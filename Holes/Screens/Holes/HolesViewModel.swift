//
//  HolesViewModel.swift
//  Holes
//
//  Created by Dylan Elliott on 19/2/2022.
//

import Foundation

class HolesViewModel: NSObject, ObservableObject {
    let transactionsManager: TransactionsManager
    var holes: [Hole] { didSet { updateCellModels() } }
    @Published var cellModels: [TransactionCellModel] = []
    
    var amountFormetter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    override init() {
        transactionsManager = .init()
        holes = []
        super.init()
        reload()
    }
    
    func reload() {
        holes = transactionsManager.getTransactionHoles()
    }
    
    func updateCellModels() {
        DispatchQueue.main.async {
            self.cellModels = self.holes.map {
                let transactions = self.transactionsManager.transactions(for: $0, includingDescendantHoles: false)
                let total = transactions.map { $0.amount }.sum()
                return TransactionCellModel(
                    id: $0.id,
                    title: $0.title,
                    subtitle: "\(transactions.count) transactions",
                    amount: self.amountFormetter.string(from: total as NSNumber)!,
                    type: .hole
                )
            }
        }
    }
    
//    func unmarkTransactionAsHole(_ transaction: TransactionCellModel) {
//        guard let transaction = allTransactions.first(where: { $0.id == transaction.id }) else { return }
//        transactionsManager.unmarkTransactionAsHole(transaction)
//        reload()
//    }
}

extension Array where Element: Numeric {
    func sum() -> Element {
        return reduce(0, { return $0 + $1})
    }
}
