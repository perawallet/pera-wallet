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
//   AssetDetailInfoViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AssetDetailInfoViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let yourBalanceTitleLabel: TextStyle
    let balanceLabel: TextStyle
    let secondaryValueLabel: TextStyle
    let assetNameLabel: TextStyle
    let assetID: TextStyle
    let assetIDPadding: LayoutPaddings
    let verifiedImage: ImageStyle
    let separator: Separator

    let topPadding: LayoutMetric
    let separatorPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let balanceLabelTopPadding: LayoutMetric
    let bottomPadding: LayoutMetric
    let secondaryValueLabelTopPadding: LayoutMetric
    let verifiedImageHorizontalSpacing: LayoutMetric
    let spacingBetweenSeparatorAndAssetName: LayoutMetric
    let spacingBetweenAssetNameAndAssetID: LayoutMetric
    let spacingBetweenAssetIDAndSeparator: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.separator = Separator(color: AppColors.Shared.Layer.grayLighter, size: 1)
        self.yourBalanceTitleLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
        ]
        self.balanceLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMMono.regular.make(36)),
        ]
        self.secondaryValueLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMMono.regular.make(15)),
        ]
        self.assetNameLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.medium.make(15)),
        ]
        self.assetID = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(15))
        ]
        self.assetIDPadding = (8, 24, 8, 24)
        self.verifiedImage = [
            .image("icon-verified-shield")
        ]
        self.topPadding = 24
        self.separatorPadding = 32
        self.horizontalPadding = 24
        self.balanceLabelTopPadding = 8
        self.bottomPadding = 32
        self.secondaryValueLabelTopPadding = 4
        self.verifiedImageHorizontalSpacing = 8
        self.spacingBetweenSeparatorAndAssetName = 32
        self.spacingBetweenAssetNameAndAssetID = 4
        self.spacingBetweenAssetIDAndSeparator = 24
    }
}
