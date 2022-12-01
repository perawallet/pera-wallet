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
//   LedgerAccountVerificationStatusViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct LedgerAccountVerificationStatusViewTheme: StyleSheet, LayoutSheet {
    let statusLabel: TextStyle
    let addressLabel: TextStyle
    let corner: Corner
    let firstShadow: MacaroonUIKit.Shadow
    let secondShadow: MacaroonUIKit.Shadow
    let thirdShadow: MacaroonUIKit.Shadow
    let indicator: ImageStyle

    let horizontalInset: LayoutMetric
    let verticalStackViewSpacing: LayoutMetric
    let verticalInset: LayoutMetric
    let imageSize: LayoutSize

    init(_ family: LayoutFamily) {
        self.statusLabel = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(Colors.Helpers.negative)
        ]
        self.addressLabel = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .font(Fonts.DMMono.regular.make(13)),
            .textColor(Colors.Text.main)
        ]
        self.corner = Corner(radius: 4)
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
        self.indicator = [
            .image("red-loading-indicator"),
            .contentMode(.scaleAspectFill)
        ]

        self.horizontalInset = 24
        self.verticalInset = 16
        self.verticalStackViewSpacing = 4
        self.imageSize = (24, 24)
    }
}
