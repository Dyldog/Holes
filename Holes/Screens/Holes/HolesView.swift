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
        List(viewModel.cellModels) { hole in
            TransactionCell(transaction: hole)
        }
        .navigationTitle("Holes")
        .onAppear {
            viewModel.reload()
        }
    }
}
