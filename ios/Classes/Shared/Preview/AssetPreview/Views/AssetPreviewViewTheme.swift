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
//   AssetPreviewViewTheme.swift

import MacaroonUIKit

struct AssetPreviewViewTheme:
    LayoutSheet,
    StyleSheet {
    let verifiedIcon: ImageStyle
    let title: TextStyle
    let subtitle: TextStyle
    var primaryAccessory: TextStyle
    var secondaryAccessory: TextStyle

    let contentMinWidthRatio: LayoutMetric
    let minSpacingBetweenContentAndSecondaryContent: LayoutMetric
    let verifiedIconContentEdgeInsets: LayoutOffset
    let imageSize: LayoutSize
    let horizontalPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.contentMinWidthRatio = 0.15
        self.minSpacingBetweenContentAndSecondaryContent = 8
        self.verifiedIconContentEdgeInsets = (8, 0)
        self.verifiedIcon = [
            .contentMode(.right)
        ]
        self.title = [
            .textOverflow(SingleLineText()),
            .textColor(AppColors.Components.Text.main),
            .textAlignment(.left)
        ]
        self.subtitle = [
            .textOverflow(SingleLineText()),
            .textColor(AppColors.Components.Text.grayLighter),
            .textAlignment(.left)
        ]
        self.primaryAccessory = [
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
            .textAlignment(.right)
        ]
        self.secondaryAccessory = [
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.grayLighter),
            .textAlignment(.right)
        ]

        self.imageSize = (40, 40)
        self.horizontalPadding = 16
    }
}

extension AssetPreviewViewTheme {
    mutating func configureForAssetPreviewAddition() {
        primaryAccessory = primaryAccessory.modify( [] )

        secondaryAccessory = secondaryAccessory.modify(
            [ .textOverflow(SingleLineFittingText()), .textColor(AppColors.Components.Text.gray) ]
        )
    }
}
