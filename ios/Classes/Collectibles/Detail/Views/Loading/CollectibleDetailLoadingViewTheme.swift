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
    let imagePaddings: LayoutPaddings

    let titleViewHeight: LayoutMetric
    let titleTopPadding: LayoutMetric
    let titleWidthMultiplier: LayoutMetric

    let subtitleViewHeight: LayoutMetric
    let subtitleTopPadding: LayoutMetric
    let subtitleWidthMultiplier: LayoutMetric

    let actionTopPadding: LayoutMetric
    let actionHeight: LayoutMetric
    let spacingBetweeenActions: LayoutMetric

    let descriptionHeight: LayoutMetric
    let descriptionWidthMultiplier: LayoutMetric

    let descriptionValueLineHeight: LayoutMetric
    let descriptionValueLineSpacing: LayoutMetric
    let descriptionValueFirstLineTopMargin: LayoutMetric
    let descriptionValueFirstLineWidthMultiplier: LayoutMetric
    let descriptionValueSecondLineWidthMultiplier: LayoutMetric

    let corner: Corner

    let spacingBetweenDescriptionAndSeparator: LayoutMetric
    let separator: Separator

    init(
        _ family: LayoutFamily
    ) {
        imagePaddings = (12, 24, .noMetric, 24)

        titleTopPadding = 36
        titleViewHeight = 16
        titleWidthMultiplier = 0.20

        subtitleTopPadding = 8
        subtitleViewHeight = 20
        subtitleWidthMultiplier = 0.30

        descriptionHeight = 24
        descriptionWidthMultiplier = 0.30

        descriptionValueLineHeight = 20
        descriptionValueLineSpacing = 4
        descriptionValueFirstLineTopMargin = 20
        descriptionValueFirstLineWidthMultiplier = 0.80
        descriptionValueSecondLineWidthMultiplier = 0.60

        corner = Corner(radius: 4)

        separator = Separator(color: Colors.Layer.grayLighter, size: 1)

        spacingBetweenDescriptionAndSeparator = 32

        actionTopPadding = 20
        actionHeight = 52
        spacingBetweeenActions = 16
    }
}
