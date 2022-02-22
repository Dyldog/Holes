//
//  TransactionCell.swift
//  Holes
//
//  Created by Dylan Elliott on 22/2/2022.
//

import SwiftUI

struct TransactionCell: View {
    let transaction: TransactionCellModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.subtitle)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Text(transaction.title)
            }
            Spacer()
            Text(transaction.amount)
        }
        .contentShape(Rectangle())
    }
}
