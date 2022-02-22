//
//  MoveTransactionGroupView.swift
//  Holes
//
//  Created by Dylan Elliott on 22/2/2022.
//

import SwiftUI

struct MoveTransactionGroupView: View {
    var transactionsManager: TransactionsManager = .init()
    
    let item: TransactionCellModel
    @State var eventTitle: String?
    var completion: () -> Void
    
    var body: some View {
        switch item.type {
        case .transaction:
            if let transaction = transactionsManager.transaction(withID: item.id) {
                AddEventView(transaction: transaction) {
                    completion()
                }
            } else {
                EmptyView()
            }
        case .event:
            if let event = transactionsManager.event(withID: item.id) {
                SelectHoleView(itemTitle: event.title, itemID: event.id, allowsRootSelection: false) { hole in
                    // Shouldn't be nil
                    guard let hole = hole else { return }
                    transactionsManager.moveEvent(withID: event.id, toHoleWithID: hole.id)
                    completion()
                }
            }  else {
                EmptyView()
            }
        case .hole:
            if let hole = transactionsManager.hole(withID: item.id) {
                SelectHoleView(itemTitle: hole.title, itemID: hole.id, allowsRootSelection: true) { parent in
                    transactionsManager.moveHole(withID: hole.id, toHoleWithID: parent?.id)
                    completion()
                }
            } else {
                EmptyView()
            }
        }
//        .popover(item: $eventTitle) { eventTitle in
//            SearchView(
//                title: "Select Hole",
//                subtitle: "For \(eventTitle)",
//                items: transactionsManager.getTransactionHoles()) { selectedHole, searchText in
//                    switch selectedHole {
//                    case let .add(hole):
//                        let event = transactionsManager.createEvent(eventTitle, in: hole)
////                        transactionsManager.addTransaction(transaction, toEvent: event)
//                        completion()
//                    case .create:
//                        let hole = transactionsManager.createHole(searchText)
//                        let event = transactionsManager.createEvent(eventTitle, in: hole)
////                        transactionsManager.addTransaction(transaction, toEvent: event)
//                        completion()
//                    }
//                }
//        }
    }
    
    func searchItems() -> [TransactionGroupSearchModel] {
        let map: ([TransactionGroup]) -> [TransactionGroupSearchModel] = {
            return $0.filter { $0.id != item.id }.map { $0.searchModel() }
        }
        switch item.type {
        case .transaction:
            return map(transactionsManager.getEvents())
        case .hole:
            return map(transactionsManager.getTransactionHoles()) + [.rootModel]
        case .event:
            return map(transactionsManager.getTransactionHoles())
        }
    }
    
    func moveItem(to selection: TransactionGroupSearchModel) {
        switch (item.type, selection.itemType) {
        case (.transaction, .event):
            guard let selectionID = selection.id else { return }
            transactionsManager.moveTransaction(withID: item.id, toEventWithID: selectionID)
        case (.event, .hole):
            guard let selectionID = selection.id else { return }
            transactionsManager.moveEvent(withID: item.id, toHoleWithID: selectionID)
        case (.hole, .hole):
            transactionsManager.moveHole(withID: item.id, toHoleWithID: selection.id)
        default:
            return
        }
    }
    
    func moveItem(to newParent: String) {
        
    }
}
