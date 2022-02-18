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
//   AssetPreviewActionViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AssetPreviewActionViewTheme: StyleSheet, LayoutSheet {
    let accountName: TextStyle
    let assetAndNFTs: TextStyle
    let secondaryAssetValue: TextStyle
    let actionButton: ButtonStyle

    let imageSize: LayoutSize
    let horizontalPadding: LayoutMetric
    let assetNameVerticalStackViewTrailingPadding: LayoutMetric
    let verticalPadding: LayoutMetric
    let secondaryImageLeadingPadding: LayoutMetric

    init(actionButtonStyle: ButtonStyle, _ family: LayoutFamily = LayoutFamily.current) {
        self.accountName = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.regular.make(15))
        ]
        self.assetAndNFTs = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.grayLighter),
            .font(Fonts.DMSans.regular.make(13))
        ]
        self.secondaryAssetValue = [
            .textAlignment(.right),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.grayLighter),
            .font(Fonts.DMMono.regular.make(13))
        ]
        self.actionButton = actionButtonStyle

        self.imageSize = (40, 40)
        self.horizontalPadding = 16
        self.secondaryImageLeadingPadding = 8
        self.verticalPadding = 16
        self.assetNameVerticalStackViewTrailingPadding = 80
    }

    init(_ family: LayoutFamily) {
        self.init(actionButtonStyle: [], family)
    }
}
