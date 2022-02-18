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
//   PortfolioValueViewTheme.swift

import MacaroonUIKit

struct PortfolioValueViewTheme: StyleSheet, LayoutSheet {
    let title: ButtonStyle
    let value: TextStyle

    let verticalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.title = [
            .font(Fonts.DMSans.regular.make(15)),
            .titleColor([.normal(AppColors.Components.Text.gray.uiColor)]),
            .tintColor(AppColors.Components.Text.gray.uiColor),
        ]
        self.value = [
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.regular.make(36)),
            .textColor(AppColors.Components.Text.main.uiColor)
        ]

        self.verticalInset = 8
    }
}
