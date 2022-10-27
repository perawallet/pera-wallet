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
    case address = "address"
    case app = "application"
    case firstRound = "firstRound"
    case lastRound = "lastRound"
    case accessToken = "access_token"
    case top = "top"
    case username = "username"
    case bid = "SignedBinary"
    case max = "max"
    case beforeTime = "before-time"
    case afterTime = "after-time"
    case clientId = "client_id"
    case clientSecret = "client_secret"
    case code = "code"
    case grantType = "grant_type"
    case redirectUri = "redirect_uri"
    case algoDollarConversion = "symbol"
    case note = "note"
    case email = "email"
    case category = "category"
    case pushToken = "push_token"
    case id = "id"
    case platform = "platform"
    case model = "model"
    case locale = "locale"
    case accounts = "accounts"
    case transactionId = "transaction_id"
    case assetId = "assetIdx"
    case sender = "sender_address"
    case receiver = "receiver_address"
    case asset = "asset_id"
    case assetIDs = "asset_ids"
    case limit = "limit"
    case query = "q"
    case offset = "offset"
    case status = "status"
    case transactionDetailId = "txid"
    case next = "next"
    case assetIdFilter = "asset-id"
    case transactionType = "tx-type"
    case cursor = "cursor"
    case authAddress = "auth-addr"
    case publicKey = "public_key"
    case receivesNotifications = "receive_notifications"
    case paginator = "paginator"
    case since = "since"
    case until = "until"
    case interval = "interval"
    case includesAll = "include-all"
    case hasCollectible = "has_collectible"
    case walletAddress = "wallet_address"
    case redirectUrl = "redirect_url"
    case exclude = "exclude"
    case includeDeleted = "include_deleted"
    case name = "name"
    case deviceId = "device_id"
    case privateKey = "private_key"
    case encryptedContent = "encrypted_content"
}
