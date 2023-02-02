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

//   CollectibleListItemViewTheme.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct CollectibleListItemViewTheme:
    StyleSheet,
    LayoutSheet {
    var icon: URLImageViewStyleSheet & URLImageViewLayoutSheet
    var iconSize: LayoutSize
    var iconBottomRightBadgePaddings: LayoutPaddings
    var loadingIndicator: ImageStyle
    var loadingIndicatorSize: LayoutSize
    var spacingBetweenIconAndTitle: CGFloat
    var primaryTitle: TextStyle
    var primaryTitleAccessory: ImageStyle
    var primaryTitleAccessoryContentEdgeInsets: LayoutOffset
    var secondaryTitle: TextStyle
    var spacingBetweenPrimaryAndSecondaryTitles: LayoutMetric
    var amount: TextStyle

    init(_ family: LayoutFamily) {
        self.icon = URLImageViewCollectibleListItemTheme()
        self.iconSize = (40, 40)
        self.iconBottomRightBadgePaddings = (20, 20, .noMetric, .noMetric)
        self.loadingIndicator = [
            .image("loading-indicator".templateImage),
            .tintColor(Colors.Other.Global.gray400),
            .contentMode(.scaleAspectFit)
        ]
        self.loadingIndicatorSize = (15, 15)
        self.spacingBetweenIconAndTitle = 16
        self.primaryTitle = [
            .textColor(Colors.Text.main),
        ]
        self.primaryTitleAccessory = [
            .contentMode(.right),
        ]
        self.primaryTitleAccessoryContentEdgeInsets = (6, 0)
        self.secondaryTitle = [
            .textColor(Colors.Text.grayLighter)
        ]
        self.spacingBetweenPrimaryAndSecondaryTitles = 0
        self.amount = [
            .textColor(Colors.Text.grayLighter)
        ]
    }
}

struct URLImageViewCollectibleListItemTheme: URLImageViewStyleLayoutSheet {
    struct PlaceholderStyleSheet: URLImagePlaceholderViewStyleSheet {
        var background: ViewStyle
        var image: ImageStyle
        var text: TextStyle

        init() {
            background = []
            image = []
            text = [
                .font(Typography.footnoteRegular()),
                .textAlignment(.center),
                .textColor(Colors.Text.gray),
                .textOverflow(SingleLineFittingText())
            ]
        }
    }

    struct PlaceholderLayoutSheet: URLImagePlaceholderViewLayoutSheet {
        var textPaddings: LayoutPaddings

        init(
            _ family: LayoutFamily
        ) {
            textPaddings = (2, 2, 2, 2)
        }
    }

    var background: ViewStyle
    var content: ImageStyle
    var placeholderStyleSheet: URLImagePlaceholderViewStyleSheet?
    var placeholderLayoutSheet: URLImagePlaceholderViewLayoutSheet?

    init(
        _ family: LayoutFamily
    ) {
        background = []
        content = .aspectFit()
        placeholderStyleSheet = PlaceholderStyleSheet()
        placeholderLayoutSheet = PlaceholderLayoutSheet()
    }
}
