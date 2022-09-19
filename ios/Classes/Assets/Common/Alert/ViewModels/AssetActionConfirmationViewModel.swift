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

import MacaroonUIKit
import UIKit

final class AssetActionConfirmationViewModel: ViewModel {
    private(set) var title: NSAttributedString?
    private(set) var titleColor: Color?
    private(set) var name: PrimaryTitleViewModel?
    private(set) var id: String?
    private(set) var transactionFee: String?
    private(set) var actionTitle: String?
    private(set) var cancelTitle: String?
    private(set) var detail: NSAttributedString?

    init(
        _ model: AssetAlertDraft,
        currencyFormatter: CurrencyFormatter
    ) {
        bindTitle(model)
        bindTitleColor(model)
        bindName(model)
        bindID(model)
        bindTransactionFee(
            model,
            currencyFormatter: currencyFormatter
        )
        bindActionTitle(model)
        bindCancelTitle(model)
        bindDetail(model)
    }
}

extension AssetActionConfirmationViewModel {
    private func bindTitle(_ draft: AssetAlertDraft) {
        title = draft.title?.bodyMedium(alignment: .center)
    }

    private func bindTitleColor(_ draft: AssetAlertDraft) {
        if let asset = draft.asset,
            asset.verificationTier.isSuspicious {
            titleColor = Colors.Helpers.negative
        } else {
            titleColor = Colors.Text.main
        }
    }

    private func bindName(_ draft: AssetAlertDraft) {
        name = draft.asset.unwrap(OptInAssetNameViewModel.init)
    }

    private func bindID(_ draft: AssetAlertDraft) {
        id = "\(draft.assetId)"
    }
    
    private func bindTransactionFee(
        _ draft: AssetAlertDraft,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let fee = draft.transactionFee?.toAlgos else {
            return
        }

        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = AlgoLocalCurrency()

        transactionFee = currencyFormatter.format(fee)
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

        let attributedDetailText = NSMutableAttributedString(
            attributedString: detailText.footnoteMedium()
        )

        guard let asset = draft.asset,
              let unitName = asset.unitName,
              !unitName.isEmptyOrBlank else {
                  detail = attributedDetailText
                  return
              }

        let range = (detailText as NSString).range(of: unitName)
        attributedDetailText.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.Link.icon.uiColor, range: range)
        detail = attributedDetailText
    }
}
