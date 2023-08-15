// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RekeyedAccountSelectionListAccountLoadingItemViewTheme.swift

import Foundation
import MacaroonUIKit

struct RekeyedAccountSelectionListAccountLoadingItemViewTheme:
    StyleSheet,
    LayoutSheet {
    var firstShadow: MacaroonUIKit.Shadow
    var secondShadow: MacaroonUIKit.Shadow
    var thirdShadow: MacaroonUIKit.Shadow
    var contextPaddings: LayoutPaddings
    var checkbox: ImageStyle
    var spacingBetweenCheckboxAndIcon: LayoutMetric
    var corner: Corner
    var iconSize: LayoutSize
    var iconCorner: Corner
    var spacingBetweenIconAndContent: LayoutMetric
    var titleSize: LayoutSize
    var spacingBetweenTitleAndSubtitle: LayoutMetric
    var subtitleSize: LayoutSize
    var spacingBetweenContentAndInfoAction: LayoutMetric
    var infoAction: ImageStyle

    init(_ family: LayoutFamily) {
        self.firstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            spread: 1,
            cornerRadii: (12, 12),
            corners: .allCorners
        )
        self.secondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: 0,
            cornerRadii: (12, 12),
            corners: .allCorners
        )
        self.thirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: -1,
            cornerRadii: (12, 12),
            corners: .allCorners
        )
        self.contextPaddings = (16, 16, 16, 16)
        self.checkbox = [ .image("icon-checkbox-unselected")]
        self.spacingBetweenCheckboxAndIcon = 16
        self.corner = Corner(radius: 4)
        self.iconSize = (40, 40)
        self.iconCorner = Corner(radius: iconSize.h / 2)
        self.spacingBetweenIconAndContent = 16
        self.titleSize = (94, 20)
        self.spacingBetweenTitleAndSubtitle = 8
        self.subtitleSize = (44, 16)
        self.spacingBetweenContentAndInfoAction = 16
        self.infoAction = [ .image("icon-info-gray") ]
    }
}
