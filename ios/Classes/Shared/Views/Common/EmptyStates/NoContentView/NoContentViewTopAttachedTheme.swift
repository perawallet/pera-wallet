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

//   NoContentViewTopAttachedTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct NoContentViewTopAttachedTheme: NoContentViewTheme {
    let icon: ImageStyle
    let iconAlignment: ResultView.IconViewAlignment
    let spacingBetweenIconAndTitle: LayoutMetric
    let title: TextStyle
    let titleHorizontalMargins: LayoutHorizontalMargins
    let spacingBetweenTitleAndBody: LayoutMetric
    let body: TextStyle
    let bodyHorizontalMargins: LayoutHorizontalMargins
    let contentHorizontalPaddings: LayoutHorizontalPaddings
    let contentVerticalPaddings: LayoutVerticalPaddings
    let resultAlignment: NoContentView.ResultViewAlignment

    init(
        _ family: LayoutFamily
    ) {
        let resultTheme = ResultViewCommonTheme()

        self.icon = resultTheme.icon
        self.iconAlignment = resultTheme.iconAlignment
        self.spacingBetweenIconAndTitle = resultTheme.spacingBetweenIconAndTitle
        self.title = resultTheme.title
        self.titleHorizontalMargins = resultTheme.titleHorizontalMargins
        self.spacingBetweenTitleAndBody = resultTheme.spacingBetweenTitleAndBody
        self.body = resultTheme.body
        self.bodyHorizontalMargins = resultTheme.bodyHorizontalMargins
        self.contentHorizontalPaddings = (24, 24)
        self.contentVerticalPaddings = (16, 16)
        self.resultAlignment = .aligned(top: 16)
    }
}
