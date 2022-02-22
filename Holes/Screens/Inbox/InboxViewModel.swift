//
//  ContentViewModel.swift
//  Holes
//
//  Created by Dylan Elliott on 19/2/2022.
//

import Combine
import Foundation

class InboxViewModel: NSObject, ObservableObject {
    let transactionsManager: TransactionsManager
    var transactions: [Transaction] { didSet { updateCellModels() } }
    @Published var cellModels: [(String, [TransactionCellModel])] = []
    @Published var selectedTransaction: Transaction? = nil
    
    var amountFormetter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    var cancellables: [AnyCancellable] = []
    override init() {
        transactionsManager = .init()
        transactions = []
        super.init()
        reload()
        
        cancellables = cancellables + [$selectedTransaction.sink {
            print("Selected transaction updated: \($0)")
        }]
        
    }
    
    func reload() {
        DispatchQueue.global().async {
            self.transactionsManager.getUnsortedTransactions { transactions in
                DispatchQueue.main.async {
                    self.transactions = transactions
                }
            }
        }
    }
    
    func updateCellModels() {
        DispatchQueue.main.async {
            self.cellModels = self.transactions
                .sorted(by: { $0.date < $1.date })
                .groupedByDate(\.date)
                .sorted { $0.key > $1.key }.map {
                (DateFormatter.humanReadableDateFormatter.string(from: $0.key), $0.value.map {
                    TransactionCellModel(
                        id: $0.id,
                        title: $0.description,
                        subtitle: DateFormatter.timeFormatter.string(from: $0.date),
                        amount: self.amountFormetter.string(from: $0.amount as NSNumber)!,
                        type: .transaction
                    )
                })
            }
        }
    }
    
    func transaction(for cellModel: TransactionCellModel) -> Transaction? {
        return transactions.first(where: { $0.id == cellModel.id })
    }
    
    func getHoles() -> [Hole] {
        return transactionsManager.getTransactionHoles()
    }
    
    func markTransaction(_ transaction: TransactionCellModel, toEvent event: Event) {
        guard let transaction = transactions.first(where: { $0.id == transaction.id }) else { return }
        transactionsManager.addTransaction(transaction, toEvent: event)
        reload()
    }
    
//    func addTransaction(_ transaction: TransactionCellModel, toHoleNamed holeName: String) {
//        guard let transaction = transactions.first(where: { $0.id == transaction.id }) else { return }
//        let hole = transactionsManager.createHole(holeName)
//        transactionsManager.addTransaction(transaction, toHole: hole)
//        reload()
//    }
}

struct TransactionCellModel: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let amount: String
    let type: ItemType
}
