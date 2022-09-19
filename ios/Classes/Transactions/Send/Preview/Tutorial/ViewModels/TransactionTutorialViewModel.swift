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
        title = .attributedString(
            "transaction-tutorial-title"
                .localized
                .bodyLargeMedium(
                    alignment: .center
                )
        )
    }

    private func bindSubtitle(from isInitialDisplay: Bool) {
        let subtitle: String
        if isInitialDisplay {
            subtitle = "transaction-tutorial-subtitle".localized
        } else {
            subtitle = "transaction-tutorial-subtitle-other".localized
        }

        self.subtitle = .attributedString(
            subtitle
                .bodyRegular(
                    alignment: .center
                )
        )
    }

    private func bindFirstTip() {
        firstTip = .attributedString(
            "transaction-tutorial-tip-first"
                .localized
                .footnoteRegular()
        )
    }

    private func bindSecondTip() {
        let text = "transaction-tutorial-tip-second".localized
        let highlightedText = "transaction-tutorial-tip-second-highlighted".localized

        let textAttributes = NSMutableAttributedString(
            attributedString: text.footnoteRegular()
        )

        let highlightedTextAttributes: TextAttributeGroup = [
            .textColor(Colors.Helpers.negative),
            .font(Fonts.DMSans.regular.make(13).uiFont)
        ]

        let highlightedTextRange = (textAttributes.string as NSString).range(of: highlightedText)

        textAttributes.addAttributes(
            highlightedTextAttributes.asSystemAttributes(),
            range: highlightedTextRange
        )

        secondTip = .attributedString(
            textAttributes
        )
    }

    private func bindTapToMoreText() {
        let text = "transaction-tutorial-tap-to-more".localized
        let highlightedText = "transaction-tutorial-tap-to-more-highlighted".localized

        let textAttributes = NSMutableAttributedString(
            attributedString: text.footnoteRegular()
        )

        let highlightedTextAttributes: TextAttributeGroup = [
            .textColor(Colors.Link.primary),
            .font(Fonts.DMSans.regular.make(13).uiFont)
        ]

        let highlightedTextRange = (textAttributes.string as NSString).range(of: highlightedText)

        textAttributes.addAttributes(
            highlightedTextAttributes.asSystemAttributes(),
            range: highlightedTextRange
        )

        tapToMoreText = .attributedString(
            textAttributes
        )
    }
}
