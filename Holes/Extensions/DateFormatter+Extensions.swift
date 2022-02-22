//
//  DateFormatter+Extensions.swift
//  Holes
//
//  Created by Dylan Elliott on 22/2/2022.
//

import Foundation

extension DateFormatter {
    static let humanReadableDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        return formatter
    }()
}
