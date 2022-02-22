//
//  EventsViewModel.swift
//  Holes
//
//  Created by Dylan Elliott on 19/2/2022.
//

import Foundation

class EventsViewModel: NSObject, ObservableObject {
    let transactionsManager: TransactionsManager
    var events: [Event] { didSet { updateCellModels() } }
    @Published var cellModels: [(String, [TransactionCellModel])] = []
    
    var amountFormetter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    override init() {
        transactionsManager = .init()
        events = []
        super.init()
        reload()
    }
    
    func reload() {
        events = transactionsManager.getEvents()
    }
    
    func updateCellModels() {
        DispatchQueue.main.async {
            let eventTransactions: [(Date, Event, [Transaction])] = self.events.map {
                let transactions = self.transactionsManager.transactions(for: $0)
                let date = transactions.map { $0.date }.min() ?? .distantPast
                return (date, $0, transactions)
            }
            
            self.cellModels = eventTransactions.groupedByDate(\.0).sorted(by: { $0.key > $1.key }).map { event in
                let date = DateFormatter.humanReadableDateFormatter.string(from: event.key)
                let transactionCellModels: [TransactionCellModel] = event.value.flatMap { $0 }.map {
                    let transactions = $0.2
                    let total = $0.2.map { $0.amount }.sum()
                    
                    return TransactionCellModel(
                        id: $0.1.id,
                        title: $0.1.title,
                        subtitle: "\(transactions.count) transactions",
                        amount: self.amountFormetter.string(from: total as NSNumber)!,
                        type: .transaction
                    )
                }
                return (date, transactionCellModels)
            }
                
//                .map {
//                let total = $0.value.map { $0.amount }.sum()
//
//                let models = $0.1.map {
//                    return TransactionCellModel(
//                        id: $0.id,
//                        title: $0.title,
//                        subtitle: DateFormatter.humanReadableDateFormatter.string(from: date),
//                        amount: self.amountFormetter.string(from: total as NSNumber)!
//                    )
//                }
//            }
        }
    }
    
//    func unmarkTransactionAsHole(_ transaction: TransactionCellModel) {
//        guard let transaction = allTransactions.first(where: { $0.id == transaction.id }) else { return }
//        transactionsManager.unmarkTransactionAsHole(transaction)
//        reload()
//    }
}
