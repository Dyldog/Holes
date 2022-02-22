//
//  Hole.swift
//  Holes
//
//  Created by Dylan Elliott on 22/2/2022.
//

import Foundation

struct Hole: Codable, SearchItem {
    let id: String
    let title: String
    let parentID: String?
}
