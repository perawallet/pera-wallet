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
//   LedgerAccountCellViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct LedgerAccountCellViewTheme: StyleSheet, LayoutSheet {
    let nameLabel: TextStyle
    let assetInfoLabel: TextStyle
    let backgroundColor: Color
    let corner: Corner
    let firstShadow: MacaroonUIKit.Shadow
    let secondShadow: MacaroonUIKit.Shadow
    let thirdShadow: MacaroonUIKit.Shadow
    let infoButtonStyle: ButtonStyle

    let selectedStateBorder: Border
    let selectedStateCheckbox: ImageStyle
    let unselectedStateCheckbox: ImageStyle

    let horizontalInset: LayoutMetric
    let nameHorizontalOffset: LayoutMetric
    let checkboxIconSize: LayoutSize
    let infoIconSize: LayoutSize
    let verticalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = UIColor.clear
        self.nameLabel = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .font(Fonts.DMMono.regular.make(15)),
            .textColor(Colors.Text.main)
        ]
        self.assetInfoLabel = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .font(Fonts.DMSans.regular.make(13)),
            .textColor(Colors.Text.grayLighter)
        ]
        self.corner = Corner(radius: 4)
        self.firstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4
        )
        self.secondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4
        )
        self.thirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0
        )
        self.infoButtonStyle = [
            .backgroundImage([.normal("icon-info-gray")])
        ]
        self.selectedStateBorder = Border(color: Colors.Helpers.success.uiColor, width: 2)
        self.selectedStateCheckbox = [
            .image("icon-checkbox-selected")
        ]
        self.unselectedStateCheckbox = [
            .image("icon-checkbox-unselected")
        ]

        self.horizontalInset = 24
        self.nameHorizontalOffset = 20
        self.infoIconSize = (24, 24)
        self.checkboxIconSize = (20, 20)
        self.verticalInset = 16
    }
}
