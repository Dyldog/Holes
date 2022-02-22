//
//  ContentViewModel.swift
//  Holes
//
//  Created by Dylan Elliott on 19/2/2022.
//

import Foundation

class InboxViewModel: NSObject, ObservableObject {
    let transactionsManager: TransactionsManager
    var transactions: [Transaction] { didSet { updateCellModels() } }
    @Published var cellModels: [(String, [TransactionCellModel])] = []
    
    var amountFormetter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    override init() {
        transactionsManager = .init()
        transactions = []
        super.init()
        reload()
        
    }
    
    func reload() {
        transactionsManager.getUnsortedTransactions {
            self.transactions = $0
        }
    }
    
    func updateCellModels() {
        DispatchQueue.main.async {
            self.cellModels = self.transactions.groupedByDate(\.date).sorted { $0.key > $1.key }.map {
                (DateFormatter.humanReadableDateFormatter.string(from: $0.key), $0.value.map {
                    TransactionCellModel(
                        id: $0.id,
                        title: $0.description,
                        amount: self.amountFormetter.string(from: $0.amount as NSNumber)!
                    )
                })
            }
        }
    }
    
    func markTransactionAsHole(_ transaction: TransactionCellModel, isHole: Bool) {
        guard let transaction = transactions.first(where: { $0.id == transaction.id }) else { return }
        transactionsManager.markTransactionAsHole(transaction, isHole: isHole)
        reload()
    }
}

struct TransactionCellModel: Identifiable {
    let id: String
    let title: String
    let amount: String
}
