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

//   CollectibleDetailLoadingViewTheme.swift

import MacaroonUIKit

struct CollectibleDetailLoadingViewTheme:
    LayoutSheet,
    StyleSheet {
    let corner: Corner
    let titleViewHeight: LayoutMetric
    let titlePaddings: LayoutPaddings
    let titleWidthMultiplier: LayoutMetric
    let subtitleViewHeight: LayoutMetric
    let subtitleTopPadding: LayoutMetric
    let subtitleWidthMultiplier: LayoutMetric
    let imageCorner: Corner
    let imagePaddings: LayoutPaddings
    let amountViewHeight: LayoutMetric
    let amountTopPadding: LayoutMetric
    let amountWidthMultiplier: LayoutMetric
    let actionTopPadding: LayoutMetric
    let actionHeight: LayoutMetric
    let spacingBetweenDescriptionAndAction: LayoutMetric
    let descriptionHeight: LayoutMetric
    let descriptionWidthMultiplier: LayoutMetric
    let descriptionValueLineHeight: LayoutMetric
    let descriptionValueLineSpacing: LayoutMetric
    let descriptionValueFirstLineTopMargin: LayoutMetric
    let descriptionValueFirstLineWidthMultiplier: LayoutMetric
    let descriptionValueSecondLineWidthMultiplier: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.corner = Corner(radius: 4)
        self.titlePaddings = (10, 24, .noMetric, 24)
        self.titleViewHeight = 28
        self.titleWidthMultiplier = 0.45
        self.subtitleTopPadding = 4
        self.subtitleViewHeight = 20
        self.subtitleWidthMultiplier = 0.35
        self.amountTopPadding = 21
        self.amountViewHeight = 20
        self.amountWidthMultiplier = 0.4
        self.imageCorner = Corner(radius: 12)
        self.imagePaddings = (20, 24, .noMetric, 24)
        self.actionTopPadding = 24
        self.actionHeight = 52
        self.spacingBetweenDescriptionAndAction = 24
        self.descriptionHeight = 24
        self.descriptionWidthMultiplier = 0.30
        self.descriptionValueLineHeight = 20
        self.descriptionValueLineSpacing = 4
        self.descriptionValueFirstLineTopMargin = 20
        self.descriptionValueFirstLineWidthMultiplier = 0.80
        self.descriptionValueSecondLineWidthMultiplier = 0.60
    }
}
