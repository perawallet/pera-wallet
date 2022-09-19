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

//   CollectibleListItemReceiveViewTheme.swift

import MacaroonUIKit

struct CollectibleListItemReceiveViewTheme:
    LayoutSheet,
    StyleSheet {
    let containerCorner: Corner
    let containerBorder: Border
    let containerFirstShadow: MacaroonUIKit.Shadow
    let containerSecondShadow: MacaroonUIKit.Shadow
    let containerThirdShadow: MacaroonUIKit.Shadow

    let icon: ImageStyle

    let title: TextStyle
    let titleTopPadding: LayoutMetric

    let contentEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        containerCorner = Corner(radius: 4)
        containerBorder = Border(color: Colors.Shadows.Cards.shadow1.uiColor, width: 1)
        
        containerFirstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        containerSecondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        containerThirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        icon = [
            .image("icon-plus-24")
        ]

        let titleText: EditText = .attributedString(
            "collectibles-receive-action"
                .localized
                .bodyMedium(
                    alignment: .center
                )
        )

        title = [
            .textColor(Colors.Text.main),
            .textOverflow(FittingText()),
            .text(titleText)
        ]
        
        titleTopPadding = 8

        contentEdgeInsets = (8, 8, 8, 8)
    }
}
