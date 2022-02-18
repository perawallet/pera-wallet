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
    let title: TextStyle
    let titleTopMargin: LayoutMetric
    let body: TextStyle
    let bodyTopMargin: LayoutMetric
    let contentHorizontalPaddings: LayoutHorizontalPaddings
    let contentVerticalPadding: LayoutMetric
    let actionContentEdgeInsets: LayoutPaddings
    let actionCornerRadius: LayoutMetric
    let actionTopMargin: LayoutMetric
    let action: ButtonStyle

    init(
        _ family: LayoutFamily
    ) {
        let resultTheme = ResultViewCommonTheme()

        self.icon = resultTheme.icon
        self.title = resultTheme.title
        self.titleTopMargin = resultTheme.titleTopMargin
        self.body = resultTheme.body
        self.bodyTopMargin = resultTheme.bodyTopMargin
        self.contentHorizontalPaddings = (24, 24)
        self.contentVerticalPadding = 16
        self.actionContentEdgeInsets = (14, 24, 14, 24)
        self.actionCornerRadius = 4
        self.actionTopMargin = 32
        self.action = [
            .titleColor(
                [.normal(AppColors.Components.Button.Primary.text)]
            ),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(AppColors.Components.Button.Primary.background)
        ]
    }
}
