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
//   ListItemButtonTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ListItemButtonTheme:
    StyleSheet,
    LayoutSheet {
    var icon: ImageStyle
    var iconContentEdgeInsets: LayoutOffset
    var iconAlignment: ListItemButton.IconViewAlignment
    var badge: ViewStyle
    var badgeSize: LayoutSize
    var badgeCorner: Corner
    var badgeContentEdgeInsets: NSDirectionalEdgeInsets
    var contentMinHeight: LayoutMetric?
    var contentVerticalPaddings: LayoutVerticalPaddings
    var title: TextStyle
    var subtitle: TextStyle
    var spacingBetweenTitleAndSubtitle: LayoutMetric
    var accessory: ImageStyle
    var accessoryContentEdgeInsets: LayoutOffset
    
    init(
        _ family: LayoutFamily
    ) {
        self.icon = [
            .contentMode(.left),
            .isInteractable(false),
            .tintColor(Colors.Text.main)
        ]
        self.iconContentEdgeInsets = (20, 0)
        self.iconAlignment = .centered
        self.badge = [
            .backgroundColor(Colors.Helpers.negative)
        ]
        self.badgeSize = (4, 4)
        self.badgeCorner = Corner(radius: badgeSize.h / 2)
        self.badgeContentEdgeInsets = NSDirectionalEdgeInsets(
            top: 6,
            leading: 0,
            bottom: 0,
            trailing: 19
        )
        self.contentMinHeight = 36
        self.contentVerticalPaddings = (12, 12)
        self.title = [
            .textColor(Colors.Text.main),
            .textOverflow(FittingText()),
            .isInteractable(false)
        ]
        self.subtitle = [
            .textColor(Colors.Text.gray)
        ]
        self.spacingBetweenTitleAndSubtitle = 2
        self.accessory = [
            .contentMode(.right),
            .isInteractable(false)
        ]
        self.accessoryContentEdgeInsets = (0, 0)
    }
}

extension ListItemButtonTheme {
    mutating func configureForTransactionOptionsView() {
        self.iconContentEdgeInsets = (12, 0)
        self.iconAlignment = .aligned(top: 0)
        self.contentVerticalPaddings = (8, 8)
        self.contentMinHeight = 40
        self.spacingBetweenTitleAndSubtitle = 0
        self.subtitle = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray)
        ]
    }

    mutating func configureForBuySellOptionsView() {
        self.iconContentEdgeInsets = (12, 0)
        self.iconAlignment = .aligned(top: 0)
        self.contentVerticalPaddings = (8, 8)
        self.contentMinHeight = 40
        self.spacingBetweenTitleAndSubtitle = 0
        self.subtitle = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray)
        ]
    }

    mutating func configureForQRScanOptionsView() {
        self.iconContentEdgeInsets = (16, 0)
        self.contentVerticalPaddings = (8, 8)
        self.contentMinHeight = 68
        self.spacingBetweenTitleAndSubtitle = 0
    }

    mutating func configureForAssetLearnMoreView() {
        self.icon = [
            .contentMode(.left),
            .isInteractable(false),
            .tintColor(Colors.Helpers.positive)
        ]
        self.iconContentEdgeInsets = (12, 0)
        self.contentMinHeight = 40
        self.spacingBetweenTitleAndSubtitle = 0
        self.subtitle = []
    }

    mutating func configureForAssetSocialMediaView() {
        self.iconContentEdgeInsets = (16, 0)
        self.contentVerticalPaddings = (0, 0)
        self.contentMinHeight = 44
        self.spacingBetweenTitleAndSubtitle = 0
    }
}
