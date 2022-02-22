//
//  SearchView.swift
//  Turtles
//
//  Created by Dylan Elliott on 28/9/21.
//
import SwiftUI

protocol SearchItem {
    var title: String { get }
}

enum SearchViewItem<T: SearchItem>: Identifiable {
    case add(T)
    case create
    
    var id: String {
        switch self {
        case let .add(item): return item.title
        case .create: return "CREATE"
        }
    }
    
    func title(with searchText: String) -> String {
        switch self {
        case let .add(item): return item.title
        case .create: return "Create \"\(searchText)\""
        }
    }
}

struct SearchView<Item: SearchItem>: View {
    let title: String
    let subtitle: String?
    let items: [Item]
    let completion: (SearchViewItem<Item>, String) -> Void
    @State var searchText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                List(filteredItems()) { item in
                    Button {
                        completion(item, searchText)
                    } label: {
                        HStack {
                            Text(item.title(with: searchText))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(title).font(.headline)
                        if let subtitle = subtitle {
                            Text("\(subtitle)").font(.subheadline)
                        }
                    }
                }
            }
        }
    }
    
    func filteredItems() -> [SearchViewItem<Item>] {
        guard searchText.isEmpty == false else {
            return items.map { .add($0) }
        }
        
        func sanitise(text: String) -> String {
            return text.lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .joined()
        }
        
        let matchedItems = items.filter { item in
            return sanitise(text: item.title).contains(sanitise(text: searchText))
        }
        
        if matchedItems.isEmpty {
            return [.create]
        } else {
            return matchedItems.map { .add($0) }
        }
        
    }
}

