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
//  RekeyConfirmationViewModel.swift

import Foundation
import UIKit

final class RekeyConfirmationViewModel {
    private(set) var oldImage: UIImage?
    private(set) var oldTransitionTitle: String?
    private(set) var oldTransitionValue: String?
    private(set) var newTransitionTitle: String?
    private(set) var newTransitionValue: String?
    private(set) var newLedgerImage: UIImage?
    private(set) var feeValue: String?
    
    init(
        account: Account,
        ledgerName: String?,
        newAuthAddress: String
    ) {
        bindOldImage(account)
        bindOldTransitionTitle(account)
        bindOldTransitionValue(account)
        bindNewTransitionTitle(ledgerName)
        bindNewTransitionValue(
            ledgerName: ledgerName,
            newAuthAddress: newAuthAddress
        )
        bindNewLedgerImage(account)
        bindFeeValue()
    }
}

extension RekeyConfirmationViewModel {
    private func bindOldImage(_ account: Account) {
        if account.requiresLedgerConnection() {
            oldImage = "ledger-gray".uiImage
        } else {
            oldImage = "standard-gray".uiImage
        }
    }

    private func bindOldTransitionTitle(_ account: Account) {
        if account.requiresLedgerConnection() {
            oldTransitionTitle = "ledger-rekey-ledger-old".localized
        } else {
            oldTransitionTitle = "ledger-rekey-ledger-passphrase".localized
        }
    }

    private func bindOldTransitionValue(_ account: Account) {
        if account.requiresLedgerConnection() {
            if let ledgerName = account.currentLedgerDetail?.name {
                oldTransitionValue = ledgerName
            } else {
                oldTransitionValue = account.name
            }
        } else {
            oldTransitionValue = "*************"
        }
    }

    private func bindNewTransitionTitle(_ ledgerName: String?) {
        if ledgerName != nil {
            newTransitionTitle = "ledger-rekey-ledger-new".localized
            return
        }

        newTransitionTitle = "wallet-connect-transaction-title-auth-address".localized
    }

    private func bindNewTransitionValue(
        ledgerName: String?,
        newAuthAddress: String
    ) {
        newTransitionValue = ledgerName.unwrap(or: newAuthAddress.shortAddressDisplay)
    }

    private func bindNewLedgerImage(_ account: Account) {
        newLedgerImage = account.typeImage
    }

    private func bindFeeValue() {
        let fee = max(UInt64(minimumFee), 0)
        feeValue = "ledger-rekey-total-fee".localized(params: "\(fee.toAlgos)")
    }
}
