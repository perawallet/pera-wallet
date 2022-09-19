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
//   PendingAssetPreviewViewTheme.swift

import MacaroonUIKit

struct PendingAssetPreviewViewTheme: StyleSheet, LayoutSheet {
    let primaryAssetTitle: TextStyle
    let secondaryAssetTitle: TextStyle
    let secondaryImage: ImageStyle
    let assetStatus: TextStyle

    let imageSize: LayoutSize
    let horizontalPadding: LayoutMetric
    let verticalPadding: LayoutMetric
    let secondaryImageOffset: LayoutOffset

    init(_ family: LayoutFamily) {
        self.primaryAssetTitle = [
            .textAlignment(.left),
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(15))
        ]
        self.secondaryAssetTitle = [
            .textAlignment(.left),
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.grayLighter),
            .font(Fonts.DMSans.regular.make(13))
        ]
        self.secondaryImage = [
            .contentMode(.right)
        ]
        self.secondaryImageOffset = (8, 0)
        self.assetStatus = [
            .textAlignment(.right),
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(15))
        ]

        self.imageSize = (40, 40)
        self.horizontalPadding = 16
        self.verticalPadding = 16
    }
}
