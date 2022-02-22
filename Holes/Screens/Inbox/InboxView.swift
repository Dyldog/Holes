//
//  ContentView.swift
//  Holes
//
//  Created by Dylan Elliott on 19/2/2022.
//

import SwiftUI

struct InboxView: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewModel: InboxViewModel
    
    init() {
        viewModel = .init()
    }
        
    var body: some View {
        List(viewModel.cellModels, id: \.0) { section in
            Section(header: Text(section.0)) {
                ForEach(section.1){ transaction in
                    TransactionCell(transaction: transaction)
                    .onTapGesture {
                        viewModel.selectedTransaction = viewModel.transaction(for: transaction)
                    }
                }
            }
        }
        .navigationTitle("Inbox")
        .sheet(item: $viewModel.selectedTransaction, content: { transaction in
            AddEventView(transaction: transaction) {
                DispatchQueue.main.async {
                    viewModel.selectedTransaction = nil
//                    presentationMode.wrappedValue.dismiss()
                    viewModel.reload()
                }
            }
        })
        .onAppear {
            viewModel.reload()
        }
//        .actionSheet(item: $selectedTransaction, content: { transaction in
//            ActionSheet(title: Text("Mark as Hole?"), message: nil, buttons: [
//                .cancel(),
//                .default(Text("Yes"), action: {
//                    viewModel.markTransactionAsHole(transaction, isHole: true)
//                }),
//                .default(Text("No"), action: {
//                    viewModel.markTransactionAsHole(transaction, isHole: false)
//                })
////                Button("No") { },
////                Button("Yes") { },
////                .cancel()
//            ])
//        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()
    }
}
