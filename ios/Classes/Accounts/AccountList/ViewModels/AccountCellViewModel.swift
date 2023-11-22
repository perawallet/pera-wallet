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
//  AccountCellViewModel.swift

import UIKit

final class AccountCellViewModel {
    private(set) var accountImageTypeImage: UIImage?
    private(set) var accountImageTypeBottomRightBadge: UIImage?
    private(set) var name: String?
    private(set) var detail: String?
    private(set) var attributedDetail: NSAttributedString?

    private let mode: AccountListViewController.Mode
    private let account: Account

    init(
        account: Account,
        mode: AccountListViewController.Mode,
        currencyFormatter: CurrencyFormatter
    ) {
        self.mode = mode
        self.account = account
        bindAccountImageTypeImage(account)
        bindName(account)
        bindDetail(
            account,
            for: mode,
            currencyFormatter: currencyFormatter
        )
    }
}

extension AccountCellViewModel {
    private func bindName(_ account: Account) {
        name = account.name ?? "title-unknown".localized
    }

    private func bindDetail(
        _ account: Account,
        for mode: AccountListViewController.Mode,
        currencyFormatter: CurrencyFormatter
    ) {
        switch mode {
        case let .contact(assetDetail):
            if let assetDetail = assetDetail {
                currencyFormatter.formattingContext = .listItem
                currencyFormatter.currency = nil

                let amount = assetDetail.amountWithFraction
                let amountText = currencyFormatter.format(amount)
                let amountAttributedText = amountText.someString.attributed(
                    [
                        .textColor(Colors.Text.main),
                        .font(Fonts.DMMono.regular.make(15).uiFont)
                    ]
                )
                let codeText = " (\(assetDetail.unitNameRepresentation))".attributed(
                    [
                        .textColor(Colors.Text.grayLighter),
                        .font(Fonts.DMSans.regular.make(13).uiFont)
                    ]
                )
                attributedDetail = amountAttributedText + codeText
            } else {
                currencyFormatter.formattingContext = .listItem
                currencyFormatter.currency = AlgoLocalCurrency()

                detail = currencyFormatter.format(account.algo.amount.toAlgos)
            }
        }
    }

    private func bindAccountImageTypeImage(_ account: Account) {
        accountImageTypeImage = account.typeImage

        bindAccountImageTypeBottomRightBadge(account)
    }

    private func bindAccountImageTypeBottomRightBadge(_ account: Account) {
        guard !account.isBackedUp else {
            accountImageTypeBottomRightBadge = nil
            return
        }

        accountImageTypeBottomRightBadge = "circle-badge-warning".uiImage
    }
}
