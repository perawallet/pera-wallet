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
//   PinLimitViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct PinLimitViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let lockIcon: ImageStyle
    let title: TextStyle
    let subtitle: TextStyle
    let tryAgain: TextStyle
    let counter: TextStyle
    let resetButton: ButtonStyle
    let resetButtonContentEdgeInsets: LayoutPaddings
    let resetButtonCorner: Corner
    let separator: Separator
    let spacingBetweenSubtitleAndSeparator: LayoutMetric
    let titleLabelTopInset: LayoutMetric
    let subtitleLabelTopInset: LayoutMetric
    let tryAgainLabelTopInset: LayoutMetric
    let imageViewTopInset: LayoutMetric
    let counterTopInset: LayoutMetric
    let bottomPadding: LayoutMetric
    let horizontalPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.lockIcon = [
            .image("icon-lock")
        ]
        self.title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .text(Self.getTitle())
        ]
        self.subtitle = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
            .text(Self.getBody("pin-limit-too-many"))
        ]
        self.tryAgain = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
            .text(Self.getBody("pin-limit-try-again"))
        ]
        self.counter = [
            .textAlignment(.center),
            .textOverflow(SingleLineFittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMMono.regular.make(36)),
        ]
        self.resetButton = [
            .title("pin-limit-reset-all".localized),
            .titleColor([ .normal(Colors.Button.Secondary.text) ]),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(Colors.Button.Secondary.background)
        ]
        self.resetButtonContentEdgeInsets = (14, 0, 14, 0)
        self.resetButtonCorner = Corner(radius: 4)
        self.separator = Separator(color: Colors.Layer.grayLighter, size: 1)

        self.tryAgainLabelTopInset = 65
        self.titleLabelTopInset = 116
        self.subtitleLabelTopInset = 12
        self.imageViewTopInset = 104
        self.spacingBetweenSubtitleAndSeparator = -32
        self.bottomPadding = 16
        self.horizontalPadding = 24
        self.counterTopInset = 12
    }
}

extension PinLimitViewTheme {
    private static func getTitle() -> EditText {
        return .attributedString(
            "pin-limit-title"
                .localized
                .bodyLargeMedium(
                    alignment: .center
                )
        )
    }

    private static func getBody(_ text: String) -> EditText {
        return .attributedString(
            text
                .localized
                .bodyRegular(
                    alignment: .center
                )
        )
    }
}
