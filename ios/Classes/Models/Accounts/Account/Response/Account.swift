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
    typealias CompoundAssetIndexer = [Int64: Int] /// asset id -> compound asset index
    
    let address: String
    var amount: UInt64
    var amountWithoutRewards: UInt64
    var rewardsBase: UInt64?
    var round: UInt64?
    var signatureType: SignatureType?
    var status: AccountStatus
    var rewards: UInt64?
    var pendingRewards: UInt64
    var participation: Participation?
    var createdAssets: [AssetDetail]?
    var assets: [Asset]?
    var authAddress: String?
    var createdRound: UInt64?
    var closedRound: UInt64?
    var isDeleted: Bool?

    var appsLocalState: [ApplicationLocalState]?
    var appsTotalExtraPages: Int?
    var appsTotalSchema: ApplicationStateSchema?
    var createdApps: [AlgorandApplication]?
    var name: String?
    var type: AccountType = .standard
    var ledgerDetail: LedgerDetail?
    var receivesNotification: Bool
    var rekeyDetail: RekeyDetail?
    var preferredOrder: Int
    var accountImage: String?
    
    var compoundAssets: [CompoundAsset] = []
    private(set) var compoundAssetsIndexer: CompoundAssetIndexer = [:]

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        address = apiModel.address
        amount = apiModel.amount
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
        createdApps = apiModel.createdApps
        receivesNotification = true
        preferredOrder = AccountInformation.invalidOrder
        accountImage = AccountImageType.getRandomImage(for: type).rawValue
    }

    init(
        address: String,
        type: AccountType,
        ledgerDetail: LedgerDetail? = nil,
        name: String? = nil,
        rekeyDetail: RekeyDetail? = nil,
        receivesNotification: Bool = true,
        preferredOrder: Int = -1,
        accountImage: String? = nil
    ) {
        self.address = address
        self.amount = 0
        self.amountWithoutRewards = 0
        self.pendingRewards = 0
        self.status = .offline
        self.name = name
        self.type = type
        self.ledgerDetail = ledgerDetail
        self.receivesNotification = receivesNotification
        self.rekeyDetail = rekeyDetail
        self.preferredOrder = preferredOrder
        self.accountImage = accountImage ?? AccountImageType.getRandomImage(for: type).rawValue
    }
    
    init(
        localAccount: AccountInformation
    ) {
        self.address = localAccount.address
        self.amount = 0
        self.amountWithoutRewards = 0
        self.pendingRewards = 0
        self.status = .offline
        self.name = localAccount.name
        self.type = localAccount.type
        self.ledgerDetail = localAccount.ledgerDetail
        self.receivesNotification = localAccount.receivesNotification
        self.rekeyDetail = localAccount.rekeyDetail
        self.preferredOrder = localAccount.preferredOrder
        self.accountImage = localAccount.accountImage
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.address = address
        apiModel.amount = amount
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
        apiModel.createdApps = createdApps
        return apiModel
    }
    
    subscript (assetId: Int64) -> CompoundAsset? {
        let index = compoundAssetsIndexer[assetId]
        return index.unwrap { compoundAssets[safe: $0] }
    }
}

extension Account {
    func setCompoundAssets(
        _ assets: [CompoundAsset],
        _ indexer: CompoundAssetIndexer
    ) {
        compoundAssets = assets
        compoundAssetsIndexer = indexer
    }
    
    func append(
        _ compoundAsset: CompoundAsset
    ) {
        compoundAssets.append(compoundAsset)
        compoundAssetsIndexer[compoundAsset.id] = compoundAssets.lastIndex!
    }
    
    func removeAllCompoundAssets() {
        compoundAssets = []
        compoundAssetsIndexer = [:]
    }
    
    func contains(
        _ assetDetail: AssetInformation
    ) -> Bool {
        return self[assetDetail.id] != nil
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
        var assets: [Asset]?
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
