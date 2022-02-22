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
}

struct UpTransactionAttributes: Codable {
    let description: String
    let status: UpTransactionStatus
    let amount: UpTransactionAmount
    let createdAt: Date
    let settledAt: Date?
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
