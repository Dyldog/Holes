//
//  ContentView.swift
//  Holes
//
//  Created by Dylan Elliott on 19/2/2022.
//

import SwiftUI

struct InboxView: View {
    @ObservedObject var viewModel: InboxViewModel = .init()
    
    @State var selectedTransaction: TransactionCellModel? = nil
    
    var body: some View {
        List(viewModel.cellModels, id: \.0) { section in
            Section(header: Text(section.0)) {
                ForEach(section.1){ transaction in
                    TransactionCell(transaction: transaction)
                    .onTapGesture {
                        selectedTransaction = transaction
                    }
                }
            }
        }
        .navigationTitle("Inbox")
        .onAppear {
            viewModel.reload()
        }
        .actionSheet(item: $selectedTransaction, content: { transaction in
            ActionSheet(title: Text("Mark as Hole?"), message: nil, buttons: [
                .cancel(),
                .default(Text("Yes"), action: {
                    viewModel.markTransactionAsHole(transaction, isHole: true)
                }),
                .default(Text("No"), action: {
                    viewModel.markTransactionAsHole(transaction, isHole: false)
                })
//                Button("No") { },
//                Button("Yes") { },
//                .cancel()
            ])
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()
    }
}
