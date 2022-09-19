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
    var title: TextStyle
    var titleTopPadding: LayoutMetric
    var value: TextStyle
    var secondaryValue: TextStyle
    var spacingBetweenTitleAndValue: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
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
        self.contentHorizontalPaddings = (24, 24)
    }
}
