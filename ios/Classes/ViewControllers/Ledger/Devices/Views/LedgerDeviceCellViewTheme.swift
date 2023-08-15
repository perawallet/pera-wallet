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
//   LedgerDeviceCellViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct LedgerDeviceCellViewTheme: StyleSheet, LayoutSheet {
    let title: TextStyle
    let backgroundColor: Color
    let ledgerImage: ImageStyle
    let arrowImage: ImageStyle
    let firstShadow: MacaroonUIKit.Shadow
    let secondShadow: MacaroonUIKit.Shadow
    let thirdShadow: MacaroonUIKit.Shadow

    let horizontalInset: LayoutMetric
    let ledgerIconSize: LayoutSize
    let arrowIconSize: LayoutSize

    init(_ family: LayoutFamily) {
        self.backgroundColor = UIColor.clear
        self.title = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main)
        ]
        self.arrowImage = [
            .image("icon-arrow-gray-24")
        ]
        self.ledgerImage = [
            .image("icon-pair-ledger-account")
        ]
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

        self.horizontalInset = 16
        self.arrowIconSize = (24, 24)
        self.ledgerIconSize = (40, 40)
    }
}
