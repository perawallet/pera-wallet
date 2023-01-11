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
//   AccountPortfolioViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AccountPortfolioViewTheme:
    StyleSheet,
    LayoutSheet {
    let contentHorizontalPaddings: LayoutHorizontalPaddings
    let title: TextStyle
    let titleTopPadding: LayoutMetric
    let value: TextStyle
    let secondaryValue: TextStyle
    let spacingBetweenTitleAndValue: LayoutMetric
    let spacingBetweenSecondaryValueAndMinimumBalanceContent: LayoutMetric
    let minimumBalanceTitle: TextStyle
    let minimumBalanceTitleMinWidthRatio: LayoutMetric
    let spacingBetweenMinimumBalanceTitleAndMinimumBalanceValue: LayoutMetric
    let minimumBalanceValue: TextStyle
    let spacingBetweenMinimumBalanceValueAndMinimumBalanceInfoAction: LayoutMetric
    let minimumBalanceInfoAction: ButtonStyle

    init(
        _ family: LayoutFamily
    ) {
        self.contentHorizontalPaddings = (24, 24)
        self.title = [
            .textColor(Colors.Text.gray)
        ]
        self.titleTopPadding = 8
        self.value = [
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.center)
        ]
        self.secondaryValue = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.center)
        ]
        self.spacingBetweenTitleAndValue = 8
        self.spacingBetweenSecondaryValueAndMinimumBalanceContent = 12
        self.minimumBalanceTitle = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText())
        ]
        self.minimumBalanceTitleMinWidthRatio = 0.1
        self.spacingBetweenMinimumBalanceTitleAndMinimumBalanceValue = 4
        self.minimumBalanceValue = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText())
        ]
        self.spacingBetweenMinimumBalanceValueAndMinimumBalanceInfoAction = 8
        self.minimumBalanceInfoAction = [
            .icon([ .normal("icon-info-20") ])
        ]
    }
}
