//
//  UpTransactionsResponse.swift
//  Holes
//
//  Created by Dylan Elliott on 19/2/2022.
//

import Foundation

struct UpTransactionsResponse: Codable {
    let data: [UpTransaction]
}

struct UpTransaction: Codable {
    let id: String
    let attributes: UpTransactionAttributes
    let relationships: UpTransferRelationships
    
    var isRoundup: Bool { attributes.description.lowercased() == "round up" }
    var isInternalTransfer: Bool { relationships.transferAccount != nil }
}

struct UpTransactionAttributes: Codable {
    let description: String
    let status: UpTransactionStatus
    let amount: UpTransactionAmount
    let createdAt: Date
    let settledAt: Date?
    let roundUp: UpTransactionRoundup?
}

struct UpTransactionRoundup: Codable {
    let amount: UpTransactionAmount
}

enum UpTransactionStatus: String, Codable {
    case settled = "SETTLED"
    case held = "HELD"
}

struct UpTransactionAmount: Codable {
    let currencyCode: String
    let value: String
    let valueInBaseUnits: Double
}

struct UpTransferRelationships: Codable {
    let account: UpAccount
    let transferAccount: UpAccount?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        account = try container.decode(UpAccount.self, forKey: .account)
        transferAccount = try? container.decodeIfPresent(UpAccount.self, forKey: .transferAccount)
    }
    
    enum CodingKeys: String, CodingKey {
        case account
        case transferAccount
    }
}

struct UpAccount: Codable {
    let data: UpAccountData
}

struct UpAccountData: Codable {
    let type: String
    let id: String
}
