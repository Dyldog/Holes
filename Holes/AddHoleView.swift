//
//  AddHoleView.swift
//  Holes
//
//  Created by Dylan Elliott on 22/2/2022.
//

import SwiftUI

struct SelectHoleView: View {
    var transactionsManager: TransactionsManager = .init()
    
    let itemTitle: String
    let itemID: String
    let allowsRootSelection: Bool
    
    @State var newParentTitle: String?
    var completion: (Hole?) -> Void
    
    var body: some View {
        SearchView(
            title: "Select Hole",
            subtitle: "For \(itemTitle)",
            items: searchItems(),
            completion: { selectedEvent, searchText in
                switch selectedEvent {
                case let .add(hole):
                    guard let id = hole.id else {
                        completion(nil)
                        return
                    }
                    
                    guard let hole = transactionsManager.hole(withID: id) else { return }
                    completion(hole)
                case .create:
                    newParentTitle = searchText
                }
            }
        )
        .sheet(item: $newParentTitle) { parentTitle in
            let newHole = transactionsManager.createHole(parentTitle)
            SelectHoleView(itemTitle: newHole.title, itemID: newHole.id, allowsRootSelection: true) { parentHole in
                guard let _ = transactionsManager.moveHole(withID: newHole.id, toHoleWithID: parentHole?.id) else { return }
                completion(newHole)
            }
        }
    }
    
    func searchItems() -> [TransactionGroupSearchModel] {
        var models = transactionsManager.getTransactionHoles()
            .filter { $0.id != itemID }
            .map { $0.searchModel() }
        if allowsRootSelection {
            models = models + [.rootModel]
        }
        
        return models
            
    }
}
