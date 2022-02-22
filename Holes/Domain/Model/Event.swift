//
//  Event.swift
//  Holes
//
//  Created by Dylan Elliott on 22/2/2022.
//

import Foundation

struct Event: Codable, SearchItem {
    let id: String
    let title: String
    let holeID: String
}
