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
//   AlgoStatisticsLoadingViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AlgoStatisticsLoadingViewTheme: StyleSheet, LayoutSheet {
    let loadingCorner: Corner

    let priceViewMargin: LayoutMargins
    let priceViewSize: LayoutSize

    let priceSubviewMargin: LayoutMargins
    let priceSubviewSize: LayoutSize

    let statsImage: ImageStyle
    let statsMargin: LayoutMargins
    let statsHeight: LayoutMetric

    let controlViewMargin: LayoutMargins
    let controlViewHeight: LayoutMetric

    let headerLoadingMargin: LayoutMargins
    let headerLoadingSize: LayoutSize

    let firstItemTopInset: LayoutMetric
    let itemLeadingInset: LayoutMetric
    let itemHeight: LayoutMetric

    let itemContainerSeparator: Separator
    let itemLeftSize: LayoutSize

    let firstRightItemSize: LayoutSize
    let secondRightItemSize: LayoutSize
    let thirdRightItemSize: LayoutSize


    init(_ family: LayoutFamily) {
        self.loadingCorner = Corner(radius: 4)

        self.priceViewMargin = (20, 24, .noMetric, .noMetric)
        self.priceViewSize = (109, 44)

        self.priceSubviewMargin = (12, 24, .noMetric, .noMetric)
        self.priceSubviewSize = (59, 20)

        self.statsImage = [
            .image("chart-loading-bg"),
            .contentMode(.scaleAspectFit)
        ]

        self.statsMargin = (15, 0, .noMetric, 0)
        self.statsHeight = 180

        self.controlViewMargin = (40, 24, .noMetric, 24)
        self.controlViewHeight = 30

        self.headerLoadingMargin = (42, 24, .noMetric, .noMetric)
        self.headerLoadingSize = (81, 20)

        self.firstItemTopInset = 6
        self.itemLeadingInset = 24
        self.itemHeight = 56

        self.itemContainerSeparator = Separator(color: AppColors.Shared.Layer.grayLighter)
        self.itemLeftSize = (81, 16)

        self.firstRightItemSize = (107, 20)
        self.secondRightItemSize = (55, 20)
        self.thirdRightItemSize = (71, 20)
    }
}
