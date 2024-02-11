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

//   BuySellOptionsScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct BuySellOptionsScreenTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var contextPaddings: LayoutPaddings
    var option: ListItemButtonTheme
    var spacingBetweenOptions: LayoutMetric
    var buyContextHeader: TextStyle
    var buyOptionsNotAvailable: TextStyle
    var spacingBetweenBuyContextHeaderAndBuyContext: LayoutMetric
    var spacingBetweenBuyAndSellContext: LayoutMetric
    var sellContextHeader: TextStyle
    var spacingBetweenSellContextHeaderAndSellContext: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contextPaddings = (32, 20, 20, 20)
        var option = ListItemButtonTheme()
        option.configureForBuySellOptionsView()
        self.option = option
        self.spacingBetweenOptions = 20
        let buyContextHeaderText =
            "buy-sell-options-buy-header-title"
                .localized
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
        self.buyContextHeader = [
            .text(buyContextHeaderText),
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText()),
        ]
        let buyOptionsNotAvailableText =
            "buy-sell-options-buy-not-available-description"
                .localized
                .footnoteRegular(
                    alignment: .center,
                    lineBreakMode: .byTruncatingTail
                )
        self.buyOptionsNotAvailable = [
            .text(buyOptionsNotAvailableText),
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText()),
        ]
        self.spacingBetweenBuyAndSellContext = 40
        self.spacingBetweenBuyContextHeaderAndBuyContext = 12
        let sellContextHeaderText =
            "buy-sell-options-sell-header-title"
                .localized
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
        self.sellContextHeader = [
            .text(sellContextHeaderText),
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText()),
        ]
        self.spacingBetweenSellContextHeaderAndSellContext = 12
    }
}
