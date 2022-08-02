// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  NotificationDetail.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class NotificationDetail: ALGAPIModel {
    var type: NotificationType
    let senderAddress: String?
    let receiverAddress: String?
    let asset: NotificationAsset?
    let amount: UInt64
    
    init() {
        self.type = .broadcast
        self.senderAddress = nil
        self.receiverAddress = nil
        self.asset = nil
        self.amount = 0
    }
    
    init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decodeIfPresent(NotificationType.self, forKey: .notificationType)
        
        let amount: UInt64
        if let anAmount = try container.decodeIfPresent(UInt64.self, forKey: .amount) {
            amount = anAmount
        } else if let amountString = try container.decodeIfPresent(String.self, forKey: .amountStr),
                  let anAmount = UInt64(amountString) {
            amount = anAmount
        } else {
            amount = 0
        }
        
        self.type = type ?? .broadcast
        self.senderAddress = try container.decodeIfPresent(String.self, forKey: .senderAddress)
        self.receiverAddress = try container.decodeIfPresent(String.self, forKey: .receiverAddress)
        self.asset = try container.decodeIfPresent(NotificationAsset.self, forKey: .asset)
        self.amount = amount
    }
    
    func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .notificationType)
        try container.encodeIfPresent(senderAddress, forKey: .senderAddress)
        try container.encodeIfPresent(receiverAddress, forKey: .receiverAddress)
        try container.encodeIfPresent(asset, forKey: .asset)
        try container.encode(amount, forKey: .amount)
    }
    
    private enum CodingKeys:
        String,
        CodingKey {
        case notificationType = "notification_type"
        case senderAddress = "sender_public_key"
        case receiverAddress = "receiver_public_key"
        case asset
        case amount
        case amountStr = "amount_str"
    }
}

enum NotificationType:
    String,
    JSONModel {
    case transactionSent = "transaction-sent"
    case transactionReceived = "transaction-received"
    case transactionFailed = "transaction-failed"
    case assetTransactionSent = "asset-transaction-sent"
    case assetTransactionReceived = "asset-transaction-received"
    case assetTransactionFailed = "asset-transaction-failed"
    case assetSupportRequest = "asset-support-request"
    case assetSupportSuccess = "asset-support-success"
    case broadcast = "broadcast"

    init() {
        self = .broadcast
    }
    
    func isSent() -> Bool {
        switch self {
        case .transactionSent, .assetTransactionSent:
            return true
        default:
            return false
        }
    }
}
