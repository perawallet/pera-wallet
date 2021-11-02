// Copyright 2019 Algorand, Inc.

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

class RekeyConfirmationViewModel {
    
    private(set) var assetText: String?
    private(set) var oldTransitionTitle: String?
    private(set) var oldTransitionValue: String?
    private(set) var newTransitionValue: String?
    private(set) var feeValue: String?
    
    init(account: Account, ledgerName: String?) {
        setAssetCount(for: account)
        setOldTransitionTitle(for: account)
        setOldTransitionValue(for: account)
        setNewTransitionValue(with: ledgerName)
        setFeeValue()
    }
    
    private func setAssetCount(for account: Account) {
        if account.assetDetails.count > 1 {
            assetText = "ledger-rekey-more-assets".localized(params: "\(account.assetDetails.count - 1)")
        }
    }
    
    private func setOldTransitionTitle(for account: Account) {
        if account.requiresLedgerConnection() {
            oldTransitionTitle = "ledger-rekey-ledger-old".localized
        } else {
            oldTransitionTitle = "ledger-rekey-ledger-passphrase".localized
        }
    }
    
    private func setOldTransitionValue(for account: Account) {
        if account.requiresLedgerConnection() {
            if let ledgerName = account.currentLedgerDetail?.name {
                oldTransitionValue = ledgerName
            } else {
                oldTransitionValue = account.name
            }
        } else {
            oldTransitionValue = "*********"
        }
    }
    
    private func setNewTransitionValue(with ledgerName: String?) {
        newTransitionValue = ledgerName
    }
    
    private func setFeeValue() {
        /// <todo> This calculation will be updated when its details are clear.
        let fee = max(UInt64(minimumFee), 0)
        feeValue = "ledger-rekey-total-fee".localized(params: "\(fee.toAlgos)")
    }
}

extension RekeyConfirmationViewModel {
    func configure(_ view: RekeyConfirmationView) {
        view.setTransitionOldTitleLabel(oldTransitionTitle)
        view.setTransitionOldValueLabel(oldTransitionValue)
        view.setTransitionNewValueLabel(newTransitionValue)
        view.setFeeAmount(feeValue)
    }
    
    func configure(_ view: RekeyConfirmationFooterSupplementaryView) {
        view.contextView.setMoreAssetsButtonTitle(assetText)
    }
}
