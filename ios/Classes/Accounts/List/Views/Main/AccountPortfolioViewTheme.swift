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
    var value: TextStyle
    var spacingBetweenTitleAndValue: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.contentHorizontalPaddings = (24, 24)
        self.title = []
        self.value = [
            .textColor(AppColors.Components.Text.main.uiColor),
            .textOverflow(SingleLineFittingText())
        ]
        self.spacingBetweenTitleAndValue = 8
    }
}
