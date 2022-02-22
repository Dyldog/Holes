//
//  HolesViewModel.swift
//  Holes
//
//  Created by Dylan Elliott on 19/2/2022.
//

import Foundation

class NonHolesViewModel: NSObject, ObservableObject {
    let transactionsManager: TransactionsManager
    var nonHoles: [(Date, [Transaction])] { didSet { updateCellModels() } }
    @Published var cellModels: [(String, [TransactionCellModel])] = []
    
    var allTransactions: [Transaction] { nonHoles.flatMap { $0.1} }
    
    var amountFormetter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    override init() {
        transactionsManager = .init()
        nonHoles = []
        super.init()
        reload()
    }
    
    func reload() {
        transactionsManager.getNonHoles {
            self.nonHoles = $0
        }
    }
    
    func updateCellModels() {
        DispatchQueue.main.async {
            self.cellModels = self.nonHoles.sorted { $0.0 > $1.0 }.map {
                (DateFormatter.humanReadableDateFormatter.string(from: $0.0), $0.1.map {
                    return TransactionCellModel(
                        id: $0.id,
                        title: $0.description,
                        amount: self.amountFormetter.string(from: $0.amount as NSNumber)!
                    )
                })
            }
        }
    }
    
    func unmarkTransactionAsHole(_ transaction: TransactionCellModel) {
        guard let transaction = allTransactions.first(where: { $0.id == transaction.id }) else { return }
        transactionsManager.unmarkTransactionAsHole(transaction)
        reload()
    }
}
