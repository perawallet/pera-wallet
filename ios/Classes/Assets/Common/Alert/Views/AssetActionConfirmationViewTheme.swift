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
    let minimumHorizontalSpacing: LayoutMetric
    let backgroundColor: Color
    let mainButtonTheme: ButtonTheme
    let secondaryButtonTheme: ButtonTheme
    let titleLabel: TextStyle
    let description: TextStyle
    let assetCodeLabel: TextStyle
    let assetNameLabel: TextStyle
    let transactionFeeTitleLabel: TextStyle
    let transactionFeeAmountLabel: TextStyle
    let verifiedImage: ImageStyle
    let assetIDLabel: TextStyle
    let copyIDButton: ButtonStyle
    let separator: Separator

    let titleTopPadding: LayoutMetric
    let assetCodeLabelTopPadding: LayoutMetric
    let assetCodeLabelMinHeight: LayoutMetric
    let assetNameLabelTopPadding: LayoutMetric
    let assetNameLabelMinHeight: LayoutMetric
    let assetIDPaddings: LayoutPaddings
    let transactionTopPadding: LayoutMetric
    let transactionBottomPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let verticalInset: LayoutMetric
    let buttonInset: LayoutMetric
    let bottomInset: LayoutMetric
    let descriptionTopInset: LayoutMetric
    let separatorPadding: LayoutMetric
    let copyIDButtonEdgeInsets: LayoutPaddings
    let copyIDButtonHeight: LayoutMetric
    let copyIDButtonCorner: Corner

    init(_ family: LayoutFamily) {
        self.minimumHorizontalSpacing = 8
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
            .textOverflow(SingleLineFittingText())
        ]
        self.copyIDButton = [
            .backgroundColor(AppColors.Shared.Layer.grayLighter),
            .title("asset-copy-id".localized),
            .font(Fonts.DMSans.medium.make(13)),
            .titleColor([.normal(AppColors.Components.Text.main)])
        ]
        self.transactionFeeTitleLabel = [
            .text("collectible-approve-transaction-fee".localized),
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.left),
            .textOverflow(FittingText())
        ]
        self.transactionFeeAmountLabel = [
            .textColor(AppColors.Shared.Helpers.negative),
            .font(Fonts.DMSans.medium.make(15)),
            .textAlignment(.right),
            .textOverflow(SingleLineText())
        ]
        self.separator = Separator(color: AppColors.Shared.Layer.grayLighter, size: 1)
        self.separatorPadding = -20
        self.mainButtonTheme = ButtonPrimaryTheme()
        self.secondaryButtonTheme = ButtonSecondaryTheme()
        self.horizontalPadding = 24
        self.buttonInset = 16
        self.verticalInset = 36
        self.titleTopPadding = 22
        self.bottomInset = 16
        self.descriptionTopInset = 44
        self.assetCodeLabelTopPadding = 42
        self.assetCodeLabelMinHeight = 42
        self.assetNameLabelTopPadding = 4
        self.assetNameLabelMinHeight = 20
        self.assetIDPaddings = (40, 8, .noMetric, 105)
        self.transactionTopPadding = 48
        self.transactionBottomPadding = 32
        self.copyIDButtonEdgeInsets = (6, 12, 6, 12)
        self.copyIDButtonHeight = 32
        self.copyIDButtonCorner = Corner(radius: 16)
    }
}
