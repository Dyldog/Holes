//
//  TransactionManager.swift
//  Holes
//
//  Created by Dylan Elliott on 22/2/2022.
//

import Foundation

struct TransactionsManager {
    private let upClient: UPAPIClient = .init()
    
    private func retrieveLocalTransactions() -> [Transaction] {
        guard let data = UserDefaults.standard.data(forKey: Constants.transactionUserDefaultsKey) else {
            return []
        }
        
        do {
            let transactions = try JSONDecoder().decode([Transaction].self, from: data)
            return transactions
        } catch {
            print("Error decoding local transactions: \(error)")
            return []
        }
    }
    
    private func storeLcoalTransactions(_ transactions: [Transaction]) {
        do {
            let data = try JSONEncoder().encode(transactions)
            UserDefaults.standard.set(data, forKey: Constants.transactionUserDefaultsKey)
        } catch {
            print("Error encoding local transactions: \(error)")
        }
    }
    
    func getUnsortedTransactions(_ completion: @escaping ([Transaction]) -> Void) {
        let localTransactions = retrieveLocalTransactions()
        let localIDs = localTransactions.map { $0.id }
        upClient.getTransactions { response in
            let newTransactions = response.filter { localIDs.contains($0.id) == false }
            storeLcoalTransactions(localTransactions + newTransactions)
            let unsorted = localTransactions.filter { $0.isHole == nil} + newTransactions
            completion(unsorted)
        }
    }
    
    func getHoles(_ completion: @escaping ([(Date, [HoleTransaction])]) -> Void) {
        let holes = retrieveLocalTransactions()
            .filter { $0.isHole == true }
            .compactMap { $0.asHoleTransaction() }
            .groupedByDate(\.holeDate)
            .map { ($0.key, $0.value) }
        completion(holes)
    }
    
    func getNonHoles(_ completion: @escaping ([(Date, [Transaction])]) -> Void) {
        let holes = retrieveLocalTransactions()
            .filter { $0.isHole == false }
            .groupedByDate(\.date)
            .map { ($0.key, $0.value.sorted(by: { $0.date < $1.date })) }
        completion(holes)
    }
    
    func markTransactionAsHole(_ transaction: Transaction, isHole: Bool) {
        let holed = Transaction(
            id: transaction.id,
            description: transaction.description,
            amount: transaction.amount,
            date: transaction.date,
            isHole: isHole,
            holeDate: transaction.date
        )
        
        let newTransactions = retrieveLocalTransactions().filter { $0.id != transaction.id } + [holed]
        storeLcoalTransactions(newTransactions)
    }
    
    func unmarkTransactionAsHole(_ transaction: HoleTransaction) {
        let unholed = Transaction(
            id: transaction.id,
            description: transaction.description,
            amount: transaction.amount,
            date: transaction.date,
            isHole: nil,
            holeDate: nil
        )
        
        let newTransactions = retrieveLocalTransactions().filter { $0.id != transaction.id } + [unholed]
        storeLcoalTransactions(newTransactions)
    }
    
    // TODO: Cannot I combine with HoleTransaction version so I'm not duplicating
    func unmarkTransactionAsHole(_ transaction: Transaction) {
        let unholed = Transaction(
            id: transaction.id,
            description: transaction.description,
            amount: transaction.amount,
            date: transaction.date,
            isHole: nil,
            holeDate: nil
        )
        
        let newTransactions = retrieveLocalTransactions().filter { $0.id != transaction.id } + [unholed]
        storeLcoalTransactions(newTransactions)
    }
    
    enum Constants {
        static let transactionUserDefaultsKey = "LOCAL_TRANSACTIONS"
    }
}
