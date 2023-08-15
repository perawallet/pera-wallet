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
}

extension Account {
    var isCreated: Bool {
        return createdRound != nil
    }
    
    var signerAddress: PublicKey {
        return authAddress ?? address
    }

    var isRekeyedToSelf: Bool {
        return authAddress == address
    }

    func hasAuthAccount() -> Bool {
        return authAddress != nil && !isRekeyedToSelf
    }
    
    func hasLedgerDetail() -> Bool {
        return ledgerDetail != nil
    }
    
    func requiresLedgerConnection() -> Bool {
        return authorization.isLedger || authorization.isRekeyedToLedger
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

    func isOptedIn(to asset: AssetID) -> Bool {
        return self[asset] != nil || asset == algo.id
    }

    func isOwner(of asset: AssetID) -> Bool {
        if let ownedAsset = self[asset] {
            return ownedAsset.amount > 0
        }

        return false
    }

    func isCreator(of asset: Asset) -> Bool {
        return self.address == asset.creator?.address
    }
}

extension Account {
    var typeTitle: String? {
        if authorization.isStandard {
            return nil
        }

        if authorization.isWatch {
            return "title-watch-account".localized
        }

        if authorization.isLedger {
            return "title-ledger-account".localized
        }

        if authorization.isRekeyed {
            return "title-rekeyed-account".localized
        }

        if authorization.isNoAuth {
            return "title-no-auth".localized
        }

        return nil
    }

    /// <note> `underlyingTypeImage` should be used when we want to display the underlying type instead of general types. For instance, the Standard to Ledger rekeyed account's general type is `standardToLedgerRekeyed`  but its underlying type is `standard`
    var underlyingTypeImage: UIImage {
        if authorization.isStandard ||
           authorization.isStandardToStandardRekeyed ||
           authorization.isStandardToLedgerRekeyed ||
           authorization.isStandardToNoAuthInLocalRekeyed {
            return "icon-standard-account".uiImage
        }

        if authorization.isLedger ||
           authorization.isLedgerToLedgerRekeyed ||
           authorization.isLedgerToStandardRekeyed ||
           authorization.isLedgerToNoAuthInLocalRekeyed {
            return "icon-ledger-account".uiImage
        }

        if authorization.isUnknown ||
           authorization.isUnknownToLedgerRekeyed ||
           authorization.isUnknownToStandardRekeyed ||
           authorization.isUnknownToNoAuthInLocalRekeyed {
            return "icon-unknown-account".uiImage
        }

        if authorization.isWatch {
            return "icon-watch-account".uiImage
        }

        return "icon-no-auth-account".uiImage
    }
    
    var typeImage: UIImage {
        if authorization.isStandard {
            return "icon-standard-account".uiImage
        }

        if authorization.isWatch {
            return "icon-watch-account".uiImage
        }

        if authorization.isLedger {
            return "icon-ledger-account".uiImage
        }

        if authorization.isRekeyedToStandard {
            return "icon-any-to-standard-rekeyed-account".uiImage
        }

        if authorization.isRekeyedToLedger {
            return "icon-any-to-ledger-rekeyed-account".uiImage
        }

        if authorization.isNoAuth {
            return "icon-no-auth-account".uiImage
        }

        return "icon-unknown-account".uiImage
    }
}
