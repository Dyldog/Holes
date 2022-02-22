//
//  Dictionary+Extensions.swift
//  Holes
//
//  Created by Dylan Elliott on 19/2/2022.
//

import Foundation

extension Array {
    func groupedByDate(_ keypath: KeyPath<Element, Date>) -> [Date: [Element]] {
        return Dictionary(grouping: self) { element in
            let date = element[keyPath: keypath]
            let comps = Calendar.current.dateComponents([.day, .year, .month], from: date)
            return Calendar.current.date(from: comps)!
        }
    }
    
}
