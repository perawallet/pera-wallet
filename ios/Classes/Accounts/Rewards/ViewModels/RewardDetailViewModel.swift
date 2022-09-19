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
//  RewardDetailViewModel.swift

import Foundation
import MacaroonUIKit

struct RewardDetailViewModel:
    ViewModel,
    Hashable {
    private(set) var title: EditText?
    private(set) var amount: EditText?
    private(set) var description: EditText?
    private(set) var FAQLabel: EditText?
    
    init(
        account: Account,
        currencyFormatter: CurrencyFormatter
    ) {
        bindTitle()
        bindRewardAmount(
            from: account,
            currencyFormatter: currencyFormatter
        )
        bindDescription()
        bindFAQLabel()
    }
}

extension RewardDetailViewModel {
    private mutating func bindTitle() {
        title = .attributedString(
            "rewards-title"
                .localized
                .footnoteRegular()
        )
    }

    private mutating func bindRewardAmount(
        from account: Account,
        currencyFormatter: CurrencyFormatter
    ) {
        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = AlgoLocalCurrency()

        let text = currencyFormatter.format(account.pendingRewards.toAlgos)
        let font = Fonts.DMMono.regular.make(19)
        let lineHeightMultiplier = 1.13

        self.amount = text.unwrap {
            .attributedString(
                $0.attributed(
                    [
                        .font(font),
                        .lineHeightMultiplier(lineHeightMultiplier, font),
                        .paragraph([
                            .lineHeightMultiple(lineHeightMultiplier),
                            .textAlignment(.left)
                        ])
                    ]
                )
            )
        }
    }

    private mutating func bindDescription() {
        description = .attributedString(
            "rewards-detail-subtitle"
                .localized
                .bodyRegular()
        )
    }

    private mutating func bindFAQLabel() {
        let title = "total-rewards-faq-title".localized
        let FAQ = "total-rewards-faq".localized

        let titleAttributes = NSMutableAttributedString(
            attributedString: title.bodyRegular()
        )

        let FAQAttributes: TextAttributeGroup = [
            .textColor(Colors.Link.primary.uiColor),
            .font(Fonts.DMSans.medium.make(15).uiFont)
        ]

        let FAQRange = (titleAttributes.string as NSString).range(of: FAQ)

        titleAttributes.addAttributes(
            FAQAttributes.asSystemAttributes(),
            range: FAQRange
        )

        FAQLabel = .attributedString(
            titleAttributes
        )
    }
}
