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
//  AnalyticsEvent.swift

import Foundation

typealias AnalyticsParameters = [AnalyticsParameter: Any]

protocol AnalyticsEvent {
    var key: AnalyticsEventKey { get }
    var params: AnalyticsParameters? { get }
}

extension AnalyticsEvent {
    var params: AnalyticsParameters? {
        return nil
    }
}

enum AnalyticsEventKey: String {
    case currencyChange = "currency_change"
    case rekey = "rekey"
    case transaction = "transaction"
    case register = "register"
    case tabSend = "tap_tab_send"
    case detailSend = "tap_asset_detail_send"
    case showQRCopy = "tap_show_qr_copy"
    case showQRShare = "tap_show_qr_share"
    case showQRShareComplete = "tap_show_qr_share_complete"
    case tabReceive = "tap_tab_receive"
    case detailReceive = "tap_asset_detail_receive"
    case assetDetail = "asset_detail_asset"
    case assetDetailChange = "asset_detail_asset_change"
    case notificationFilter = "notification_filter_change"
    case wcSessionApproved = "wc_session_approved"
    case wcSessionRejected = "wc_session_rejected"
    case wcSessionDisconnected = "wc_session_disconnected"
    case wcTransactionConfirmed = "wc_transaction_confirmed"
    case wcTransactionDeclined = "wc_transaction_declined"
}

enum AnalyticsParameter: String {
    case id = "id"
    case address = "address"
    case type = "type"
    case amount = "amount"
    case isMax = "is_max"
    case accountType = "account_type"
    case assetId = "asset_id"
    case sender = "sender"
    case unsignedTransaction = "unsigned_transaction"
    case signedTransaction = "signed_transaction"
    case isReceivingNotifications = "is_receiving_notifications"
    case transactionId = "tx_id"
    case dappName = "dapp_name"
    case dappURL = "dapp_url"
    case transactionCount = "transaction_count"
    case topic = "topic"
}
