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
//   AssetActionConfirmationViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AssetActionConfirmationViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let mainButtonTheme: ButtonTheme
    let secondaryButtonTheme: ButtonTheme
    let titleLabel: TextStyle
    let description: TextStyle
    let assetCodeLabel: TextStyle
    let assetNameLabel: TextStyle
    let verifiedImage: ImageStyle
    let assetIDLabel: TextStyle
    let copyIDButton: ButtonStyle
    let topSeparator: Separator
    let bottomSeparator: Separator

    let titleTopPadding: LayoutMetric
    let assetCodeLabelTopPadding: LayoutMetric
    let assetNameLabelTopPadding: LayoutMetric
    let assetIDPaddings: LayoutPaddings
    let horizontalPadding: LayoutMetric
    let verticalInset: LayoutMetric
    let buttonInset: LayoutMetric
    let bottomInset: LayoutMetric
    let descriptionTopInset: LayoutMetric
    let topSeparatorPadding: LayoutMetric
    let bottomSeparatorPadding: LayoutMetric
    let copyIDButtonSize: LayoutSize
    let copyIDButtonCorner: Corner

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.titleLabel = [
            .textAlignment(.center),
            .textOverflow(FittingText()),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.medium.make(15))
        ]
        self.description = [
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.left),
            .textOverflow(FittingText())
        ]
        self.verifiedImage = [
            .image("icon-verified-shield")
        ]
        self.assetCodeLabel = [
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.medium.make(32)),
            .textAlignment(.left),
            .textOverflow(FittingText())
        ]
        self.assetNameLabel = [
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.left),
            .textOverflow(FittingText())
        ]
        self.assetIDLabel = [
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.left),
            .textOverflow(FittingText())
        ]
        self.copyIDButton = [
            .backgroundColor(AppColors.Shared.Layer.grayLighter),
            .title("asset-copy-id".localized),
            .font(Fonts.DMSans.medium.make(13)),
            .titleColor([.normal(AppColors.Components.Text.main)])
        ]
        let separatorColor = AppColors.Shared.Layer.grayLighter
        let separatorHeight: LayoutMetric = 1
        self.topSeparatorPadding = -20
        self.bottomSeparatorPadding = -24
        self.topSeparator = Separator(color: separatorColor, size: separatorHeight)
        self.bottomSeparator = Separator(color: separatorColor, size: separatorHeight, position: .top((0, 0)))
        self.mainButtonTheme = ButtonPrimaryTheme()
        self.secondaryButtonTheme = ButtonSecondaryTheme()
        self.horizontalPadding = 24
        self.buttonInset = 16
        self.verticalInset = 36
        self.titleTopPadding = 22
        self.bottomInset = 16
        self.descriptionTopInset = 48
        self.assetCodeLabelTopPadding = 42
        self.assetNameLabelTopPadding = 4
        self.assetIDPaddings = (44, 8, .noMetric, 105)
        self.copyIDButtonSize = (73, 32)
        self.copyIDButtonCorner = Corner(radius: copyIDButtonSize.h / 2)
    }
}
