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

//   AssetQuickActionViewTheme.swift

import Foundation
import MacaroonUIKit

struct AssetQuickActionViewTheme: StyleSheet, LayoutSheet {
    let containerShadow: MacaroonUIKit.Shadow
    let topPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let bottomPadding: LayoutMetric

    let buttonContentInsets: LayoutPaddings
    let buttonMaxWidthRatio: LayoutMetric
    let buttonCorner: Corner

    let title: TextStyle
    let spacingBetweenTitleAndButton: LayoutMetric

    let accountTypeImageTopPadding: LayoutMetric
    let accountTypeImageSize: LayoutSize

    let accountName: TextStyle
    let spacingBetweenAccountTypeAndName: LayoutMetric

    init(_ family: LayoutFamily) {
        self.containerShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow4.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 14),
            radius: 60,
            cornerRadii: (0, 0),
            corners: [.topLeft, .topRight]
        )
        self.topPadding = 24
        self.horizontalPadding = 24
        self.bottomPadding = 20

        self.buttonContentInsets = (12, 20, 12, 20)
        self.buttonMaxWidthRatio = 0.6
        self.buttonCorner = Corner(radius: 4)

        self.title = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText())
        ]
        self.spacingBetweenTitleAndButton = 16

        self.accountTypeImageTopPadding = 4
        self.accountTypeImageSize = (20, 20)

        self.accountName = [
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineText())
        ]
        self.spacingBetweenAccountTypeAndName = 8
    }
}
