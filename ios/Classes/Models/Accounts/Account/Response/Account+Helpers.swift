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
    func isSameAccount(with otherAcc: Account) -> Bool {
        return isSameAccount(with: otherAcc.address)
    }

    func isSameAccount(with address: String) -> Bool {
        return self.address == address
    }
}

extension Account {
    func hasParticipationKey() -> Bool {
        return !(participation == nil || participation?.voteParticipationKey == defaultParticipationKey)
    }

    func hasAnyAssets() -> Bool {
        return !assets.isNilOrEmpty
    }
    
    func hasDifferentAssets(than account: Account) -> Bool {
        return
            assets != account.assets ||
            !standardAssets.someArray.containsSameElements(as: account.standardAssets.someArray)
    }

    func hasDifferentApps(than account: Account) -> Bool {
        return totalCreatedApps != account.totalCreatedApps || appsLocalState?.count != account.appsLocalState?.count
    }

    var hasDifferentMinBalance: Bool {
        return hasAnyAssets() || isThereAnyCreatedApps || isThereAnyOptedApps || isThereSchemaValues || isThereAnyAppExtraPages
    }

   private var isThereAnyCreatedApps: Bool {
       return totalCreatedApps > 0
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

    func update(from localAccount: AccountInformation) {
        name = localAccount.name
        type = localAccount.type
        ledgerDetail = localAccount.ledgerDetail
        receivesNotification = localAccount.receivesNotification
        rekeyDetail = localAccount.rekeyDetail
        preferredOrder = localAccount.preferredOrder
    }
    
    func removeDeletedAssets() {
        assets = nonDeletedAssets()
    }
}

extension Account {
    var isCreated: Bool {
        return createdRound != nil
    }
    
    var signerAddress: PublicKey {
        return authAddress ?? address
    }

    func hasAuthAccount() -> Bool {
        return authAddress != nil
    }
    
    func hasLedgerDetail() -> Bool {
        return ledgerDetail != nil
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
        return isLedger() || isRekeyedToLedger()
    }
    
    func isRekeyedToLedger() -> Bool {
        if !isRekeyed() {
            return false
        }
        
        guard let authAddress else {
            return false
        }
        
        return rekeyDetail?[authAddress] != nil
    }
    
    /// <note>
    /// We cannot be sure whether an account is rekeyed to a Ledger device. It can be rekeyed to a standard account as well.
    /// If an account is rekeyed and we don't know the related rekey details, we can suspect that it might be rekeyed to a standard account
    /// or not recovered from the ledger device.
    func isRekeyedToAnyAccount() -> Bool {
        if !isRekeyed() {
            return false
        }
        
        return !isRekeyedToLedger()
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

    func nonDeletedAssets() -> [ALGAsset]? {
        return assets?.filter { !($0.isDeleted ?? true) }
    }

    /// <todo> This will be moved to a single place when the tickets on v5.4.2 is handled.
    func calculateMinBalance() -> UInt64 {
        let assetCount = (assets?.count ?? 0) + 1
        let createdAppAmount = minimumTransactionMicroAlgosLimit * UInt64(totalCreatedApps)
        let localStateAmount = minimumTransactionMicroAlgosLimit * UInt64(appsLocalState?.count ?? 0)
        let totalSchemaValueAmount = totalNumIntConstantForMinimumAmount * UInt64(appsTotalSchema?.intValue ?? 0)
        let byteSliceAmount = byteSliceConstantForMinimumAmount * UInt64(appsTotalSchema?.byteSliceCount ?? 0)
        let extraPagesAmount = minimumTransactionMicroAlgosLimit * UInt64(appsTotalExtraPages ?? 0)

        let applicationRelatedMinimumAmount =
            createdAppAmount +
            localStateAmount +
            totalSchemaValueAmount +
            byteSliceAmount +
            extraPagesAmount

        let minBalance =
            (minimumTransactionMicroAlgosLimit * UInt64(assetCount)) +
            applicationRelatedMinimumAmount

        return minBalance
    }
}

extension Account {
    func update(with account: Account) {
        algo.amount = account.algo.amount
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
        preferredOrder = account.preferredOrder

        if let updatedName = account.name {
            name = updatedName
        }
    }

    var typeTitle: String? {
        if isWatchAccount() {
            return "title-watch-account".localized
        }
        if isRekeyed() {
            return "title-rekeyed-account".localized
        }
        if isLedger() {
            return "title-ledger-account".localized
        }
        return nil
    }
    
    var typeImage: UIImage {
        if isWatchAccount() {
            return "icon-watch-account".uiImage
        }
        if isRekeyed() {
            return "icon-rekeyed-account".uiImage
        }
        if isLedger() {
            return "icon-ledger-account".uiImage
        }
        return "icon-standard-account".uiImage
    }

    func isOptedIn(to asset: AssetID) -> Bool {
        return self[asset] != nil || asset == algo.id
    }

    func isOwner(of asset: AssetID) -> Bool {
        if let ownedAsset = self[asset] {
            return ownedAsset.amount > 0
        }

        return false
    }
}
