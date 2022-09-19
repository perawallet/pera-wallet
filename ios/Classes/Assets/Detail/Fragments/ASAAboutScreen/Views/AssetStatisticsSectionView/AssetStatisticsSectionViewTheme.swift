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

//   AssetStatisticsSectionViewTheme.swift

import Foundation
import UIKit
import MacaroonUIKit

struct AssetStatisticsSectionViewTheme:
    StyleSheet,
    LayoutSheet {
    var title: TextStyle
    var spacingBetweenTitleAndStatistics: LayoutMetric
    var price: PrimaryTitleViewTheme
    var spacingBetweenPriceAndTotalSupply: LayoutMetric
    var totalSupply: PrimaryTitleViewTheme

    init(
        _ family: LayoutFamily
    ) {
        self.title = [
            .textColor(Colors.Text.grayLighter),
            .textOverflow(SingleLineFittingText())
        ]
        self.spacingBetweenTitleAndStatistics = 24
        self.price = AssetStatisticsSectionPriceViewTheme(family)
        self.spacingBetweenPriceAndTotalSupply = 12
        self.totalSupply = AssetStatisticsSectionTotalSupplyViewTheme(family)
    }
}
