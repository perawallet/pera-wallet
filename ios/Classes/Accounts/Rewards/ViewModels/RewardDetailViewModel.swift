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
    
    init(account: Account, calculatedRewards: Decimal) {
        bindTitle()
        bindRewardAmount(from: account, and: calculatedRewards)
        bindDescription()
        bindFAQLabel()
    }
}

extension RewardDetailViewModel {
    private mutating func bindTitle() {
        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18

        title = .attributedString(
            "rewards-title"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.left)
                    ])
                ])
        )
    }

    private mutating func bindRewardAmount(from account: Account, and calculatedRewards: Decimal) {
        guard let rewardAmount =
                (account.pendingRewards.toAlgos + calculatedRewards).toFullAlgosStringForLabel else {
                    return
                }
        let font = Fonts.DMMono.regular.make(19)
        let lineHeightMultiplier = 1.13

        self.amount = .attributedString(
            (rewardAmount)
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.left)
                    ])
                ])
        )
    }

    private mutating func bindDescription() {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        description = .attributedString(
            "rewards-detail-subtitle"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.left)
                    ])
                ])
        )
    }

    private mutating func bindFAQLabel() {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        let totalString = "total-rewards-faq-title"
        let FAQString = "total-rewards-faq"

        let attributedString =
        totalString
            .localized
            .attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byWordWrapping),
                    .lineHeightMultiple(lineHeightMultiplier),
                    .textAlignment(.left)
                ]),
            ])
            .appendAttributesToRange(
                [
                    .foregroundColor: AppColors.Components.Link.primary.uiColor,
                    .font: Fonts.DMSans.regular.make(15).uiFont,
                ],
                of: FAQString.localized
            )

        FAQLabel = .attributedString(
            attributedString
        )
    }
}
