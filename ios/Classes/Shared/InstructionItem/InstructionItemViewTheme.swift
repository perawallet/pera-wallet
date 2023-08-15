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
//   InstructionItemViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct InstructionItemViewTheme:
    StyleSheet,
    LayoutSheet {
    var order: TextStyle
    var orderFirstShadow: MacaroonUIKit.Shadow
    var orderSecondShadow: MacaroonUIKit.Shadow
    var orderThirdShadow: MacaroonUIKit.Shadow
    var orderSize: LayoutSize
    var orderAlignment: OrderAlignment
    var spacingBetweenOrderAndContent: LayoutMetric
    var title: TextStyle
    var spacingBetweenTitleAndSubtitle: LayoutMetric
    var subtitle: TextStyle

    init(
        _ family: LayoutFamily
    ) {
        self.order = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText()),
        ]
        self.orderFirstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            spread: 1,
            cornerRadii: (20, 20),
            corners: .allCorners
        )
        self.orderSecondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: 0,
            cornerRadii: (20, 20),
            corners: .allCorners
        )
        self.orderThirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: -1,
            cornerRadii: (20, 20),
            corners: .allCorners
        )
        self.orderSize = (40, 40)
        self.orderAlignment = .center
        self.spacingBetweenOrderAndContent = 20
        self.title = [
            .textColor(Colors.Text.main),
            .textOverflow(FittingText()),
        ]
        self.spacingBetweenTitleAndSubtitle = 8
        self.subtitle = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText()),
        ]
    }
}

extension InstructionItemViewTheme {
    enum OrderAlignment {
        case top
        case center
    }
}
