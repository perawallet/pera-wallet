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

//   InsufficientAlgoBalanceScreenTheme.swift

import Foundation
import MacaroonUIKit

struct InsufficientAlgoBalanceScreenTheme:
    LayoutSheet,
    StyleSheet {
    let contextEdgeInsets: LayoutPaddings
    let image: ImageStyle
    let titleTopInset: LayoutMetric
    let title: TextStyle
    let spacingBetweenTitleAndBody: LayoutMetric
    let body: TextStyle
    let spacingBetweenBodyAndAlgoItem: LayoutMetric
    let algoItem: PrimaryListItemViewTheme
    let algoItemCorner: Corner
    let algoItemBorder: Border
    let algoItemContentPaddings: LayoutPaddings
    let action: ButtonStyle
    let actionEdgeInsets: LayoutPaddings
    let actionContentEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        self.contextEdgeInsets = (32, 24, 12, 24)
        self.image = [
            .contentMode(.scaleAspectFit)
        ]
        self.titleTopInset = 20
        self.title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Typography.bodyLargeMedium())
        ]
        self.spacingBetweenTitleAndBody = 12
        self.body = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
            .font(Typography.bodyRegular())
        ]
        self.spacingBetweenBodyAndAlgoItem = 32
        var algoItem = AssetListItemTheme()
        algoItem.primaryValue.textColor = Colors.Helpers.negative
        self.algoItem = algoItem
        self.algoItemCorner = Corner(radius: 4)
        self.algoItemBorder = Border(
            color: Colors.Helpers.negative.uiColor,
            width: 2
        )
        self.algoItemContentPaddings = (14, 20, 14, 20)
        self.action = [
            .font(Typography.bodyMedium()),
            .titleColor([ .normal(Colors.Button.Secondary.text) ]),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted"),
            ])
        ]
        self.actionEdgeInsets = (8, 24, 16, 24)
        self.actionContentEdgeInsets = (16, 24, 16, 24)
    }
}
