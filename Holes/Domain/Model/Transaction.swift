//
//  Transaction.swift
//  Holes
//
//  Created by Dylan Elliott on 19/2/2022.
//

import Foundation

struct Transaction: Codable, Identifiable {
    let id: String
    let description: String
    /// In AUD
    let amount: Double
    let date: Date
    
    let isHole: Bool?
    /// If this is a transaction related to a night out, is the date of the night out
    let holeDate: Date?
    
    func asHoleTransaction() -> HoleTransaction? {
        guard let holeDate = holeDate else { return nil }
        
        return HoleTransaction(
            id: id,
            description: description,
            amount: amount,
            date: date,
            holeDate: holeDate
        )

    }
}

