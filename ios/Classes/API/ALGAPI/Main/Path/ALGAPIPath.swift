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
    case deviceNotificationStatus = "/devices/%@/notification-status/"
    case lastSeenNotificationStatus = "/devices/%@/update-last-seen-notification/"
    case availableSwapPoolAssets = "/dex-swap/available-assets/"
    case algoUSDHistory = "/price/algo-usd/history"
    case announcements = "/devices/%@/banners/"
    case assetDetail = "/assets/%@/"
    case assetRequest = "/asset-requests/"
    case assets = "/assets/"
    case assetSearch = "/assets/search/"
    case backups = "/backups/%@"
    case blockDetail = "/blocks/%d"
    case calculatePeraFee = "/dex-swap/calculate-pera-fee/"
    case currencies = "/currencies/"
    case currencyDetail = "/currencies/%@/"
    case deviceAccountUpdate = "/devices/%@/accounts/%@/"
    case deviceDetail = "/devices/%@/"
    case devices = "/devices/"
    case nameServicesSearch = "/name-services/search/"
    case subscribeToWalletConnectSession = "/devices/wallet-connect-subscriptions/"
    case exportTransactions = "/accounts/%@/export-history/"
    case trendingAssets = "/discover/assets/trending/"
    case notifications = "/devices/%@/notifications/"
    case pendingAccountTransactions = "/accounts/%@/transactions/pending"
    case pendingTransaction = "/transactions/pending/%@"
    case prepareSwapTransaction = "/dex-swap/prepare-transactions/"
    case signBuyAlgo = "/moonpay/sign-url/"
    case status = "/status"
    case supply = "/ledger/supply"
    case swapQuote = "/dex-swap/quotes/"
    case trackTransactions = "/transactions/"
    case transactionParams = "/transactions/params"
    case transactions = "/transactions"
    case verifiedAssets = "/verified-assets/"
    case waitForBlock = "/status/wait-for-block-after/%@"
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
