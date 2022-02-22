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
    
    let holeStatus: HoleStatus
    
    func asHoleTransaction() -> HoleTransaction? {
        guard case let .hole(holeID, holeDate) = holeStatus else { return nil }
        
        return HoleTransaction(
            id: id,
            description: description,
            amount: amount,
            date: date,
            holeID: holeID,
            holeDate: holeDate
        )

    }
}

enum HoleStatus: Codable, Equatable {
    case unsorted
    case nonHole
    case hole(String, Date)
    
    static func ==(lhs: HoleStatus, rhs: HoleStatus) -> Bool {
        switch (lhs, rhs) {
        case let (.hole(lhsID, lhsDate), .hole(rhsID, rhsDate)):
            return lhsID == rhsID && lhsDate == rhsDate
        case (.unsorted, .unsorted), (.nonHole, .nonHole):
            return true
        case (.unsorted, _), (.hole, _), (.nonHole, _):
            return false
        }
    }
}
