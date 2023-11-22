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
    var authorization: AccountAuthorization
    var isWatchAccount: Bool
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
    var ledgerDetail: LedgerDetail?
    var receivesNotification: Bool
    var rekeyDetail: RekeyDetail?
    var preferredOrder: Int
    var isBackedUp: Bool

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
        authorization = .unknown
        isWatchAccount = false
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
        isBackedUp = true
    }

    init(
        address: String,
        ledgerDetail: LedgerDetail? = nil,
        name: String? = nil,
        rekeyDetail: RekeyDetail? = nil,
        receivesNotification: Bool = true,
        preferredOrder: Int = -1,
        accountImage: String? = nil
    ) {
        self.address = address
        self.amountWithoutRewards = 0
        self.authorization = .unknown
        self.isWatchAccount = false
        self.pendingRewards = 0
        self.status = .offline
        self.name = name
        self.ledgerDetail = ledgerDetail
        self.receivesNotification = receivesNotification
        self.rekeyDetail = rekeyDetail
        self.preferredOrder = preferredOrder
        self.totalCreatedApps = 0
        self.algo = Algo(amount: 0)
        self.isBackedUp = true
    }
    
    init(
        localAccount: AccountInformation
    ) {
        self.address = localAccount.address
        self.amountWithoutRewards = 0
        self.authorization = localAccount.isWatchAccount ? .watch : .unknown
        self.pendingRewards = 0
        self.status = .offline
        self.name = localAccount.name
        self.isWatchAccount = localAccount.isWatchAccount
        self.ledgerDetail = localAccount.ledgerDetail
        self.receivesNotification = localAccount.receivesNotification
        self.rekeyDetail = localAccount.rekeyDetail
        self.preferredOrder = localAccount.preferredOrder
        self.totalCreatedApps = 0
        self.algo = Algo(amount: 0)
        self.isBackedUp = localAccount.isBackedUp
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

        if authorization.isStandard,
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

extension Account {
    func update(from localAccount: AccountInformation) {
        name = localAccount.name
        authorization = localAccount.isWatchAccount ? .watch : authorization
        isWatchAccount = localAccount.isWatchAccount
        ledgerDetail = localAccount.ledgerDetail
        receivesNotification = localAccount.receivesNotification
        rekeyDetail = localAccount.rekeyDetail
        preferredOrder = localAccount.preferredOrder
        isBackedUp = localAccount.isBackedUp
    }

    func update(with account: Account) {
        algo.amount = account.algo.amount
        status = account.status
        rewards = account.rewards
        pendingRewards = account.pendingRewards
        participation = account.participation
        createdAssets = account.createdAssets
        assets = account.assets
        authorization = account.authorization
        isWatchAccount = account.isWatchAccount
        ledgerDetail = account.ledgerDetail
        amountWithoutRewards = account.amountWithoutRewards
        rewardsBase = account.rewardsBase
        round = account.round
        signatureType = account.signatureType
        authAddress = account.authAddress
        rekeyDetail = account.rekeyDetail
        receivesNotification = account.receivesNotification
        createdRound = account.createdRound
        closedRound = account.closedRound
        isDeleted = account.isDeleted
        appsLocalState = account.appsLocalState
        appsTotalExtraPages = account.appsTotalExtraPages
        appsTotalSchema = account.appsTotalSchema
        preferredOrder = account.preferredOrder
        isBackedUp = account.isBackedUp

        if let updatedName = account.name {
            name = updatedName
        }
    }
}

enum AccountAuthorization: RawRepresentable {
    var rawValue: String {
        switch self {
        case .standard: return "standard"
        case .ledger: return "ledger"
        case .watch: return "watch"
        case .noAuthInLocal: return "noAuthInLocal"
        case .standardToLedgerRekeyed: return "standardToLedgerRekeyed"
        case .standardToStandardRekeyed: return "standardToStandardRekeyed"
        case .standardToNoAuthInLocalRekeyed: return "standardToNoAuthInLocalRekeyed"
        case .ledgerToLedgerRekeyed: return "ledgerToLedgerRekeyed"
        case .ledgerToStandardRekeyed: return "ledgerToStandardRekeyed"
        case .ledgerToNoAuthInLocalRekeyed: return "ledgerToNoAuthInLocalRekeyed"
        case .unknownToLedgerRekeyed: return "unknownToLedgerRekeyed"
        case .unknownToStandardRekeyed: return "unknownToStandardRekeyed"
        case .unknownToNoAuthInLocalRekeyed: return "unknownToNoAuthInLocalRekeyed"
        case .unknown: return "unknown"
        }
    }

    init?(rawValue: String) {
        switch rawValue {
        case Self.standard.rawValue: self = .standard
        case Self.ledger.rawValue: self = .ledger
        case Self.watch.rawValue: self = .watch
        case Self.standardToLedgerRekeyed.rawValue: self = .standardToLedgerRekeyed
        case Self.standardToStandardRekeyed.rawValue: self = .standardToStandardRekeyed
        case Self.standardToNoAuthInLocalRekeyed.rawValue: self = .standardToNoAuthInLocalRekeyed
        case Self.ledgerToLedgerRekeyed.rawValue: self = .ledgerToLedgerRekeyed
        case Self.ledgerToStandardRekeyed.rawValue: self = .ledgerToStandardRekeyed
        case Self.ledgerToNoAuthInLocalRekeyed.rawValue: self = .ledgerToNoAuthInLocalRekeyed
        case Self.unknownToLedgerRekeyed.rawValue: self = .unknownToLedgerRekeyed
        case Self.unknownToStandardRekeyed.rawValue: self = .unknownToStandardRekeyed
        case Self.unknownToNoAuthInLocalRekeyed.rawValue: self = .unknownToNoAuthInLocalRekeyed
        case Self.noAuthInLocal.rawValue: self = .noAuthInLocal
        default: self = .unknown
        }
    }

    case standard
    case ledger
    case watch
    case noAuthInLocal /// <note> Missing private data and not rekeyed

    case standardToLedgerRekeyed
    case standardToStandardRekeyed
    case standardToNoAuthInLocalRekeyed

    case ledgerToLedgerRekeyed
    case ledgerToStandardRekeyed
    case ledgerToNoAuthInLocalRekeyed

    case unknownToLedgerRekeyed
    case unknownToStandardRekeyed
    case unknownToNoAuthInLocalRekeyed

    case unknown /// <note> Undetermined or indeterminable authorization state.
}

extension AccountAuthorization {
    var isStandard: Bool {
        return self == .standard
    }

    var isLedger: Bool {
        return self == .ledger
    }

    var isWatch: Bool {
        return self == .watch
    }

    var isNoAuthInLocal: Bool {
        return self == .noAuthInLocal
    }

    var isUnknown: Bool {
        return self == .unknown
    }

    var isStandardToLedgerRekeyed: Bool {
        return self == .standardToLedgerRekeyed
    }

    var isStandardToStandardRekeyed: Bool {
        return self == .standardToStandardRekeyed
    }

    var isStandardToNoAuthInLocalRekeyed: Bool {
        return self == .standardToNoAuthInLocalRekeyed
    }

    var isLedgerToLedgerRekeyed: Bool {
        return self == .ledgerToLedgerRekeyed
    }

    var isLedgerToStandardRekeyed: Bool {
        return self == .ledgerToStandardRekeyed
    }

    var isLedgerToNoAuthInLocalRekeyed: Bool {
        return self == .ledgerToNoAuthInLocalRekeyed
    }

    var isUnknownToLedgerRekeyed: Bool {
        return self == .unknownToLedgerRekeyed
    }

    var isUnknownToStandardRekeyed: Bool {
        return self == .unknownToStandardRekeyed
    }

    var isUnknownToNoAuthInLocalRekeyed: Bool {
        return self == .unknownToNoAuthInLocalRekeyed
    }

    /// <note> Missing private data or rekeyed to account that is not in local
    var isNoAuth: Bool {
        return isNoAuthInLocal || isRekeyedToNoAuthInLocal
    }

    var isAuthorized: Bool {
        return !isWatch && !isNoAuth && !isUnknown
    }

    /// <note> `isRekeyedToNoAuthInLocal` is not included in this check.
    /// Rekeyed account authorization means, we've the auth account or auth ledger detail in the app, If you want to check auth address nullity, check auth address.
    var isRekeyed: Bool {
        return
            isStandardToLedgerRekeyed ||
            isStandardToStandardRekeyed ||
            isLedgerToLedgerRekeyed ||
            isLedgerToStandardRekeyed ||
            isUnknownToLedgerRekeyed ||
            isUnknownToStandardRekeyed
    }

    var isRekeyedToLedger: Bool {
        return
            isStandardToLedgerRekeyed ||
            isLedgerToLedgerRekeyed ||
            isUnknownToLedgerRekeyed
    }

    var isRekeyedToStandard: Bool {
        return
            isStandardToStandardRekeyed ||
            isLedgerToStandardRekeyed ||
            isUnknownToStandardRekeyed
    }

    var isRekeyedToNoAuthInLocal: Bool {
       return
            isStandardToNoAuthInLocalRekeyed ||
            isLedgerToNoAuthInLocalRekeyed ||
            isUnknownToNoAuthInLocalRekeyed
    }
}
