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
    var filterViewHeight: LayoutMetric
    var filterViewMargin: LayoutHorizontalMargins

    var sectionCorner: LayoutMetric
    var sectionSize: LayoutSize
    var sectionMargin: LayoutMargins

    var sectionLineStyle: ViewStyle
    var sectionLinePaddings: LayoutHorizontalPaddings
    var sectionLineHeight: LayoutMetric

    var itemCorner: LayoutMetric
    var itemSize: LayoutSize
    var itemMargin: LayoutMargins
    var itemSeparator: Separator

    init(
        _ family: LayoutFamily
    ) {


        self.filterViewHeight = 40
        self.filterViewMargin = (-24, -24)

        self.sectionCorner = 4
        self.sectionMargin = (32, 24, .noMetric, .noMetric)
        self.sectionSize = (60, 20)

        self.sectionLineStyle = [
            .backgroundColor(Colors.Layer.grayLighter)
        ]
        self.sectionLinePaddings = (20, 20)
        self.sectionLineHeight = 1

        self.itemCorner = 4
        self.itemMargin = (32, 24, .noMetric, .noMetric)
        self.itemSize = (.noMetric, 72)
        self.itemSeparator = Separator(color: Colors.Layer.grayLighter)
    }
}
