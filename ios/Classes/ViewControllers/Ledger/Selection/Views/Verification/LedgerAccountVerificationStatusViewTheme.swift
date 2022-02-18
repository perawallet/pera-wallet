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
    let shadow: MacaroonUIKit.Shadow
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
            .textColor(AppColors.Shared.Helpers.negative)
        ]
        self.addressLabel = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .font(Fonts.DMMono.regular.make(13)),
            .textColor(AppColors.Components.Text.main)
        ]
        self.corner = Corner(radius: 4)
        self.shadow = MacaroonUIKit.Shadow(
            color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.08),
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: AppColors.Shared.System.background.uiColor
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
