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
//   TransactionHistoryLoadingViewCommonTheme.swift

import Foundation
import MacaroonUIKit

struct TransactionHistoryLoadingViewCommonTheme: TransactionHistoryLoadingViewTheme {
    var titleViewCorner: LayoutMetric
    var titleViewSize: LayoutSize
    var titleMargin: LayoutMargins

    var sectionCorner: LayoutMetric
    var sectionSize: LayoutSize
    var sectionMargin: LayoutMargins

    var itemCorner: LayoutMetric
    var itemSize: LayoutSize
    var itemMargin: LayoutMargins

    init(
        _ family: LayoutFamily
    ) {

        self.titleViewCorner = 4
        self.titleMargin = (24, 24, .noMetric, .noMetric)
        self.titleViewSize = (138, 24)

        self.sectionCorner = 4
        self.sectionMargin = (32, 24, .noMetric, .noMetric)
        self.sectionSize = (60, 20)

        self.itemCorner = 4
        self.itemMargin = (32, 24, .noMetric, .noMetric)
        self.itemSize = (.noMetric, 72)
    }
}
