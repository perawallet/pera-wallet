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
//   ALGAPIPath.swift

import Foundation
import MagpieCore

enum ALGAPIPath: String {
    case accountDetail = "/accounts/%@"
    case accounts = "/accounts"
    case accountTransaction = "/accounts/%@/transactions"
    case transactions = "/transactions"
    case transactionParams = "/transactions/params"
    case trackTransactions = "/transactions/"
    case pendingAccountTransactions = "/accounts/%@/transactions/pending"
    case devices = "/devices/"
    case deviceDetail = "/devices/%@/"
    case deviceAccountUpdate = "/devices/%@/accounts/%@/"
    case notifications = "/devices/%@/notifications/"
    case assets = "/assets/"
    case assetDetail = "/assets/%@/"
    case assetRequest = "/asset-requests/"
    case assetSearch = "/assets/search/"
    case verifiedAssets = "/verified-assets/"
    case currencies = "/currencies/"
    case currencyDetail = "/currencies/%@/"
    case waitForBlock = "/status/wait-for-block-after/%@"
    case supply = "/ledger/supply"
    case blockDetail = "/blocks/%d"
    case status = "/status"
    case algoUSDHistory = "/price/algo-usd/history"
    case signBuyAlgo = "/moonpay/sign-url/"
    case announcements = "/devices/%@/banners/"
    case nameServicesSearch = "/name-services/search/"
}

extension EndpointBuilder {
    @discardableResult
    func path(_ aPath: ALGAPIPath) -> Self {
        let vPath = MagpieCore.Path(aPath.rawValue)
        return path(vPath)
    }

    @discardableResult
    func path(_ aPath: ALGAPIPath, args: CVarArg...) -> Self {
        let vPath = MagpieCore.Path(format: aPath.rawValue, arguments: args)
        return path(vPath)
    }
}
