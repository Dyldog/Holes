//
//  HolesTransactionsView.swift
//  Holes
//
//  Created by Dylan Elliott on 22/2/2022.
//

import SwiftUI

typealias TransactionSource = () -> [TransactionGroup]

struct TransactionGroupView: View {
    let title: String
    
    @ObservedObject var viewModel: TransactionGroupViewModel
    
    @State var selectedItem: TransactionSource? = nil
    @State var moveItem: TransactionCellModel? = nil
    
    init(title: String, type: ItemType?, source: @escaping TransactionSource) {
        self.title = title
        viewModel = .init(parentType: type, source: source)
    }
    
    var body: some View {
        List {
            ForEach(viewModel.cellModels) { hole in
                let view = TransactionCell(transaction: hole)
                
                let swipeAction = {
                    moveItem = hole
                }
                
                if let source = viewModel.sourceForItemSelection(hole) {
                    NavigationLink {
                        TransactionGroupView(title: hole.title, type: hole.type, source: source)
                    } label: {
                        view
                    }.withSwipeAction {
                        swipeAction()
                    }
                } else {
                    view.withSwipeAction {
                        swipeAction()
                    }
                }
            }
        }
        .popover(item: $moveItem, content: { item in
            MoveTransactionGroupView(item: item, completion: {
                moveItem = nil
                viewModel.reload()
            })
        })
        .onAppear {
            viewModel.reload()
        }
        .navigationTitle(title)
        
    }
}

private extension View {
    @ViewBuilder
    func withSwipeAction(action: @escaping () -> Void) -> some View {
        self.swipeActions(allowsFullSwipe: false) {
            Button {
                action()
            } label: {
                Label("Move", systemImage: "folder.fill")
            }
            .tint(.blue)
        }
    }
}
