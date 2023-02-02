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
//   HomeLoadingViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct HomeLoadingViewTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var contentEdgeInsets: LayoutPaddings
    var portfolioTitle: TextStyle
    var portfolioTitleTopPadding: LayoutMetric
    var portfolioInfoAction: ButtonStyle
    var spacingBetweenPortfolioTitleAndPortfolioInfoAction: LayoutMetric
    var primaryPortfolioValueSize: LayoutSize
    var spacingBetweenPortfolioTitleAndPrimaryPortfolioValue: LayoutMetric
    var secondaryPortfolioValueSize: LayoutSize
    var spacingBetweenPrimaryPortfolioValueAndSecondaryPortfolioValue: LayoutMetric
    var portfolioValueCorner: Corner
    var quickActions: HomeQuickActionsViewTheme
    var spacingBetweenQuickActionsAndSecondaryPortfolioValue: LayoutMetric
    var quickActionsBottomPadding: LayoutMetric
    var accountsHeader: ManagementItemViewTheme
    var spacingBetweenAccountsHeaderAndPortfolio: LayoutMetric
    var accountsContentEdgeInsets: NSDirectionalEdgeInsets
    var account: PreviewLoadingViewTheme
    var accountSeparator: Separator
    var accountHeight: LayoutMetric
    var numberOfAccounts: Int

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Helpers.heroBackground)
        ]
        self.contentEdgeInsets = (16, 24, 0, 24)
        self.portfolioTitle = [
            .text("portfolio-title".localized.bodyRegular()),
            .textColor(Colors.Text.gray)
        ]
        self.portfolioTitleTopPadding = 8
        self.portfolioInfoAction = [
            .icon([ .normal("icon-info-20".templateImage) ]),
            .tintColor(Colors.Text.grayLighter)
        ]
        self.spacingBetweenPortfolioTitleAndPortfolioInfoAction = 8
        self.primaryPortfolioValueSize = (181, 44)
        self.spacingBetweenPortfolioTitleAndPrimaryPortfolioValue = 8
        self.secondaryPortfolioValueSize = (97, 20)
        self.spacingBetweenPrimaryPortfolioValueAndSecondaryPortfolioValue = 12
        self.portfolioValueCorner = Corner(radius: 4)
        self.quickActions = HomeQuickActionsViewTheme(family)
        self.spacingBetweenQuickActionsAndSecondaryPortfolioValue = 48
        self.quickActionsBottomPadding = 36
        self.accountsHeader = ManagementItemViewTheme()
        self.spacingBetweenAccountsHeaderAndPortfolio = 36
        self.accountsContentEdgeInsets = .init(top: 8, leading: 0, bottom: 24, trailing: 0)
        self.account = PreviewLoadingViewCommonTheme()
        self.accountHeight = 76
        self.accountSeparator = Separator(
            color: Colors.Layer.grayLighter,
            size: 1,
            position: .bottom((56, 0))
        )
        self.numberOfAccounts = 6
    }
}
