//
//  UpAPIClient.swift
//  Holes
//
//  Created by Dylan Elliott on 19/2/2022.
//

import Foundation

struct UPAPIClient {
    func getTransactions(_ completion: @escaping ([Transaction]) -> Void) {
        let url = URL(string: "https://api.up.com.au/api/v1/transactions")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(Secrets.Up.apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // Error
                print("Error: \(error.localizedDescription)")
            } else if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let upResponse = try decoder.decode(UpTransactionsResponse.self, from: data)
                    let domainTransactions = upResponse.data.map {
                        return Transaction(
                            id: $0.id,
                            description: $0.attributes.description,
                            amount: $0.attributes.amount.valueInBaseUnits / 100.0,
                            date: $0.attributes.createdAt,
                            isHole: nil,
                            holeDate: nil
                        )
                    }
                    completion(domainTransactions)
                } catch {
                    print("Error decoding response: \(error)")
                    
                    if let dataString = String(data: data, encoding: .utf8) {
                        print("\(dataString)")
                    } else {
                        print("Couldn't decode string from response data")
                    }
                }
            } else {
                print("No response data or error returned: \(response?.debugDescription ?? "NO RESPONSE")")
            }
        }.resume()
    }
}
