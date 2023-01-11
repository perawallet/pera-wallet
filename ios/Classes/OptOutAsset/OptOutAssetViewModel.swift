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

//   OptOutAssetViewModel.swift

import Foundation
import MacaroonUIKit

struct OptOutAssetViewModel: ViewModel {
    var title: String?
    var assetID: SecondaryListItemViewModel?
    var account: SecondaryListItemViewModel?
    var transactionFee: SecondaryListItemViewModel?
    var description: TextProvider?
    var approveAction: TextProvider?
    var closeAction: TextProvider?

    init(
        draft: OptOutAssetDraft
    ) {
        bindTitle(draft)
        bindAssetID(draft)
        bindAccount(draft)
        bindTransactionFee(draft)
        bindDescription(draft)
        bindApproveAction(draft)
        bindCloseAction(draft)
    }
}

extension OptOutAssetViewModel {
    private mutating func bindTitle(
        _ draft: OptOutAssetDraft
    ) {
        let asset = draft.asset

        if draft.isOptingOutCollectibleAsset {
            title =
            "collectible-detail-opt-out-alert-title"
                .localized(params: asset.naming.unitName ?? "title-unknown".localized)
        } else {
            title = "asset-remove-confirmation-title".localized
        }
    }

    private mutating func bindAssetID(
        _ draft: OptOutAssetDraft
    ) {
        assetID = AssetIDSecondaryListItemViewModel(
            assetID: draft.asset.id
        )
    }

    private mutating func bindAccount(
        _ draft: OptOutAssetDraft
    ) {
        account = AccountSecondaryListItemViewModel(
            account: draft.account
        )
    }

    private mutating func bindTransactionFee(
        _ draft: OptOutAssetDraft
    ) {
        transactionFee = TransactionFeeSecondaryListItemViewModel(
            fee: draft.transactionFee
        )
    }

    private mutating func bindDescription(
        _ draft: OptOutAssetDraft
    ) {
        let asset = draft.asset

        let assetName = asset.naming.unitName ?? "title-unknown".localized
        let accountName = draft.account.primaryDisplayName

        let aDescription: String

        if draft.isOptingOutCollectibleAsset {
            aDescription =
            "collectible-detail-opt-out-alert-message"
                .localized(params: assetName, accountName)
        } else {
            aDescription =
            "asset-remove-transaction-warning"
                .localized(params: assetName, accountName)
        }

        description =
        aDescription
            .bodyRegular()
    }

    private mutating func bindApproveAction(
        _ draft: OptOutAssetDraft
    ) {
        let aTitle: String

        if draft.isOptingOutCollectibleAsset {
            aTitle = "transaction-item-opt-out".localized
        } else {
            aTitle = "title-remove".localized
        }

        approveAction = aTitle.localized
    }

    private mutating func bindCloseAction(
        _ draft: OptOutAssetDraft
    ) {
        let aTitle: String

        if draft.isOptingOutCollectibleAsset {
            aTitle = "title-cancel".localized
        } else {
            aTitle = "title-keep".localized
        }

        closeAction = aTitle.localized
    }
}
