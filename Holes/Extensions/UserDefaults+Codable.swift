//
//  UserDefaults+Codable.swift
//  Holes
//
//  Created by Dylan Elliott on 22/2/2022.
//

import Foundation

extension UserDefaults {
    func decodableForKey<T: Decodable>(_ key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        
        do {
            let transactions = try JSONDecoder().decode(T.self, from: data)
            return transactions
        } catch {
            print("Error decoding user default \(String(describing: T.self)) for key \(key): \(error)")
            return nil
        }
    }
    
    func setEncodable<T: Encodable>(_ value: T, for key: String) {
        do {
            let data = try JSONEncoder().encode(value)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Error encoding \(String(describing: T.self)) for key \(key): \(error)")
        }
    }
}
