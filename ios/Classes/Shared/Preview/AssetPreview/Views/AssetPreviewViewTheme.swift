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
    let icon: URLImageViewStyleLayoutSheet
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
        icon = URLImageViewAssetTheme()
        contentMinWidthRatio = 0.25
        minSpacingBetweenContentAndSecondaryContent = 16
        verifiedIconContentEdgeInsets = (6, 0)
        verifiedIcon = [
            .contentMode(.right)
        ]
        title = [
            .textColor(Colors.Text.main),
        ]
        subtitle = [
            .textColor(Colors.Text.grayLighter),
        ]
        primaryAccessory = [
            .textColor(Colors.Text.main),
        ]
        secondaryAccessory = [
            .textColor(Colors.Text.grayLighter),
        ]

        imageSize = (40, 40)
        horizontalPadding = 16
    }
}
