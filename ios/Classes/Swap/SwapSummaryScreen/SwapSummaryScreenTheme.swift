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

//   SwapSummaryScreenTheme.swift

import MacaroonUIKit
import UIKit

struct SwapSummaryScreenTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let summaryItem: SwapSummaryItemViewTheme
    let topSpacing: LayoutMetric
    let horizontalInset: LayoutMetric
    let itemVerticalSpacing: LayoutMetric
    let summaryStatus: SwapSummaryStatusViewTheme
    let summaryAccount: SwapSummaryAccountViewTheme
    let separator: Separator
    let separatorSpacing: LayoutMetric
    let minimumBottomSpacing: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.summaryItem = SwapSummaryItemViewTheme()
        self.topSpacing = 52
        self.horizontalInset = 24
        self.itemVerticalSpacing = 24
        self.summaryStatus = SwapSummaryStatusViewTheme()
        self.summaryAccount = SwapSummaryAccountViewTheme()
        self.separator = Separator(
            color: Colors.Layer.grayLighter,
            size: 1,
            position: .bottom((horizontalInset, horizontalInset))
        )
        self.separatorSpacing = 28
        self.minimumBottomSpacing = 16
    }
}
