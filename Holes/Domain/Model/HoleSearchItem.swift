//
//  HoleSearchItem.swift
//  Holes
//
//  Created by Dylan Elliott on 22/2/2022.
//

import Foundation

enum HoleSearchItem: SearchItem {
    case add(Hole)
    case create
    
    var title: String {
        switch self {
        case .add(let hole): return hole.title
        case .create: return "Create New Hole"
        }
    }
}
