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
//  AssetActionConfirmationViewModel.swift

import UIKit
import MacaroonUIKit

final class AssetActionConfirmationViewModel: PairedViewModel {
    private(set) var title: String?
    private(set) var id: String?
    private(set) var transactionFee: String?
    private(set) var actionTitle: String?
    private(set) var cancelTitle: String?
    private(set) var detail: NSAttributedString?
    private(set) var assetDisplayViewModel: AssetDisplayViewModel?

    init(_ model: AssetAlertDraft) {
        bindTitle(model)
        bindID(model)
        bindTransactionFee(model)
        bindActionTitle(model)
        bindCancelTitle(model)
        bindDetail(model)
        bindAssetDisplayViewModel(model)
    }
}

extension AssetActionConfirmationViewModel {
    private func bindTitle(_ draft: AssetAlertDraft) {
        title = draft.title
    }

    private func bindID(_ draft: AssetAlertDraft) {
        id = "\(draft.assetId)"
    }
    
    private func bindTransactionFee(_ draft: AssetAlertDraft) {
        guard let fee = draft.transactionFee?.toAlgos else {
            return
        }
        
        transactionFee = fee.toAlgosStringForLabel
    }

    private func bindActionTitle(_ draft: AssetAlertDraft) {
        actionTitle = draft.actionTitle
    }

    private func bindCancelTitle(_ draft: AssetAlertDraft) {
        cancelTitle = draft.cancelTitle
    }

    private func bindDetail(_ draft: AssetAlertDraft) {
        guard let detailText = draft.detail else {
            return
        }

        let attributedDetailText = NSMutableAttributedString(attributedString: detailText.attributed([.lineSpacing(1.2)]))

        guard let asset = draft.asset,
              let unitName = asset.unitName,
              !unitName.isEmptyOrBlank else {
                  detail = attributedDetailText
                  return
              }

        let range = (detailText as NSString).range(of: unitName)
        attributedDetailText.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColors.Components.Link.icon.uiColor, range: range)
        attributedDetailText.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColors.Components.Link.icon.uiColor, range: range)
        detail = attributedDetailText
    }

    private func bindAssetDisplayViewModel(_ draft: AssetAlertDraft) {
        assetDisplayViewModel = AssetDisplayViewModel(draft.asset)
    }
}
