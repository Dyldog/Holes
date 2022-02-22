//
//  TransactionManager.swift
//  Holes
//
//  Created by Dylan Elliott on 22/2/2022.
//

import Foundation

struct TransactionsManager {
    static let shared: TransactionsManager = .init()
    
    private let upClient: UPAPIClient = .init()
    
    // MARK: - UserDefaults Storage
    private func retrieveLocalTransactions() -> [Transaction] {
        return UserDefaults.standard.decodableForKey(Constants.transactionUserDefaultsKey) ?? []
    }
    
    private func storeLcoalTransactions(_ transactions: [Transaction]) {
        UserDefaults.standard.setEncodable(transactions, for: Constants.transactionUserDefaultsKey)
    }
    
    private func retrieveHoles() -> [Hole] {
        return UserDefaults.standard.decodableForKey(Constants.holesUserDefaultsKey) ?? []
    }
    
    private func storeHoles(_ holes: [Hole]) {
        return UserDefaults.standard.setEncodable(holes, for: Constants.holesUserDefaultsKey)
    }
    
    private func retrieveEvents() -> [Event] {
        return UserDefaults.standard.decodableForKey(Constants.eventsUserDefaultsKey) ?? []
    }
    
    private func storeEvents(_ holes: [Event]) {
        return UserDefaults.standard.setEncodable(holes, for: Constants.eventsUserDefaultsKey)
    }
    
    // MARK: Transactions
    
    func transaction(withID id: String) -> Transaction? {
        return retrieveLocalTransactions().first(where: { $0.id == id })
    }
    
    func getUnsortedTransactions(_ completion: @escaping ([Transaction]) -> Void) {
        let localTransactions = retrieveLocalTransactions()
        let localIDs = localTransactions.map { $0.id }
        upClient.getTransactions { response in
            let newTransactions = response.filter { localIDs.contains($0.id) == false }
            storeLcoalTransactions(localTransactions + newTransactions)
            let unsorted = localTransactions.filter { $0.holeStatus == .unsorted } + newTransactions
            completion(unsorted)
        }
    }
    
    func transactions(for event: Event) -> [Transaction] {
        retrieveLocalTransactions()
            .filter {
                if case let .hole(eventID, _) = $0.holeStatus {
                    return event.id == eventID
                } else {
                    return false
                }
            }
    }
    
    func transactions(for hole: Hole, includingDescendantHoles: Bool) -> [Transaction] {
        let eventsIDs = events(for: hole, includingDescendantHoles: includingDescendantHoles).map { $0.id }
        return retrieveLocalTransactions().filter {
            switch $0.holeStatus {
            case let .hole(eventID, _): return eventsIDs.contains(eventID)
            default: return false
            }
        }
    }
    
    func addTransaction(_ transaction: Transaction, toEvent event: Event) {
        let holed = Transaction(
            id: transaction.id,
            description: transaction.description,
            amount: transaction.amount,
            date: transaction.date,
            holeStatus: .hole(event.id, transaction.date)
        )
        
        let newTransactions = retrieveLocalTransactions().filter { $0.id != transaction.id } + [holed]
        storeLcoalTransactions(newTransactions)
    }
    
    func moveTransaction(withID: String, toEventWithID: String) {
        guard let transaction = retrieveLocalTransactions().first(where: { $0.id == withID }) else { return }
        
        let moved = Transaction(
            id: transaction.id,
            description: transaction.description,
            amount: transaction.amount,
            date: transaction.date,
            holeStatus: .hole(toEventWithID, transaction.date)
        )
        
        storeLcoalTransactions(retrieveLocalTransactions().filter { $0.id != moved.id } + [moved])
    }
    
    
    // MARK: - Events
    
    func createEvent(_ name: String, in hole: Hole) -> Event {
        let event = Event(id: UUID().uuidString, title: name, holeID: hole.id)
        storeEvents(retrieveEvents() + [event])
        return event
    }
    
    func event(withID id: String) -> Event? {
        return retrieveEvents().first(where: { $0.id == id })
    }
    
    func getEvents() -> [Event] {
        retrieveEvents()
    }
    
    func events(for hole: Hole, includingDescendantHoles: Bool) -> [Event] {
        var holesToSearch = [hole]
        
        if includingDescendantHoles {
            holesToSearch = holesToSearch + childHoles(for: hole, includeDescendents: true)
        }
        
        return holesToSearch.flatMap { hole in
            retrieveEvents().filter { $0.holeID == hole.id }
        }
    }
    
    func moveEvent(withID eventID: String, toHoleWithID holeID: String) {
        guard let event = event(withID: eventID) else { return }
        let moved = Event(
            id: event.id,
            title: event.title,
            holeID: holeID
        )
        
        storeEvents(getEvents().filter { $0.id != moved.id } + [moved])
    }
    
    @discardableResult
    func moveHole(withID holeID: String, toHoleWithID newParentID: String?) -> Hole? {
        guard let hole = hole(withID: holeID) else { return nil }
        let moved = Hole(
            id: hole.id,
            title: hole.title,
            parentID: newParentID
        )
        
        storeHoles(retrieveHoles().filter { $0.id != moved.id } + [moved])
        
        return hole
    }
    
    // MARK: - Holes
    
    func createHole(_ name: String) -> Hole {
        let hole = Hole(id: UUID().uuidString, title: name, parentID: nil)
        storeHoles(retrieveHoles() + [hole])
        return hole
    }
    
    func hole(withID id: String) -> Hole? {
        return retrieveHoles().first(where: { $0.id == id })
    }
    
    func getTransactionHoles() -> [Hole] {
        retrieveHoles()
    }
    
    func getTopLevelHoles() -> [Hole] {
        getTransactionHoles().filter { $0.parentID == nil }
    }
    func childHoles(for hole: Hole, includeDescendents: Bool) -> [Hole] {
        let directChildren = retrieveHoles().filter { $0.parentID == hole.id }
        
        if includeDescendents == false {
            return directChildren
        } else {
            let grandChildren = directChildren.flatMap {
                childHoles(for: $0, includeDescendents: true)
            }
            
            return directChildren + grandChildren
        }
    }
    
    func getHoles(_ completion: @escaping ([(Date, [HoleTransaction])]) -> Void) {
        let holes = retrieveLocalTransactions()
            .compactMap { $0.asHoleTransaction() }
            .groupedByDate(\.holeDate)
            .map { ($0.key, $0.value) }
        completion(holes)
    }
    
    enum Constants {
        static let transactionUserDefaultsKey = "LOCAL_TRANSACTIONS"
        static let holesUserDefaultsKey = "LOCAL_HOLES"
        static let eventsUserDefaultsKey = "LOCAL_EVENTS"
    }
}
