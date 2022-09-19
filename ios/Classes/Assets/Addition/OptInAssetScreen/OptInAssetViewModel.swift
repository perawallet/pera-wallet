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

//   OptInAssetViewModel.swift

import Foundation
import MacaroonUIKit

struct OptInAssetViewModel: ViewModel {
    var title: String?
    var assetID: SecondaryListItemViewModel?
    var account: SecondaryListItemViewModel?
    var transactionFee: SecondaryListItemViewModel?
    var description: TextProvider?
    var approveAction: TextProvider?
    var closeAction: TextProvider?

    init(
        draft: OptInAssetDraft
    ) {
        bindTitle(draft)
        bindAssetID(draft)
        bindAccount(draft)
        bindTransactionFee(draft)
        bindDescription(draft)
        bindApproveAction()
        bindCloseAction()
    }
}

extension OptInAssetViewModel {
    private mutating func bindTitle(
        _ draft: OptInAssetDraft
    ) {
        if draft.asset.isCollectible {
            title = "opt-in-title-adding-nft".localized
        } else {
            title = "asset-add-confirmation-title".localized
        }
    }

    private mutating func bindAssetID(
        _ draft: OptInAssetDraft
    ) {
        assetID = AssetIDSecondaryListItemViewModel(
            assetID: draft.asset.id
        )
    }

    private mutating func bindAccount(
        _ draft: OptInAssetDraft
    ) {
        account = AccountSecondaryListItemViewModel(
            account: draft.account
        )
    }

    private mutating func bindTransactionFee(
        _ draft: OptInAssetDraft
    ) {
        transactionFee = TransactionFeeSecondaryListItemViewModel(
            fee: draft.transactionFee
        )
    }

    private mutating func bindDescription(
        _ draft: OptInAssetDraft
    ) {
        let aDescription: String

        if draft.asset.isCollectible {
            aDescription = "opt-in-description-adding-nft".localized
        } else {
            aDescription = "asset-add-warning".localized
        }

        description = aDescription.bodyRegular()
    }

    private mutating func bindApproveAction() {
        approveAction = "title-approve".localized
    }

    private mutating func bindCloseAction() {
        closeAction = "title-close".localized
    }
}
