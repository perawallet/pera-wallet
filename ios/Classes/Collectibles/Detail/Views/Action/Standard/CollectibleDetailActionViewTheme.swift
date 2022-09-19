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

//   CollectibleDetailActionViewTheme.swift

import MacaroonUIKit

struct CollectibleDetailActionViewTheme:
    StyleSheet,
    LayoutSheet {
    let title: TextStyle
    let subtitle: TextStyle
    let sendAction: ButtonStyle
    let shareAction: ButtonStyle
    let separator: ViewStyle

    let topInset: LayoutMetric
    let subtitleTopOffset: LayoutMetric
    let buttonTopOffset: LayoutMetric
    let buttonBottomInset: LayoutMetric
    let separatorHorizontalInset: LayoutMetric
    let actionContentEdgeInsets: LayoutPaddings
    let actionCorner: Corner
    
    let buttonHeight: LayoutMetric
    let buttonSpacing: LayoutMetric
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

        actionContentEdgeInsets = (14, 0, 14, 0)
        actionCorner = Corner(radius: 4)

        sendAction = [
            .title(Self.getActionTitle("title-send")),
            .titleColor(
                [ .normal(Colors.Button.Secondary.text)]
            ),
            .backgroundColor(Colors.Button.Secondary.background),
            .icon([.normal("icon-arrow-up")])
        ]

        shareAction = [
            .title(Self.getActionTitle("collectible-detail-share")),
            .titleColor(
                [ .normal(Colors.Button.Secondary.text) ]
            ),
            .backgroundColor(Colors.Button.Secondary.background),
            .icon([ .normal("icon-share-24") ])
        ]

        separator = [
            .backgroundColor(Colors.Layer.grayLighter)
        ]

        topInset = 16
        subtitleTopOffset = 4
        buttonTopOffset = 20
        buttonBottomInset = 32
        separatorHorizontalInset = -24
        buttonHeight = 52
        buttonSpacing = 16
        separatorHeight = 1
    }
}

extension CollectibleDetailActionViewTheme {
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
