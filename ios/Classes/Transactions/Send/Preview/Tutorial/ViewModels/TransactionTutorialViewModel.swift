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
//   TransactionTutorialViewModel.swift

import UIKit
import MacaroonUIKit

final class TransactionTutorialViewModel: ViewModel {
    private(set) var title: EditText?
    private(set) var subtitle: EditText?
    private(set) var firstTip: EditText?
    private(set) var secondTip: EditText?
    private(set) var tapToMoreText: EditText?

    init(isInitialDisplay: Bool) {
        bindTitle()
        bindSubtitle(from: isInitialDisplay)
        bindFirstTip()
        bindSecondTip()
        bindTapToMoreText()
    }
}

extension TransactionTutorialViewModel {
    private func bindTitle() {
        let font = Fonts.DMSans.medium.make(19)
        let lineHeightMultiplier = 1.13

        title = .attributedString(
            "transaction-tutorial-title"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .textAlignment(.center),
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }

    private func bindSubtitle(from isInitialDisplay: Bool) {
        let subtitle: String
        if isInitialDisplay {
            subtitle = "transaction-tutorial-subtitle".localized
        } else {
            subtitle = "transaction-tutorial-subtitle-other".localized
        }

        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        self.subtitle = .attributedString(
            subtitle
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .textAlignment(.center),
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ]),
                ])
        )
    }

    private func bindFirstTip() {
        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18

        firstTip = .attributedString(
            "transaction-tutorial-tip-first"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }

    private func bindSecondTip() {
        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18

        // <todo>: `appendAttributesToRange` range functionality should be added to Macaroon.
        let attributedString =
        "transaction-tutorial-tip-second"
            .localized
            .attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byWordWrapping),
                    .lineHeightMultiple(lineHeightMultiplier)
                ]),
            ])
            .appendAttributesToRange(
                [
                    .foregroundColor: AppColors.Shared.Helpers.negative.uiColor,
                    .font: Fonts.DMSans.regular.make(13).uiFont,
                ],
                of: "transaction-tutorial-tip-second-highlighted".localized
            )

        secondTip = .attributedString(
            attributedString
        )
    }

    private func bindTapToMoreText() {
        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18

        // <todo>:
        // `appendAttributesToRange` range functionality should be added to Macaroon.
        tapToMoreText = .attributedString(
            "transaction-tutorial-tap-to-more"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineHeightMultiple(lineHeightMultiplier)
                    ]),
                ])
                .appendAttributesToRange(
                    [
                        .foregroundColor: AppColors.Components.Link.primary.uiColor,
                        .font: Fonts.DMSans.regular.make(13).uiFont
                    ],
                    of: "transaction-tutorial-tap-to-more-highlighted".localized
                )
        )
    }
}
