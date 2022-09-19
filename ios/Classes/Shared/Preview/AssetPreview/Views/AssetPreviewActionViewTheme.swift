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
    let assetAndCollectibles: TextStyle
    let secondaryImage: ImageStyle
    let secondaryAssetValue: TextStyle
    let actionButton: ButtonStyle

    let image: URLImageViewStyleLayoutSheet
    let imageSize: LayoutSize
    let horizontalPadding: LayoutMetric
    let verticalPadding: LayoutMetric
    let secondaryImageOffset: LayoutOffset

    init(actionButtonStyle: ButtonStyle, _ family: LayoutFamily = LayoutFamily.current) {
        self.accountName = [
            .textAlignment(.left),
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(15))
        ]
        self.assetAndCollectibles = [
            .textAlignment(.left),
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.grayLighter),
            .font(Fonts.DMSans.regular.make(13))
        ]
        self.secondaryImage = [
            .contentMode(.right)
        ]
        self.secondaryImageOffset = (8, 0)
        self.secondaryAssetValue = [
            .textAlignment(.right),
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.grayLighter),
            .font(Fonts.DMMono.regular.make(13))
        ]
        self.actionButton = actionButtonStyle

        self.image = URLImageViewAssetTheme()
        self.imageSize = (40, 40)
        self.horizontalPadding = 16
        self.verticalPadding = 16
    }

    init(_ family: LayoutFamily) {
        self.init(actionButtonStyle: [], family)
    }
}
