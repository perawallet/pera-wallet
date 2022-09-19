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

//   ALGAnalyticsMetadata.swift

import Foundation
import MacaroonVendors

typealias ALGAnalyticsMetadata = [ALGAnalyticsMetadataKey: Any]

/// <note>
/// Naming convention:
/// The actual key should be used unless there requires some context-related distinction.
/// Sort;
/// Alphabetical order by value
enum ALGAnalyticsMetadataKey:
    String,
    AnalyticsMetadataKey {
    case accountType = "account_type"
    case accountAddress = "address"
    case amount
    case assetID = "asset_id"
    case dappName = "dapp_name"
    case dappURL = "dapp_url"
    case id
    case isMax = "is_max"
    case allowNotifications = "is_receiving_notifications"
    case mismatchFoundAccountAddress = "received_address"
    case mismatchExpectedAccountAddress = "requested_address"
    case senderAccountAddress = "sender"
    case signedTransaction = "signed_transaction"
    case wcSessionTopic = "topic"
    case transactionCount = "transaction_count"
    case transactionID = "tx_id"
    case accountCreationType = "type"
    case unsignedTransaction = "unsigned_transaction"
}
