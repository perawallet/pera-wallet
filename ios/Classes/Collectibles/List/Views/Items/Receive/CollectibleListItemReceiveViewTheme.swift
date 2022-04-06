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
        containerBorder = Border(color: AppColors.SendTransaction.Shadow.first.uiColor, width: 1)
        
        containerFirstShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.first.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        containerSecondShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.second.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        containerThirdShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.third.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        icon = [
            .image("icon-plus-24")
        ]

        let font = Fonts.DMSans.medium.make(15)
        let lineHeightMultiplier = 1.23

        let titleText: EditText = .attributedString(
            "collectibles-receive-action"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.center)
                    ])
                ])
        )

        title = [
            .textColor(AppColors.Components.Text.main),
            .textOverflow(FittingText()),
            .text(titleText)
        ]
        
        titleTopPadding = 8

        contentEdgeInsets = (8, 8, 8, 8)
    }
}
