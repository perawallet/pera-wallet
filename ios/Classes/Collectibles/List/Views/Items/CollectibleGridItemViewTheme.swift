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

//   CollectibleGridItemViewTheme.swift

import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct CollectibleGridItemViewTheme:
    LayoutSheet,
    StyleSheet {
    let image: URLImageViewStyleLayoutSheet

    let title: TextStyle
    let titleAndSubtitleContentTopPadding: LayoutMetric

    let subtitle: TextStyle

    let bottomLeftBadge: ImageStyle
    let bottomLeftBadgeContentEdgeInsets: LayoutPaddings
    let bottomLeftBadgePaddings: LayoutPaddings

    let topLeftBadge: ImageStyle
    let topLeftBadgeContentEdgeInsets: LayoutPaddings
    let topLeftBadgePaddings: LayoutPaddings

    let amount: TextStyle
    let amountContentEdgeInsets: LayoutPaddings
    let amountPaddings: LayoutPaddings
    let minimumSpacingBetweeenTopLeftBadgeAndAmount: LayoutMetric

    let pendingCanvasPaddings: LayoutPaddings

    let indicator: ImageStyle
    let indicatorSize: LayoutSize
    let indicatorLeadingPadding: LayoutMetric

    let pendingOverlay: ImageStyle
    let pendingCanvas: ImageStyle
    let pendingTitle: TextStyle
    let pendingTitlePaddings: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        image = URLImageViewCollectibleListTheme()

        title = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText()),
        ]
        titleAndSubtitleContentTopPadding = 12

        subtitle = [
            .textColor(Colors.Text.main),
            .textOverflow(MultilineText(numberOfLines: 2)),
        ]

        bottomLeftBadge = [
            .contentMode(.center),
            .tintColor(Colors.Text.white)
        ]
        bottomLeftBadgeContentEdgeInsets = (4, 4, 4, 4)
        bottomLeftBadgePaddings = (.noMetric, 8, 8, .noMetric)

        topLeftBadge = [
            .contentMode(.center)
        ]

        topLeftBadgeContentEdgeInsets = (2, 2, 2, 2)
        topLeftBadgePaddings = (8, 8, .noMetric, .noMetric)

        amount = [
            .textColor(Colors.Text.white),
            .textOverflow(SingleLineText()),
        ]
        amountContentEdgeInsets = (4, 6, 4, 6)
        amountPaddings = (8, .noMetric, .noMetric, 8)
        minimumSpacingBetweeenTopLeftBadgeAndAmount = 8

        pendingCanvasPaddings = (.noMetric, 8, 8, .noMetric)

        indicator = [
            .image("loading-indicator".templateImage),
            .tintColor(Colors.Text.white),
            .contentMode(.scaleAspectFit)
        ]
        indicatorSize = (15, 15)
        indicatorLeadingPadding = 6

        pendingOverlay = [ .image("overlay-bg") ]
        pendingCanvas = [ .image("badge-bg") ]
        pendingTitle = [
            .textColor(Colors.Text.white),
            .textOverflow(SingleLineText()),
        ]
        pendingTitlePaddings = (4, 6, 4, 6)
    }
}

struct URLImageViewCollectibleListTheme: URLImageViewStyleLayoutSheet {
    struct PlaceholderLayoutSheet: URLImagePlaceholderViewLayoutSheet {
        let textPaddings: LayoutPaddings

        init(
            _ family: LayoutFamily
        ) {
            textPaddings = (8, 8, 8, 8)
        }
    }

    struct PlaceholderStyleSheet: URLImagePlaceholderViewStyleSheet {
        let background: ViewStyle
        let image: ImageStyle
        let text: TextStyle

        init() {
            background = []
            image = []
            text = [
                .textColor(Colors.Text.gray),
                .textOverflow(FittingText())
            ]
        }
    }

    let background: ViewStyle
    let content: ImageStyle
    let placeholderStyleSheet: URLImagePlaceholderViewStyleSheet?
    let placeholderLayoutSheet: URLImagePlaceholderViewLayoutSheet?

    init(
        _ family: LayoutFamily
    ) {
        background = []
        content = .aspectFit()
        placeholderStyleSheet = PlaceholderStyleSheet()
        placeholderLayoutSheet = PlaceholderLayoutSheet()
    }
}
