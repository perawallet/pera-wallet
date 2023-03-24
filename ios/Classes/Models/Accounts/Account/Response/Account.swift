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
//  Account.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class Account: ALGEntityModel {
    typealias StandardAssetIndexer = [AssetID: Int] /// asset id -> standard asset index
    typealias CollectibleAssetIndexer = [AssetID: Int] /// asset id -> collectible asset index
    
    let address: String
    var amountWithoutRewards: UInt64
    var rewardsBase: UInt64?
    var round: UInt64?
    var signatureType: SignatureType?
    var status: AccountStatus
    var rewards: UInt64?
    var pendingRewards: UInt64
    var participation: Participation?
    var createdAssets: [AssetDetail]?
    var assets: [ALGAsset]?
    var authAddress: String?
    var createdRound: UInt64?
    var closedRound: UInt64?
    var isDeleted: Bool?

    var appsLocalState: [ApplicationLocalState]?
    var appsTotalExtraPages: Int?
    var appsTotalSchema: ApplicationStateSchema?

    var totalCreatedApps: Int

    var name: String?
    var type: AccountInformation.AccountType = .standard
    var ledgerDetail: LedgerDetail?
    var receivesNotification: Bool
    var rekeyDetail: RekeyDetail?
    var preferredOrder: Int

    var algo: Algo
    private(set) var standardAssets: [StandardAsset]?
    private(set) var collectibleAssets: [CollectibleAsset]?

    var totalUSDValueOfAssets: Decimal? {
        return calculateTotalUSDValueOfAssets()
    }

    private var standardAssetsIndexer: StandardAssetIndexer = [:]
    private var collectibleAssetsIndexer: CollectibleAssetIndexer = [:]

    /// <note>
    /// They are deeply coupled to the standard/collectible assets so it should be updated whenever
    /// those properties change.
    private var standardAssetsTotalUSDValue: Decimal?
    private var collectibleAssetsTotalUSDValue: Decimal?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        address = apiModel.address
        amountWithoutRewards = apiModel.amountWithoutPendingRewards
        rewardsBase = apiModel.rewardBase
        round = apiModel.round
        signatureType = apiModel.sigType
        status = apiModel.status
        rewards = apiModel.rewards
        pendingRewards = apiModel.pendingRewards
        participation = apiModel.participation
        createdAssets = apiModel.createdAssets.unwrapMap(AssetDetail.init)
        assets = apiModel.assets
        authAddress = apiModel.authAddr
        createdRound = apiModel.createdAtRound
        closedRound = apiModel.closedAtRound
        isDeleted = apiModel.deleted
        appsLocalState = apiModel.appsLocalState
        appsTotalExtraPages = apiModel.appsTotalExtraPages
        appsTotalSchema = apiModel.appsTotalSchema
        receivesNotification = true
        preferredOrder = AccountInformation.invalidOrder
        totalCreatedApps = apiModel.totalCreatedApps
        algo = Algo(amount: apiModel.amount)
    }

    init(
        address: String,
        type: AccountInformation.AccountType,
        ledgerDetail: LedgerDetail? = nil,
        name: String? = nil,
        rekeyDetail: RekeyDetail? = nil,
        receivesNotification: Bool = true,
        preferredOrder: Int = -1,
        accountImage: String? = nil
    ) {
        self.address = address
        self.amountWithoutRewards = 0
        self.pendingRewards = 0
        self.status = .offline
        self.name = name
        self.type = type
        self.ledgerDetail = ledgerDetail
        self.receivesNotification = receivesNotification
        self.rekeyDetail = rekeyDetail
        self.preferredOrder = preferredOrder
        self.totalCreatedApps = 0
        self.algo = Algo(amount: 0)
    }
    
    init(
        localAccount: AccountInformation
    ) {
        self.address = localAccount.address
        self.amountWithoutRewards = 0
        self.pendingRewards = 0
        self.status = .offline
        self.name = localAccount.name
        self.type = localAccount.type
        self.ledgerDetail = localAccount.ledgerDetail
        self.receivesNotification = localAccount.receivesNotification
        self.rekeyDetail = localAccount.rekeyDetail
        self.preferredOrder = localAccount.preferredOrder
        self.totalCreatedApps = 0
        self.algo = Algo(amount: 0)
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.address = address
        apiModel.amount = algo.amount
        apiModel.amountWithoutPendingRewards = amountWithoutRewards
        apiModel.createdAtRound = rewardsBase
        apiModel.sigType = signatureType
        apiModel.status = status
        apiModel.pendingRewards = pendingRewards
        apiModel.participation = participation
        apiModel.createdAssets = createdAssets?.encode()
        apiModel.assets = assets
        apiModel.authAddr = authAddress
        apiModel.closedAtRound = closedRound
        apiModel.deleted = isDeleted
        apiModel.appsLocalState = appsLocalState
        apiModel.appsTotalExtraPages = appsTotalExtraPages
        apiModel.appsTotalSchema = appsTotalSchema
        apiModel.totalCreatedApps = totalCreatedApps
        return apiModel
    }

    subscript (assetId: AssetID) -> Asset? {
        if assetId == algo.id {
            return algo
        }
        
        if let index = standardAssetsIndexer[assetId] {
            return standardAssets?[safe: index]
        }

        let index = collectibleAssetsIndexer[assetId]
        return index.unwrap { collectibleAssets?[safe: $0] }
    }
}

extension Account {
    var primaryDisplayName: String {
        return name.unwrap(or: address.shortAddressDisplay)
    }

    var secondaryDisplayName: String? {
        let name = name
        let address = address
        let shortAddressDisplay = address.shortAddressDisplay

        if type == .standard,
           name == shortAddressDisplay {
            return nil
        }

        let subtitle: String?

        if (name != nil && name != shortAddressDisplay) {
            subtitle = shortAddressDisplay
        } else {
            subtitle = typeTitle
        }

        return subtitle
    }
}

extension Account {
    var allAssets: [Asset]? {
        if standardAssets == nil &&
           collectibleAssets == nil {
            return nil
        }

        let arr1 = standardAssets.someArray
        let arr2 = collectibleAssets.someArray
        return arr1 + arr2
    }

    func setAlgo(
        _ algo: Algo
    ) {
        self.algo = algo
    }

    /// <todo>
    /// We should remove this method, use the one adding one asset at a time. Then, we will decide the indexer data.
    func setStandardAssets(
        _ assets: [StandardAsset],
        _ indexer: StandardAssetIndexer
    ) {
        standardAssets = assets
        standardAssetsIndexer = indexer

        updateTotalUSDValueOfStandardAssets()
    }

    /// <todo>
    /// We should remove this method, use the one adding one asset at a time. Then, we will decide the indexer data.
    func setCollectibleAssets(
        _ assets: [CollectibleAsset],
        _ indexer: CollectibleAssetIndexer
    ) {
        collectibleAssets = assets
        collectibleAssetsIndexer = indexer

        updateTotalUSDValueOfCollectibleAssets()
    }

    func append(
        _ asset: StandardAsset
    ) {
        var newStandardAssets = standardAssets.someArray
        newStandardAssets.append(asset)

        standardAssets = newStandardAssets
        standardAssetsIndexer[asset.id] = newStandardAssets.lastIndex!

        updateTotalUSDValueOfStandardAssets(appending: asset)
    }

    func append(
        _ collectible: CollectibleAsset
    ) {
        collectible.optedInAddress = address

        var newCollectibleAssets = collectibleAssets.someArray
        newCollectibleAssets.append(collectible)

        collectibleAssets = newCollectibleAssets
        collectibleAssetsIndexer[collectible.id] = newCollectibleAssets.lastIndex!

        updateTotalUSDValueOfCollectibleAssets(appending: collectible)
    }
    
    func removeAllAssets() {
        standardAssets = nil
        collectibleAssets = []

        standardAssetsIndexer = [:]
        collectibleAssetsIndexer = [:]

        standardAssetsTotalUSDValue = nil
        collectibleAssetsTotalUSDValue = nil
    }
    
    func containsStandardAsset(
        _ id: AssetID
    ) -> Bool {
        let index = standardAssetsIndexer[id]
        return index.unwrap { standardAssets?[safe: $0] } != nil
    }

    func containsCollectibleAsset(
        _ id: AssetID
    ) -> Bool {
        let index = collectibleAssetsIndexer[id]
        return index.unwrap { collectibleAssets?[safe: $0] } != nil
    }

    func containsAsset(
        _ id: AssetID
    ) -> Bool {
        return containsStandardAsset(id) || containsCollectibleAsset(id)
    }
}

extension Account {
    private func updateTotalUSDValueOfStandardAssets() {
        standardAssetsTotalUSDValue = calculateTotalUSDValue(of: standardAssets)
    }

    private func updateTotalUSDValueOfStandardAssets(
        appending asset: StandardAsset
    ) {
        standardAssetsTotalUSDValue = calculateTotalUSDValue(
            of: standardAssetsTotalUSDValue,
            appending: asset
        )
    }

    private func updateTotalUSDValueOfCollectibleAssets() {
        collectibleAssetsTotalUSDValue = calculateTotalUSDValue(of: collectibleAssets)
    }

    private func updateTotalUSDValueOfCollectibleAssets(
        appending asset: CollectibleAsset
    ) {
        collectibleAssetsTotalUSDValue = calculateTotalUSDValue(
            of: collectibleAssetsTotalUSDValue,
            appending: asset
        )
    }

    private func calculateTotalUSDValueOfAssets() -> Decimal? {
        if standardAssetsTotalUSDValue == nil &&
           collectibleAssetsTotalUSDValue == nil {
            return nil
        }

        let value1 = standardAssetsTotalUSDValue ?? 0
        let value2 = collectibleAssetsTotalUSDValue ?? 0
        return value1 + value2
    }

    private func calculateTotalUSDValue(
        of assets: [Asset]?
    ) -> Decimal? {
        return assets?.reduce(0) {
            $0 + calculateTotalUSDValue(of: $1)
        }
    }

    private func calculateTotalUSDValue(
        of assetsTotalUSDValue: Decimal?,
        appending asset: Asset
    ) -> Decimal {
        let assetTotalUSDValue = calculateTotalUSDValue(of: asset)
        return (assetsTotalUSDValue ?? 0) + assetTotalUSDValue
    }

    private func calculateTotalUSDValue(
        of asset: Asset
    ) -> Decimal {
        return asset.totalUSDValue ?? 0
    }
}

extension Account {
    struct APIModel: ALGAPIModel {
        var address: String
        var amount: UInt64
        var status: AccountStatus
        var rewards:  UInt64?
        var amountWithoutPendingRewards: UInt64
        var pendingRewards: UInt64
        var rewardBase: UInt64?
        var participation: Participation?
        var createdAssets: [AssetDetail.APIModel]?
        var assets: [ALGAsset]?
        var sigType: SignatureType?
        var round: UInt64?
        var authAddr: String?
        var createdAtRound: UInt64?
        var closedAtRound: UInt64?
        var deleted: Bool?
        var appsLocalState: [ApplicationLocalState]?
        var appsTotalExtraPages: Int?
        var appsTotalSchema: ApplicationStateSchema?
        var createdApps: [AlgorandApplication]?
        var totalCreatedApps: Int

        init() {
            self.address = ""
            self.amount = 0
            self.status = .offline
            self.rewards = nil
            self.amountWithoutPendingRewards = 0
            self.pendingRewards = 0
            self.rewardBase = nil
            self.participation = nil
            self.createdAssets = nil
            self.assets = nil
            self.sigType = nil
            self.round = nil
            self.authAddr = nil
            self.createdAtRound = nil
            self.closedAtRound = nil
            self.deleted = nil
            self.appsLocalState = nil
            self.appsTotalExtraPages = nil
            self.appsTotalSchema = nil
            self.createdApps = nil
            self.totalCreatedApps = 0
        }

        private enum CodingKeys: String, CodingKey {
            case address
            case amount
            case status
            case rewards
            case amountWithoutPendingRewards = "amount-without-pending-rewards"
            case pendingRewards = "pending-rewards"
            case rewardBase = "reward-base"
            case participation
            case createdAssets = "created-assets"
            case assets
            case sigType = "sig-type"
            case round
            case authAddr = "auth-addr"
            case createdAtRound = "created-at-round"
            case closedAtRound = "closed-at-round"
            case deleted
            case appsLocalState = "apps-local-state"
            case appsTotalExtraPages = "apps-total-extra-pages"
            case appsTotalSchema = "apps-total-schema"
            case createdApps = "created-apps"
            case totalCreatedApps = "total-created-apps"
        }
    }
}

extension Account: Equatable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.address == rhs.address
    }
}

extension Account: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(address.hashValue)
    }
}

extension Array where Self.Element == CollectibleAsset {
    func sorted(
        _ algorithm: CollectibleSortingAlgorithm
    ) -> Self {
        return sorted(by: algorithm.getFormula)
    }
}

extension Account {
    /// <todo>
    /// Set the network in Account when it is fetched from the indexer, then we won't need to pass the network.
    func usdc(_ network: ALGAPI.Network) -> Asset? {
        let assetID = ALGAsset.usdcAssetID(network)
        return self[assetID]
    }

    func usdt(_ network: ALGAPI.Network) -> Asset? {
        guard let assetID = ALGAsset.usdtAssetID(network) else {
            return nil
        }

        return self[assetID]
    }
}
