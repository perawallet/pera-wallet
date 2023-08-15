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

//   StandardAccountInformationScreenTheme.swift

import Foundation
import MacaroonUIKit

struct StandardAccountInformationScreenTheme:
    LayoutSheet,
    StyleSheet {
    var contextEdgeInsets: LayoutPaddings
    var title: TextStyle
    var spacingBetweenTitleAndAccountItem: LayoutMetric
    var accountItemMinHeight: LayoutMetric
    var accountItemFirstShadow: MacaroonUIKit.Shadow
    var accountItemSecondShadow: MacaroonUIKit.Shadow
    var accountItemThirdShadow: MacaroonUIKit.Shadow
    var accountItem: AccountListItemWithActionViewTheme
    var spacingBetweenAccountItemAndAccountTypeInformation: LayoutMetric
    var accountTypeInformation: AccountTypeInformationViewTheme
    var spacingBetweenAccountTypeInformationAndOptions: LayoutMetric
    var options: AccountInformationOptionsViewTheme

    init(_ family: LayoutFamily) {
        self.contextEdgeInsets = (20, 24, 16, 24)
        self.title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Typography.bodyLargeMedium())
        ]
        self.spacingBetweenTitleAndAccountItem = 28
        self.accountItemMinHeight = 80
        self.accountItemFirstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            spread: 1,
            cornerRadii: (20, 20),
            corners: .allCorners
        )
        self.accountItemSecondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: 0,
            cornerRadii: (20, 20),
            corners: .allCorners
        )
        self.accountItemThirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: -1,
            cornerRadii: (20, 20),
            corners: .allCorners
        )
        self.accountItem = AccountListItemWithActionViewTheme(family)
        self.spacingBetweenAccountItemAndAccountTypeInformation = 28
        self.accountTypeInformation = AccountTypeInformationViewTheme(family)
        self.spacingBetweenAccountTypeInformationAndOptions = 16
        self.options = AccountInformationOptionsViewTheme(family)
    }
}
