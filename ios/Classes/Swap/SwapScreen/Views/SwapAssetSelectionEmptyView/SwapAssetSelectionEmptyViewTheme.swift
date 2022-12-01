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

//   SwapAssetSelectionEmptyViewTheme.swift

import MacaroonUIKit
import UIKit

struct SwapAssetSelectionEmptyViewTheme:
    StyleSheet,
    LayoutSheet {
    let title: TextStyle
    let spacingBetweenTitleAndIcon: LayoutMetric
    let icon: ImageStyle
    let emptyAsset: ButtonStyle
    let emptyAssetLeadingInset: LayoutMetric
    let buttonIconSpacing: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.title = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineFittingText())
        ]
        self.spacingBetweenTitleAndIcon = 16
        self.icon = [
            .image("icon-swap-empty")
        ]
        self.emptyAsset = [
            .font(Typography.bodyMedium()),
            .titleColor([.normal(Colors.Text.main)]),
            .title("swap-asset-choose-title".localized),
            .icon([.normal("icon-arrow-24")])
        ]
        self.emptyAssetLeadingInset = 16
        self.buttonIconSpacing = 8
    }
}
