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
//   WCConnectionAccountSelectionViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct WCConnectionAccountSelectionViewTheme: StyleSheet, LayoutSheet {
    let firstShadow: MacaroonUIKit.Shadow
    let secondShadow: MacaroonUIKit.Shadow
    let thirdShadow: MacaroonUIKit.Shadow
    let title: TextStyle
    let secondaryTitle: TextStyle
    let iconImage: ImageStyle
    let arrowImage: ImageStyle

    let horizontalInset: LayoutMetric
    let verticalInset: LayoutMetric
    let iconImageSize: LayoutSize
    let arrowIconSize: LayoutSize
    
    let iconVerticalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.firstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            spread: 1,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        self.secondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: 0,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        self.thirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: -1,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        self.title = [
            .isInteractable(false),
            .text("wallet-connect-session-select-account".localized),
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(Colors.Text.main)
        ]
        self.secondaryTitle = [
            .isInteractable(false),
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(Colors.Text.grayLighter),
            .font(Fonts.DMSans.regular.make(13))
        ]
        self.arrowImage = [
            .isInteractable(false),
            .image("icon-arrow-gray-24")
        ]
        self.iconImage = [
            .isInteractable(false),
            .image("standard-gray")
        ]
        self.verticalInset = 18
        self.horizontalInset = 16
        self.arrowIconSize = (24, 24)
        self.iconImageSize = (40, 40)
        self.iconVerticalInset = 18
    }
}
