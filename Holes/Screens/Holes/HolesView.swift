//
//  HolesView.swift
//  Holes
//
//  Created by Dylan Elliott on 19/2/2022.
//

import SwiftUI

struct HolesView: View {
    @ObservedObject var viewModel: HolesViewModel = .init()
    
    @State var selectedTransaction: TransactionCellModel? = nil
    
    var body: some View {
        List(viewModel.cellModels, id: \.0) { section in
            Section(header: Text(section.0)) {
                ForEach(section.1){ transaction in
                    TransactionCell(transaction: transaction)
                    .onTapGesture(perform: {
                        selectedTransaction = transaction
                    })
                    .swipeActions {
                        Button(role: .destructive) {
                            viewModel.unmarkTransactionAsHole(transaction)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                }
            }
        }
        .navigationTitle("Holes")
        .onAppear {
            viewModel.reload()
        }
        .alert(item: $selectedTransaction) { transaction in
            Alert(
                title: Text("Unmark as Hole?"),
                message: nil,
                primaryButton: .default(Text("OK"), action: { viewModel.unmarkTransactionAsHole(transaction)}),
                secondaryButton: .cancel()
            )
        }
    }
}
