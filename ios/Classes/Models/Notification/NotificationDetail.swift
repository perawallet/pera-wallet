// Copyright 2019 Algorand, Inc.

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

import Magpie

class NotificationDetail: Model {
    let senderAddress: String?
    let receiverAddress: String?
    let amount: Int64?
    let asset: NotificationAsset?
    let notificationType: NotificationType?
}

extension NotificationDetail {
    enum CodingKeys: String, CodingKey {
        case senderAddress = "sender_public_key"
        case receiverAddress = "receiver_public_key"
        case amount = "amount"
        case asset = "asset"
        case notificationType = "notification_type"
    }
}

enum NotificationType: String, Model {
    case transactionSent = "transaction-sent"
    case transactionReceived = "transaction-received"
    case transactionFailed = "transaction-failed"
    case assetTransactionSent = "asset-transaction-sent"
    case assetTransactionReceived = "asset-transaction-received"
    case assetTransactionFailed = "asset-transaction-failed"
    case assetSupportRequest = "asset-support-request"
    case assetSupportSuccess = "asset-support-success"
    case broadcast = "broadcast"
}
