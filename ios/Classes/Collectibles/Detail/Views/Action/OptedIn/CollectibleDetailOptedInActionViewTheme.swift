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

//   CollectibleDetailOptedInActionViewTheme.swift

import MacaroonUIKit

struct CollectibleDetailOptedInActionViewTheme:
    StyleSheet,
    LayoutSheet {
    let title: TextStyle
    let subtitle: TextStyle
    let optOut: ButtonStyle
    let optedInTitle: TextStyle
    let separator: ViewStyle

    let topInset: LayoutMetric
    let subtitleTopOffset: LayoutMetric
    let buttonTopInset: LayoutMetric
    let buttonBottomInset: LayoutMetric
    let accountShareTopInset: LayoutMetric
    let optedInTitleHeight: LayoutMetric
    let accountShareHeight: LayoutMetric
    let accountShareBottomInset: LayoutMetric
    let separatorHorizontalInset: LayoutMetric
    let actionContentEdgeInsets: LayoutPaddings
    let actionCorner: Corner
    let buttonHeight: LayoutMetric
    let separatorHeight: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        title = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .textColor(Colors.Text.gray)
        ]
        subtitle = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .textColor(Colors.Text.main)
        ]
        optedInTitle = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .textColor(Colors.Text.main),
            .text(Self.getOptedInTitle("collectible-detail-opted-in"))
        ]

        actionContentEdgeInsets = (14, 0, 14, 0)
        actionCorner = Corner(radius: 4)

        optOut = [
            .title(Self.getActionTitle("collectible-detail-opt-out")),
            .titleColor(
                [ .normal(Colors.Button.Secondary.text)]
            ),
            .backgroundColor(Colors.Button.Secondary.background),
            .icon([.normal("icon-trash-24")])
        ]

        separator = [
            .backgroundColor(Colors.Layer.grayLighter)
        ]

        topInset = 24
        subtitleTopOffset = 4
        buttonTopInset = 28
        buttonBottomInset = 40
        optedInTitleHeight = 28
        accountShareHeight = 64
        accountShareTopInset = 16
        accountShareBottomInset = 28
        separatorHorizontalInset = -24
        buttonHeight = 52
        separatorHeight = 1
    }
}

extension CollectibleDetailOptedInActionViewTheme {
    private static func getOptedInTitle(
        _ aTitle: String
    ) -> EditText {
        return .attributedString(
            aTitle
                .localized
                .bodyLargeMedium()
        )
    }
    private static func getActionTitle(
        _ aTitle: String
    ) -> EditText {
        return .attributedString(
            aTitle
                .localized
                .bodyMedium()
        )
    }
}
