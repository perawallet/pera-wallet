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
//  Account+Helpers.swift

import Foundation
import UIKit
import MagpieCore
import MacaroonUtils

extension Account {
    func mnemonics() -> [String] {
        return UIApplication.shared.appConfiguration?.session.mnemonics(forAccount: self.address) ?? []
    }
}

extension Account {
    func amount(for assetDetail: AssetDetail) -> Decimal? {
        guard let asset = assets?.first(where: { $0.id == assetDetail.id }) else {
            return nil
        }
        return asset.amount.assetAmount(fromFraction: assetDetail.fractionDecimals)
    }

    func amount(for assetInformation: AssetInformation) -> Decimal? {
        guard let asset = assets?.first(where: { $0.id == assetInformation.id }) else {
            return nil
        }
        return asset.amount.assetAmount(fromFraction: assetInformation.decimals)
    }

    func amountWithoutFraction(for assetDetail: AssetDetail) -> UInt64? {
        guard let asset = assets?.first(where: { $0.id == assetDetail.id }) else {
            return nil
        }
        return UInt64(asset.amount)
    }
    
    func amountDisplayWithFraction(for assetDetail: AssetDetail) -> String? {
        return amount(for: assetDetail)?.toExactFractionLabel(fraction: assetDetail.fractionDecimals)
    }

    func amountDisplayWithFraction(for assetInformation: AssetInformation) -> String? {
        return amount(for: assetInformation)?.toExactFractionLabel(fraction: assetInformation.decimals)
    }

    func amountNumberWithAutoFraction(for assetDetail: AssetInformation) -> String? {
        return amount(for: assetDetail)?.toNumberStringWithSeparatorForLabel(fraction: assetDetail.decimals)
    }

    func isSameAccount(with address: String) -> Bool {
        return self.address == address
    }
}

extension Account {
    func doesAccountHasParticipationKey() -> Bool {
        return !(participation == nil || participation?.voteParticipationKey == defaultParticipationKey)
    }

    func containsDifferentAssets(than account: Account) -> Bool {
        return assets != account.assets
    }

    func hasDifference(with account: Account) -> Bool {
        return !(
            address == account.address &&
            amount == account.amount &&
            rewards == account.rewards &&
            !hasDifferentAssets(than: account) &&
            !hasDifferentApps(than: account)
        )
    }

    func hasAnyAssets() -> Bool {
        return !assets.isNilOrEmpty
    }
    
    func hasDifferentAssets(than account: Account) -> Bool {
        return assets != account.assets || !compoundAssets.map { $0.detail }.containsSameElements(as: account.compoundAssets.map { $0.detail })
    }

    func hasDifferentApps(than account: Account) -> Bool {
        return createdApps?.count != account.createdApps?.count || appsLocalState?.count != account.appsLocalState?.count
    }

    var hasMinAmountFields: Bool {
        return hasAnyAssets() || isThereAnyCreatedApps || isThereAnyOptedApps || isThereSchemaValues || isThereAnyAppExtraPages
    }

   private var isThereAnyCreatedApps: Bool {
        return !createdApps.isNilOrEmpty
    }

    private var isThereAnyOptedApps: Bool {
        return !appsLocalState.isNilOrEmpty
    }

    private var isThereSchemaValues: Bool {
        guard let schema = appsTotalSchema else {
            return false
        }

        return schema.intValue.unwrap(or: 0) > 0 || schema.byteSliceCount.unwrap(or: 0) > 0
    }

    private var isThereAnyAppExtraPages: Bool {
        return appsTotalExtraPages.unwrap(or: 0) > 0
    }

    @discardableResult
    func removeAsset(_ id: Int64?) -> [CompoundAsset] {
        return compoundAssets.removeAll { compoundAsset  in
            compoundAsset.id == id
        }
    }
    
    func containsAsset(_ id: Int64) -> Bool {
        return compoundAssets.contains { compoundAsset -> Bool in
            compoundAsset.id == id
        }
    }

    func update(from localAccount: AccountInformation) {
        name = localAccount.name
        type = localAccount.type
        ledgerDetail = localAccount.ledgerDetail
        receivesNotification = localAccount.receivesNotification
        rekeyDetail = localAccount.rekeyDetail
        preferredOrder = localAccount.preferredOrder
        accountImage = localAccount.accountImage
    }
    
    func removeDeletedAssets() {
        assets = nonDeletedAssets()
    }
}

extension Account {
    var isCreated: Bool {
        return createdRound != nil
    }

    func hasAuthAccount() -> Bool {
        return authAddress != nil
    }
    
    func isWatchAccount() -> Bool {
        return type == .watch
    }
    
    func isLedger() -> Bool {
        if isWatchAccount() {
            return false
        }
        
        if let authAddress = authAddress {
            return address == authAddress
        }
        
        return type == .ledger
    }
    
    func isRekeyed() -> Bool {
        if isWatchAccount() {
            return false
        }
        
        if let authAddress = authAddress {
            return authAddress != address
        }
        
        return false
    }
    
    func requiresLedgerConnection() -> Bool {
        return isLedger() || isRekeyed()
    }
    
    func addRekeyDetail(_ ledgerDetail: LedgerDetail, for address: String) {
        if rekeyDetail != nil {
            self.rekeyDetail?[address] = ledgerDetail
        } else {
            self.rekeyDetail = [address: ledgerDetail]
        }
    }

    var currentLedgerDetail: LedgerDetail? {
        if let authAddress = authAddress {
            return rekeyDetail?[authAddress]
        }
        return ledgerDetail
    }

    func nonDeletedAssets() -> [Asset]? {
        return assets?.filter { !($0.isDeleted ?? true) }
    }
}

extension Account {
    func update(with account: Account) {
        amount = account.amount
        status = account.status
        rewards = account.rewards
        pendingRewards = account.pendingRewards
        participation = account.participation
        createdAssets = account.createdAssets
        assets = account.assets
        type = account.type
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
        createdApps = account.createdApps
        preferredOrder = account.preferredOrder
        accountImage = account.accountImage

        if let updatedName = account.name {
            name = updatedName
        }
    }
    
    func accountTypeImage() -> UIImage? {
        if isWatchAccount() {
            return img("icon-account-type-watch")
        } else if isRekeyed() {
            return img("icon-account-type-rekeyed")
        } else if isLedger() {
            return img("img-ledger-small")
        } else {
            return img("icon-account-type-standard")
        }
    }

    var image: UIImage? {
        guard let accountImage = accountImage else {
            return nil
        }

        return img("\(type.rawValue)-\(accountImage)")
    }
}
