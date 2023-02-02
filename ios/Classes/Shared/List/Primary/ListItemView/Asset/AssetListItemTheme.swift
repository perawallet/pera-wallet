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

//   AssetListItemTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AssetListItemTheme: PrimaryListItemViewTheme {
    let icon: URLImageViewStyleLayoutSheet
    let iconSize: LayoutSize
    let loadingIndicator: ImageStyle
    let loadingIndicatorSize: LayoutSize
    let contentHorizontalPadding: LayoutMetric
    let contentMinWidthRatio: LayoutMetric
    let title: PrimaryTitleViewTheme
    var primaryValue: TextStyle
    let secondaryValue: TextStyle
    let minSpacingBetweenTitleAndValue: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.icon = URLImageViewAssetTheme()
        self.iconSize = (40, 40)
        self.loadingIndicator = [
            .image("loading-indicator"),
            .contentMode(.scaleAspectFit)
        ]
        self.loadingIndicatorSize = (16, 16)
        self.contentHorizontalPadding = 16
        self.contentMinWidthRatio = 0.25
        self.title = AssetNameViewTheme()
        self.primaryValue = [
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineText())
        ]
        self.secondaryValue = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText())
        ]
        self.minSpacingBetweenTitleAndValue = 16
    }
}
