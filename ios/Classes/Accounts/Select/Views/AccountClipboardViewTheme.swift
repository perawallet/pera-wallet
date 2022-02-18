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
//   AccountClipboardViewTheme.swift


import Foundation
import MacaroonUIKit
import UIKit

struct AccountClipboardViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: UIColor
    let containerCorner: Corner
    let containerBorder: Border
    let containerFirstShadow: MacaroonUIKit.Shadow
    let containerSecondShadow: MacaroonUIKit.Shadow
    let containerThirdShadow: MacaroonUIKit.Shadow
    let titleLabel: TextStyle
    let addressLabel: TextStyle
    let copyIcon: ImageStyle

    let titleLabelTopInset: LayoutMetric
    let titleLabelLeadingInset: LayoutMetric
    let addressLabelTopOffset: LayoutMetric
    let copyIconBottomInset: LayoutMetric
    let copyIconTrailingInset: LayoutMetric
    let copyIconLeadingOffset: LayoutMetric
    let copyIconSize: LayoutSize

    init(_ family: LayoutFamily) {
        backgroundColor = AppColors.Shared.System.background.uiColor

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
        titleLabel = [
            .textColor(AppColors.Components.Text.grayLighter),
            .font(Fonts.DMSans.regular.make(13)),
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText())
        ]
        addressLabel = [
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMMono.regular.make(13)),
            .textAlignment(.left),
            .textOverflow(FittingText())
        ]
        copyIcon = [
            .image("icon-paste")
        ]

        titleLabelTopInset = 16
        titleLabelLeadingInset = 16
        addressLabelTopOffset = 4

        copyIconBottomInset = 24
        copyIconTrailingInset = 16
        copyIconLeadingOffset = 16
        copyIconSize = (24, 24)
    }
}
