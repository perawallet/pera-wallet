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
//   NoContentWithActionViewCommonTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct NoContentWithActionViewCommonTheme: NoContentViewWithActionTheme {
    let icon: ImageStyle
    let iconSize: CGSize?
    let title: TextStyle
    let titleTopMargin: LayoutMetric
    let body: TextStyle
    let bodyTopMargin: LayoutMetric
    let contentHorizontalPaddings: LayoutHorizontalPaddings
    let contentVerticalPaddings: LayoutVerticalPaddings
    let actionContentEdgeInsets: LayoutPaddings
    let actionCornerRadius: LayoutMetric
    let primaryActionTopMargin: LayoutMetric
    let primaryAction: ButtonStyle
    let secondaryActionTopMargin: LayoutMetric
    let secondaryAction: ButtonStyle
    let actionAlignment: NoContentWithActionView.ActionViewAlignment

    init(
        _ family: LayoutFamily
    ) {
        let resultTheme = ResultViewCommonTheme()

        self.icon = resultTheme.icon
        self.iconSize = nil
        self.title = resultTheme.title
        self.titleTopMargin = resultTheme.titleTopMargin
        self.body = resultTheme.body
        self.bodyTopMargin = resultTheme.bodyTopMargin
        self.contentHorizontalPaddings = (24, 24)
        self.contentVerticalPaddings = (16, 16)
        self.actionContentEdgeInsets = (14, 24, 14, 24)
        self.actionCornerRadius = 4
        self.primaryActionTopMargin = 32
        self.primaryAction = [
            .titleColor(
                [.normal(Colors.Button.Primary.text)]
            ),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(Colors.Button.Primary.background)
        ]
        self.secondaryActionTopMargin = 16
        self.secondaryAction = [
            .titleColor(
                [.normal(Colors.Button.Secondary.text)]
            ),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(Colors.Button.Secondary.background)
        ]
        self.actionAlignment = .centered
    }
}
