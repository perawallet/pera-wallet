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

//   AccountNotBackedUpWarningViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AccountNotBackedUpWarningViewTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let corner: Corner
    let contentPaddings: LayoutPaddings
    let title: TextStyle
    let spacingBetweenTitleAndSubtitle: LayoutMetric
    let subtitle: TextStyle
    let spacingBetweenContextAndImage: LayoutMetric
    let image: ImageStyle
    let imageTopMargin: LayoutMetric
    let spacingBetweenContextAndAction: LayoutMetric
    let action: ButtonStyle
    let actionCorner: Corner
    let actionEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Helpers.negative)
        ]
        self.corner = Corner(radius: 8)
        self.contentPaddings = (24, 24, 24, 20)
        self.title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Defaults.background.uiColor.withAlphaComponent(0.6))
        ]
        self.spacingBetweenTitleAndSubtitle = 8
        self.subtitle = [
            .textOverflow(FittingText()),
            .textColor(Colors.Defaults.background)
        ]
        self.spacingBetweenContextAndImage = 12
        self.image = [
            .contentMode(.scaleAspectFit)
        ]
        self.imageTopMargin = 8
        self.spacingBetweenContextAndAction = 12
        self.action = [
            .titleColor([.normal(Colors.Button.Primary.text)]),
            .backgroundColor(Colors.Defaults.background.uiColor.withAlphaComponent(0.12))
        ]
        self.actionCorner = Corner(radius: 4)
        self.actionEdgeInsets = (8, 16, 8, 16)
    }
}
