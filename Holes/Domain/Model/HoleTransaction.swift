//
//  HoleTransaction.swift
//  Holes
//
//  Created by Dylan Elliott on 22/2/2022.
//

import Foundation

struct HoleTransaction: Codable, Identifiable {
    let id: String
    let description: String
    /// In AUD
    let amount: Double
    let date: Date
    
    let holeID: String
    let holeDate: Date
}
