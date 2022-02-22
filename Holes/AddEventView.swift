//
//  AddEventView.swift
//  Holes
//
//  Created by Dylan Elliott on 22/2/2022.
//

import SwiftUI

struct AddEventView: View {
    @Environment(\.presentationMode) var presentationMode

    var transactionsManager: TransactionsManager = .init()
    
    let transaction: Transaction
    @State var eventTitle: String?
    var completion: () -> Void
    
    var body: some View {
        SearchView(
            title: "Select Event",
            subtitle: "For \(transaction.title)",
            items: transactionsManager.getEvents(),
            completion: { selectedEvent, searchText in
                switch selectedEvent {
                case let .add(event):
                    transactionsManager.addTransaction(transaction, toEvent: event)
                    completion()
                case .create:
                    eventTitle = searchText
                }
            }
        )
        .sheet(item: $eventTitle) { eventTitle in
            SelectHoleView(itemTitle: eventTitle, itemID: "NONE", allowsRootSelection: false) { hole in
                // Shouldn't be nil here
                guard let hole = hole else { return }
                let event = transactionsManager.createEvent(eventTitle, in: hole)
                transactionsManager.moveTransaction(withID: transaction.id, toEventWithID: event.id)
                completion()
            }
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}
