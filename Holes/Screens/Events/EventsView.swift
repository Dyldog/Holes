//
//  EventsView.swift
//  Holes
//
//  Created by Dylan Elliott on 19/2/2022.
//

import SwiftUI

struct EventsView: View {
    @ObservedObject var viewModel: EventsViewModel = .init()
    
    @State var selectedEvent: TransactionCellModel? = nil
    
    var body: some View {
        List(viewModel.cellModels, id: \.0) { section in
            Section(section.0) {
                ForEach(section.1) { event in
                    TransactionCell(transaction: event)
                }
            }
        }
        .navigationTitle("Events")
        .onAppear {
            viewModel.reload()
        }
//        .alert(item: $selectedEvent) { Event in
//            Alert(
//                title: Text("Unmark as Hole?"),
//                message: nil,
//                primaryButton: .default(Text("OK"), action: { viewModel.unmarkTransactionAsHole(transaction)}),
//                secondaryButton: .cancel()
//            )
//        }
    }
}
