//
//  HolesTransactionsViewModel.swift
//  Holes
//
//  Created by Dylan Elliott on 22/2/2022.
//

import Foundation

//enum TransactionSource {
//    case holes(() -> [Hole])
//    case events(() -> [Event])
//    case transactions(() -> [Transaction])
//
//    var closure: () -> [TransactionGroup] {
//        switch self {
//        case let .events(closure): return closure
//        case let .holes(closure): return closure
//        case let .transactions(closure): return closure
//        }
//    }
//}

enum ItemType {
    case hole
    case event
    case transaction
    
    var parentType: ItemType {
        switch self {
        case .hole: return .hole
        case .event: return .hole
        case .transaction: return .event
        }
    }
    
    var title: String {
        switch self {
        case .hole: return "Hole"
        case .event: return "Event"
        case .transaction: return "Transaction"
        }
    }
}
protocol TransactionGroup: SearchItem {
    var id: String { get }
    var title: String { get }
    var subtitle: String { get }
    var amount: Double { get }
    var itemType: ItemType { get }
}

extension TransactionGroup {
    func searchModel() -> TransactionGroupSearchModel {
        return .init(
            id: id,
            title: title,
            itemType: itemType
        )
    }
}

struct TransactionGroupSearchModel: SearchItem {
    let id: String?
    let title: String
    let itemType: ItemType
    
    static var rootModel: TransactionGroupSearchModel {
        .init(id: nil, title: "NO PARENT", itemType: .hole)
    }
}

extension Transaction: TransactionGroup {
    var title: String { description }
    var subtitle: String { DateFormatter.humanReadableDateFormatter.string(from: date) }
    var itemType: ItemType { .transaction }
    var isNavigable: Bool { false }
}

extension Hole: TransactionGroup {
    var subtitle: String { "SUBTITLE" }
    var amount: Double {
        TransactionsManager.shared.transactions(for: self, includingDescendantHoles: true)
            .map { $0.amount}.sum()
    }
    var itemType: ItemType { .hole }
    var isNavigable: Bool { true }
}

extension Event: TransactionGroup {
    var subtitle: String {
        guard let date = TransactionsManager.shared.transactions(for: self).map({ $0.date }).min() else {
            return "ERRRRORRR"
        }
        
        return [
            DateFormatter.humanReadableDateFormatter.string(from: date),
            "\(TransactionsManager.shared.transactions(for: self).count) transactions"
        ].joined(separator: ", ")
    }
    var amount: Double { TransactionsManager.shared.transactions(for: self).map { $0.amount}.sum() }
    var itemType: ItemType { .event }
    var isNavigable: Bool { true }
}

class TransactionGroupViewModel: NSObject, ObservableObject {
    let transactionsManager: TransactionsManager
    let parentType: ItemType?
    let source: () -> [TransactionGroup]
    @Published var cellModels: [TransactionCellModel] = []
    
    var amountFormetter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    init(parentType: ItemType?, source: @escaping () -> [TransactionGroup]) {
        transactionsManager = .init()
        self.parentType = parentType
        self.source = source
        super.init()
        reload()
    }
    
    func reload() {
        let items = source()
        updateCellModels(items: items)
    }
    
    func updateCellModels(items: [TransactionGroup]) {
        DispatchQueue.main.async {
            self.cellModels = items.map {
                return TransactionCellModel(
                    id: $0.id,
                    title: $0.title,
                    subtitle: $0.subtitle,
                    amount: self.amountFormetter.string(from: $0.amount as NSNumber)!,
                    type: $0.itemType
                )
            }
        }
    }
    
    func sourceForItemSelection(_ item: TransactionCellModel) -> (() -> [TransactionGroup])? {
        switch item.type {
        case .hole:
        guard let hole = transactionsManager.hole(withID: item.id) else { return nil }
        return {
            return self.transactionsManager.childHoles(for: hole, includeDescendents: false) +
                   self.transactionsManager.events(for: hole, includingDescendantHoles: false)
        }
        case .event:
            guard let event = transactionsManager.event(withID: item.id) else { return nil }
            return {
                self.transactionsManager.transactions(for: event)
            }
        case .transaction:
            return nil
        }
    }
    
//    func unmarkTransactionAsHole(_ transaction: TransactionCellModel) {
//        guard let transaction = allTransactions.first(where: { $0.id == transaction.id }) else { return }
//        transactionsManager.unmarkTransactionAsHole(transaction)
//        reload()
//    }
}
