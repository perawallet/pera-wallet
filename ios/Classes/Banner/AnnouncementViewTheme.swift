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

//   AnnouncementViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol AnnouncementViewTheme: StyleSheet, LayoutSheet {
    var background: ViewStyle { get }
    var backgroundImage: ImageSource? { get }
    var corner: Corner { get }
    var stackViewEdgeInset: LayoutMargins { get }
    var stackViewLayoutMargins: LayoutMargins { get }
    var stackViewItemSpacing: LayoutMetric { get }
    var stackViewButtonSpacing: LayoutMetric { get }
    var title: TextStyle { get }
    var subtitle: TextStyle { get }
    var action: ButtonStyle { get }
    var actionEdgeInsets: LayoutPaddings { get }
    var actionHeight: LayoutMetric { get }
    var close: ButtonStyle { get }
    var closeMargins: LayoutMargins { get }
    var closeSize: LayoutSize { get }
}

struct GenericAnnouncementViewTheme: AnnouncementViewTheme {
    var background: ViewStyle
    var backgroundImage: ImageSource? = nil
    var corner: Corner
    var stackViewEdgeInset: LayoutMargins
    var stackViewLayoutMargins: LayoutMargins
    var stackViewItemSpacing: LayoutMetric
    var stackViewButtonSpacing: LayoutMetric
    var title: TextStyle
    var subtitle: TextStyle
    var action: ButtonStyle
    var actionEdgeInsets: LayoutPaddings
    var actionHeight: LayoutMetric
    var close: ButtonStyle
    var closeMargins: LayoutMargins
    var closeSize: LayoutSize
    
    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Banner.background)
        ]
        self.corner = Corner(radius: 4)
        self.stackViewEdgeInset = (24, 24, 28, 24)
        self.stackViewLayoutMargins = (0, 0, 0, 0)
        self.stackViewItemSpacing = 12
        self.stackViewButtonSpacing = 16
        self.title = [
            .font(Fonts.DMSans.medium.make(15)),
            .textOverflow(FittingText()),
            .textColor(Colors.Banner.text)
        ]
        self.subtitle = [
            .font(Fonts.DMSans.regular.make(13)),
            .textOverflow(FittingText()),
            .textColor(Colors.Banner.text)
        ]
        self.action = [
            .backgroundImage([.normal("banner-cta-background")]),
            .font(Fonts.DMSans.medium.make(13))
        ]
        self.actionEdgeInsets = (0, 16, 0, 16)
        self.actionHeight = 44
        self.close = [
            .backgroundImage([.normal("icon-generic-close-banner")])
        ]
        self.closeMargins = (8, .noMetric, .noMetric, 8)
        self.closeSize = (24, 24)
    }
}

struct GovernanceAnnouncementViewTheme: AnnouncementViewTheme {
    var background: ViewStyle
    var backgroundImage: ImageSource?
    var corner: Corner
    var stackViewEdgeInset: LayoutMargins
    var stackViewLayoutMargins: LayoutMargins
    var stackViewItemSpacing: LayoutMetric
    var stackViewButtonSpacing: LayoutMetric
    var title: TextStyle
    var subtitle: TextStyle
    var action: ButtonStyle
    var actionEdgeInsets: LayoutPaddings
    var actionHeight: LayoutMetric
    var close: ButtonStyle
    var closeMargins: LayoutMargins
    var closeSize: LayoutSize

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Wallet.wallet3)
        ]
        self.backgroundImage = AssetImageSource(asset: UIImage(named: "background-governance-image"))
        self.corner = Corner(radius: 4)
        self.stackViewEdgeInset = (24, 24, 28, 80)
        self.stackViewLayoutMargins = (0, 0, 0, 0)
        self.stackViewItemSpacing = 12
        self.stackViewButtonSpacing = 16
        self.title = [
            .font(Fonts.DMSans.medium.make(15)),
            .textOverflow(FittingText()),
            .textColor(Colors.Banner.text)
        ]
        self.subtitle = [
            .font(Fonts.DMSans.regular.make(13)),
            .textOverflow(FittingText()),
            .textColor(Colors.Banner.text)
        ]
        self.action = [
            .backgroundImage([.normal("banner-cta-background")]),
            .font(Fonts.DMSans.medium.make(13))
        ]
        self.actionEdgeInsets = (0, 16, 0, 16)
        self.actionHeight = 44
        self.close = [
            .backgroundImage([.normal("icon-governance-close-banner")])
        ]
        self.closeMargins = (8, .noMetric, .noMetric, 8)
        self.closeSize = (24, 24)
    }
}
