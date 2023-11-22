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

//   WCSessionInfoViewTheme.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct WCSessionInfoViewTheme:
    LayoutSheet,
    StyleSheet {
    let firstShadow: MacaroonUIKit.Shadow
    let secondShadow: MacaroonUIKit.Shadow
    let thirdShadow: MacaroonUIKit.Shadow
    let contextEdgeInsets: LayoutPaddings
    let spacingBetweenItems: LayoutMetric
    let item: SecondaryListItemViewTheme
    let itemMinHeight: LayoutMetric

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
        self.contextEdgeInsets = (16, 16, 16, 16)
        self.spacingBetweenItems = 12
        self.item = WCSessionInfoItemTheme(family)
        self.itemMinHeight = 20
    }
}

struct WCSessionInfoItemTheme: SecondaryListItemViewTheme {
    let contentEdgeInsets: LayoutPaddings
    let title: TextStyle
    let titleMinWidthRatio: LayoutMetric
    let titleMaxWidthRatio: LayoutMetric
    let minimumSpacingBetweenTitleAndAccessory: LayoutMetric
    let accessory: SecondaryListItemValueViewTheme

    init(
        _ family: LayoutFamily
    ) {
        self.contentEdgeInsets = (0, 0, 0, 0)
        self.title = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.gray)
        ]
        self.titleMinWidthRatio = 0.2
        self.titleMaxWidthRatio = 0.45
        self.minimumSpacingBetweenTitleAndAccessory = 12
        var accessory = SecondaryListItemValueCommonViewTheme(
            isMultiline: false,
            isInteractable: true
        )
        accessory.iconLayoutOffset = (4, 0)
        self.accessory = accessory
    }
}
