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

//   AssetTransactionHistoryLoadingViewCommonTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AssetTransactionHistoryLoadingViewCommonTheme: AssetTransactionHistoryLoadingViewTheme {
    var titleViewCorner: LayoutMetric
    var titleViewSize: LayoutSize
    var titleMargin: LayoutMargins
    var balanceViewCorner: LayoutMetric
    var balanceViewSize: LayoutSize
    var balanceViewMargin: LayoutMargins
    var currencyViewCorner: LayoutMetric
    var currencyViewSize: LayoutSize
    var currencyViewMargin: LayoutMargins
    var assetNameLabelSize: LayoutSize
    var assetNameLabelTopPadding: LayoutMetric
    var assetIDButtonSize: LayoutSize
    var assetIDButtonTopPadding: LayoutMetric
    var separatorPadding: LayoutMetric
    var separator: Separator
    var bottomPadding: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {

        self.titleViewCorner = 4
        self.titleMargin = (24, .noMetric, .noMetric, .noMetric)
        self.titleViewSize = (100, 20)

        self.balanceViewCorner = 4
        self.balanceViewMargin = (12, .noMetric, .noMetric, .noMetric)
        self.balanceViewSize = (109, 44)

        self.currencyViewCorner = 4
        self.currencyViewMargin = (12, .noMetric, .noMetric, .noMetric)
        self.currencyViewSize = (59, 20)

        self.separatorPadding = 32
        self.separator = Separator(color: AppColors.Shared.Layer.grayLighter, size: 1)

        self.assetNameLabelSize = (138, 24)
        self.assetNameLabelTopPadding = 32
        self.assetIDButtonSize = (116, 24)
        self.assetIDButtonTopPadding = 11
        self.bottomPadding = 32
    }
}
