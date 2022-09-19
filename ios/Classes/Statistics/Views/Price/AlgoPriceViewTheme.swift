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
//   AlgoPriceViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AlgoPriceViewTheme:
    StyleSheet,
    LayoutSheet {
    var contentHorizontalPaddings: LayoutHorizontalPaddings
    var price: TextStyle
    var priceLoadingCorner: Corner
    var priceLoadingMinSize: LayoutSize
    var spacingBetweenPriceAndPriceAttribute: LayoutMetric
    var priceAttribute: AlgoPriceAttributeViewTheme
    var priceAttributeMinSize: LayoutSize
    var spacingBetweenPriceAttributeAndChart: LayoutMetric
    var chartHeight: LayoutMetric
    
    init(
        _ family: LayoutFamily
    ) {
        self.contentHorizontalPaddings = (24, 24)
        self.price = [
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineFittingText())
        ]
        self.priceLoadingCorner = 4
        self.priceLoadingMinSize = (110, 48)
        self.spacingBetweenPriceAndPriceAttribute = 12
        self.priceAttribute = AlgoPriceAttributeViewTheme(family)
        self.priceAttributeMinSize = (60, 20)
        self.spacingBetweenPriceAttributeAndChart = 15
        self.chartHeight = 180
    }
}
