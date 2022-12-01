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

//   ASADetailLoadingViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ASADetailLoadingViewTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var profile: ViewStyle
    var profileTopEdgeInset: LayoutMetric
    var profileHorizontalEdgeInsets: NSDirectionalHorizontalEdgeInsets
    var iconSize: LayoutSize
    var iconCorner: Corner
    var spacingBetweenIconAndTitle: LayoutMetric
    var titleSize: LayoutSize
    var spacingBetweenTitleAndPrimaryValue: LayoutMetric
    var primaryValueSize: LayoutSize
    var spacingBetweenPrimaryAndSecondaryValue: LayoutMetric
    var secondaryValueSize: LayoutSize
    var spacingBetweenProfileAndQuickActions: LayoutMetric
    var quickActions: ViewStyle
    var spacingBetweenQuickActions: LayoutMetric
    var sendActionIcon: Image
    var sendActionTitle: TextProvider
    var receiveActionIcon: Image
    var receiveActionTitle: TextProvider
    var quickActionWidth: LayoutMetric
    var spacingBetweenQuickActionIconAndTitle: LayoutMetric
    var spacingBetweenQuickActionsAndPageBar: LayoutMetric
    var pageBarStyle: PageBarStyleSheet
    var pageBarLayout: PageBarLayoutSheet
    var activityPageBarItem: PageBarButtonItem
    var activity: TransactionHistoryLoadingViewTheme
    var activityContentEdgeInsets: NSDirectionalEdgeInsets
    var aboutPageBarItem: PageBarButtonItem
    var about: ASAAboutLoadingViewTheme
    var corner: Corner

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.profile = [
            .backgroundColor(Colors.Helpers.heroBackground)
        ]
        self.profileTopEdgeInset = 50
        self.profileHorizontalEdgeInsets = .init(leading: 24, trailing: 24)
        self.iconSize = (40, 40)
        self.iconCorner = Corner(radius: iconSize.h / 2)
        self.spacingBetweenIconAndTitle = 20
        self.titleSize = (90, 20)
        self.spacingBetweenTitleAndPrimaryValue = 8
        self.primaryValueSize = (210, 36)
        self.spacingBetweenPrimaryAndSecondaryValue = 8
        self.secondaryValueSize = (40, 20)
        self.spacingBetweenProfileAndQuickActions = 48
        self.quickActions = [
            .backgroundColor(Colors.Helpers.heroBackground)
        ]
        self.spacingBetweenQuickActions = 16
        self.sendActionIcon = "send-icon"
        self.receiveActionIcon = "receive-icon"

        var quickActionTitleAttributes = Typography.footnoteRegularAttributes(
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        quickActionTitleAttributes.insert(.textColor(Colors.Text.main))

        self.sendActionTitle = "quick-actions-send-title"
            .localized
            .attributed(quickActionTitleAttributes)
        self.receiveActionTitle = "quick-actions-receive-title"
            .localized
            .attributed(quickActionTitleAttributes)

        self.quickActionWidth = 64
        self.spacingBetweenQuickActionIconAndTitle = 12
        self.spacingBetweenQuickActionsAndPageBar = 36
        self.pageBarStyle = PageBarCommonStyleSheet()
        self.pageBarLayout = PageBarCommonLayoutSheet()
        self.activityPageBarItem = PrimaryPageBarButtonItem(title: "activity".localized)
        self.activity = TransactionHistoryLoadingViewCommonTheme()
        self.activityContentEdgeInsets = .init(top: 36, leading: 24, bottom: 0, trailing: 24)
        self.aboutPageBarItem = PrimaryPageBarButtonItem(title: "about".localized)
        self.about = ASAAboutLoadingViewTheme()
        self.corner = Corner(radius: 4)
    }
}
