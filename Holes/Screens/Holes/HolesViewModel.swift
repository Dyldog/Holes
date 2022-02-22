//
//  HolesViewModel.swift
//  Holes
//
//  Created by Dylan Elliott on 19/2/2022.
//

import Foundation

class HolesViewModel: NSObject, ObservableObject {
    let transactionsManager: TransactionsManager
    var holes: [(Date, [HoleTransaction])] { didSet { updateCellModels() } }
    @Published var cellModels: [(String, [TransactionCellModel])] = []
    var allTransactions: [HoleTransaction] { holes.flatMap { $0.1} }
    
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
        transactionsManager.getHoles {
            self.holes = $0
        }
    }
    
    func updateCellModels() {
        DispatchQueue.main.async {
            self.cellModels = self.holes.sorted { $0.0 > $1.0 }.map {
                let total = self.amountFormetter.string(from: $0.1.map { $0.amount }.sum() as NSNumber)!
                let date = DateFormatter.humanReadableDateFormatter.string(from: $0.0)
                let title = "\(date) - \(total)"
                return (title, $0.1.sorted(by: { $0.date < $1.date }).map {
                    return TransactionCellModel(
                        id: $0.id,
                        title: $0.description,
                        subtitle: DateFormatter.timeFormatter.string(from: $0.date),
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

extension Array where Element: Numeric {
    func sum() -> Element {
        return reduce(0, { return $0 + $1})
    }
}
