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
//  AlgorandParamPairKey.swift

import MagpieCore

typealias APIQueryParam = ObjectQueryParam<APIParamKey>
typealias APIBodyParam = JSONObjectBodyParam<APIParamKey>

enum APIParamKey: String, CodingKey {
    case availableOnDiscover = "available_on_discover_mobile"
    case accessToken = "access_token"
    case accounts = "accounts"
    case accountType = "account_type"
    case address = "address"
    case afterTime = "after-time"
    case algoDollarConversion = "symbol"
    case amount = "amount"
    case app = "application"
    case authAddress = "auth-addr"
    case asset = "asset_id"
    case assetId = "assetIdx"
    case assetIDFilter = "asset-id"
    case assetIDs = "asset_ids"
    case assetInID = "asset_in_id"
    case assetOutID = "asset_out_id"
    case beforeTime = "before-time"
    case bid = "SignedBinary"
    case category = "category"
    case clientId = "client_id"
    case clientSecret = "client_secret"
    case code = "code"
    case cursor = "cursor"
    case lastSeenNotificationId = "last_seen_notification_id"
    case deviceId = "device_id"
    case email = "email"
    case encryptedContent = "encrypted_content"
    case exceptionText = "exception_text"
    case device = "device"
    case bridgeURL = "bridge_url"
    case topicID = "topic_id"
    case dAppName = "dapp_name"
    case endDate = "end_date"
    case exclude = "exclude"
    case firstRound = "firstRound"
    case grantType = "grant_type"
    case hasCollectible = "has_collectible"
    case id = "id"
    case includeDeleted = "include_deleted"
    case includesAll = "include-all"
    case interval = "interval"
    case lastRound = "lastRound"
    case limit = "limit"
    case locale = "locale"
    case max = "max"
    case model = "model"
    case name = "name"
    case next = "next"
    case note = "note"
    case offset = "offset"
    case paginator = "paginator"
    case platform = "platform"
    case privateKey = "private_key"
    case providers = "providers"
    case publicKey = "public_key"
    case pushToken = "push_token"
    case receiver = "receiver_address"
    case receivesNotifications = "receive_notifications"
    case redirectUri = "redirect_uri"
    case redirectUrl = "redirect_url"
    case sender = "sender_address"
    case since = "since"
    case slippage = "slippage"
    case startDate = "start_date"
    case status = "status"
    case swapperAddress = "swapper_address"
    case swapType = "swap_type"
    case top = "top"
    case transactionID = "transaction_id"
    case transactionDetailID = "txid"
    case transactionType = "tx-type"
    case until = "until"
    case username = "username"
    case query = "q"
    case quote = "quote"
    case walletAddress = "wallet_address"
}
