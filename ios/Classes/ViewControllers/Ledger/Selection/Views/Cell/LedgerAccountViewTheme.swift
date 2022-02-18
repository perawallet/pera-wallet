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
    let shadow: MacaroonUIKit.Shadow
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
            .textColor(AppColors.Components.Text.main)
        ]
        self.assetInfoLabel = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .font(Fonts.DMSans.regular.make(13)),
            .textColor(AppColors.Components.Text.grayLighter)
        ]
        self.corner = Corner(radius: 4)
        self.shadow = MacaroonUIKit.Shadow(
            color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.08),
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: AppColors.Shared.System.background.uiColor
        )
        self.infoButtonStyle = [
            .backgroundImage([.normal("icon-info-gray")])
        ]
        self.selectedStateBorder = Border(color: AppColors.Shared.Global.turquoise600.uiColor, width: 2)
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
