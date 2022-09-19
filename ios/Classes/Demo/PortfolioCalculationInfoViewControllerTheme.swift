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
//   PortfolioCalculationInfoViewController+Theme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct PortfolioCalculationInfoViewControllerTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var contentTopPadding: LayoutMetric
    var contentHorizontalPaddings: LayoutHorizontalPaddings
    var error: ErrorViewTheme
    var info: PortfolioCalculationInfoViewTheme
    var spacingBetweenErrorAndInfo: LayoutMetric
    var footerVerticalPaddings: LayoutVerticalPaddings
    var linearGradientHeight: LayoutMetric
    
    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contentTopPadding = 32
        self.contentHorizontalPaddings = (24, 24)
        self.error = ErrorViewTheme(family)
        self.info = PortfolioCalculationInfoViewTheme(family)
        self.spacingBetweenErrorAndInfo = 28
        self.footerVerticalPaddings = (32, 16)
        let buttonHeight: LayoutMetric = 52
        let additionalLinearGradientHeightForButtonTop: LayoutMetric = 4
        self.linearGradientHeight =
        footerVerticalPaddings.bottom +
        additionalLinearGradientHeightForButtonTop +
        buttonHeight
    }
}
