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
//   TransactionShadowButtonTheme.swift


import Foundation
import UIKit
import MacaroonUIKit

struct TransactionShadowButtonTheme: ButtonTheme {
    var corner: Corner
    let label: TextStyle
    let icon: ImageStyle
    let titleColorSet: StateColorGroup
    let backgroundColorSet: StateColorGroup
    let indicator: ImageStyle

    let contentEdgeInsets: LayoutPaddings
    var firstShadow: MacaroonUIKit.Shadow?
    var secondShadow: MacaroonUIKit.Shadow?
    var thirdShadow: MacaroonUIKit.Shadow?

    init(_ family: LayoutFamily) {
        self.label = [
            .isInteractable(false),
            .font(Fonts.DMSans.medium.make(13)),
            .textAlignment(.center),
            .textOverflow(SingleLineFittingText())
        ]
        self.titleColorSet = [
            .normal(Colors.Text.gray)
        ]
        self.backgroundColorSet = [
            .normal(Colors.Defaults.background)
        ]
        self.corner = Corner(radius: 4)
        self.icon = []
        self.indicator = [
            .image("button-loading-indicator"),
            .contentMode(.scaleAspectFill)
        ]
        self.contentEdgeInsets = (14, 0, 14, 0)
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
    }
}
