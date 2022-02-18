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
//   RewardInfoViewModel.swift

import UIKit
import MacaroonUIKit

struct RewardInfoViewModel: ViewModel, Hashable {
    private let account: Account
    private(set) var title: EditText?
    private(set) var rewardAmount: EditText?

    init(account: Account, calculatedRewards: Decimal) {
        self.account = account
        bindTitle()
        bindRewardAmount(from: account, and: calculatedRewards)
    }
}

extension RewardInfoViewModel {
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
                (account.pendingRewards.toAlgos + calculatedRewards).toExactFractionLabel(fraction: 6) else {
                    return
                }
        let font = Fonts.DMMono.regular.make(13)
        let lineHeightMultiplier = 1.13

        self.rewardAmount = .attributedString(
            (rewardAmount + " ALGO")
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
}
