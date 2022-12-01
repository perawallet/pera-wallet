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

//   NoContentWithActionViewIllustratedTheme.swift

import MacaroonUIKit

struct NoContentWithActionViewIllustratedTheme: NoContentViewWithActionTheme {
    let icon: ImageStyle
    let iconAlignment: ResultView.IconViewAlignment
    let spacingBetweenIconAndTitle: LayoutMetric
    let title: TextStyle
    let titleHorizontalMargins: LayoutHorizontalMargins
    let spacingBetweenTitleAndBody: LayoutMetric
    let body: TextStyle
    let bodyHorizontalMargins: LayoutHorizontalMargins
    var contentHorizontalPaddings: LayoutHorizontalPaddings
    var contentVerticalPaddings: LayoutVerticalPaddings
    let actionContentEdgeInsets: LayoutPaddings
    let actionCornerRadius: LayoutMetric
    let primaryActionTopMargin: LayoutMetric
    var primaryAction: ButtonStyle
    let actionAlignment: NoContentWithActionView.ActionViewAlignment
    let secondaryActionTopMargin: LayoutMetric
    var secondaryAction: ButtonStyle

    init(
        _ family: LayoutFamily
    ) {
        let resultTheme = ResultViewIllustratedTheme()

        icon = resultTheme.icon
        iconAlignment = resultTheme.iconAlignment
        spacingBetweenIconAndTitle = resultTheme.spacingBetweenIconAndTitle
        title = resultTheme.title
        titleHorizontalMargins = resultTheme.titleHorizontalMargins
        spacingBetweenTitleAndBody = resultTheme.spacingBetweenTitleAndBody
        body = resultTheme.body
        bodyHorizontalMargins = resultTheme.bodyHorizontalMargins
        contentHorizontalPaddings = (24, 24)
        contentVerticalPaddings = (16, 16)
        actionContentEdgeInsets = (14, 24, 14, 24)
        actionCornerRadius = 4
        primaryActionTopMargin = 52
        primaryAction = [
            .titleColor(
                [.normal(Colors.Button.Primary.text)]
            ),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(Colors.Button.Primary.background)
        ]
        secondaryActionTopMargin = 16
        secondaryAction = [
            .titleColor(
                [.normal(Colors.Button.Secondary.text)]
            ),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(Colors.Button.Secondary.background)
        ]
        actionAlignment = .aligned(left: 0, right: 0)
    }
}
