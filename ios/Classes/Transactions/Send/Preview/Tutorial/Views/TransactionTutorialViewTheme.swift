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
//   TransactionTutorialViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct TransactionTutorialViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let image: ImageStyle
    let title: TextStyle
    let subtitle: TextStyle
    let tapToMore: TextStyle
    let separator: Separator
    let actionButton: ButtonStyle
    let actionButtonContentEdgeInsets: LayoutPaddings
    let actionButtonCorner: Corner
    let instuctionViewTheme: InstructionItemViewTheme

    let bottomInset: LayoutMetric
    let horizontalInset: LayoutMetric
    let topInset: LayoutMetric
    let descriptionTopInset: LayoutMetric
    let titleTopInset: LayoutMetric
    let buttonTopInset: LayoutMetric
    let firstInstructionTopPadding: LayoutMetric
    let instructionSpacing: LayoutMetric
    let tapMoreLabelTopPadding: LayoutMetric
    let spacingBetweenSecondInstructionViewAndSeparator: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.image = [
            .image("icon-info-green")
        ]
        self.title = [
            .textColor(Colors.Text.main),
            .textOverflow(FittingText()),
        ]
        self.subtitle = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText()),
        ]
        self.tapToMore = [
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(13)),
            .textAlignment(.center),
            .textOverflow(FittingText()),
        ]
        self.actionButton = [
            .title("title-i-understand".localized),
            .titleColor([ .normal(Colors.Button.Secondary.text) ]),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(Colors.Button.Secondary.background)
        ]
        self.instuctionViewTheme = InstructionItemViewTheme(family)
        self.actionButtonContentEdgeInsets = (14, 0, 14, 0)
        self.actionButtonCorner = Corner(radius: 4)
        self.separator = Separator(color: Colors.Layer.grayLighter, size: 1)

        self.buttonTopInset = 20
        self.horizontalInset = 24
        self.topInset = 32
        self.titleTopInset = 20
        self.descriptionTopInset = 12
        self.bottomInset = 16
        self.firstInstructionTopPadding = 32
        self.instructionSpacing = 28
        self.tapMoreLabelTopPadding = 61
        self.spacingBetweenSecondInstructionViewAndSeparator = -32
    }
}
