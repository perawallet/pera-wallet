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

import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct CollectibleListItemViewTheme:
    LayoutSheet,
    StyleSheet {
    let image: URLImageViewStyleSheet

    var overlay: ViewStyle
    var overlayAlpha: LayoutMetric

    let title: TextStyle
    let titleAndSubtitleContentTopPadding: LayoutMetric

    let subtitle: TextStyle

    let bottomLeftBadge: ImageStyle
    let bottomLeftBadgeContentEdgeInsets: LayoutOffset
    let bottomLeftBadgePaddings: LayoutPaddings

    let topLeftBadge: ImageStyle
    let topLeftBadgeContentEdgeInsets: LayoutOffset
    let topLeftBadgePaddings: LayoutPaddings

    let corner: Corner

    init(
        _ family: LayoutFamily
    ) {
        image = CollectibleListItemImageViewTheme()

        overlay = [
            .backgroundColor(UIColor.clear)
        ]
        overlayAlpha = 0

        title = [
            .textColor(AppColors.Components.Text.gray),
            .textOverflow(SingleLineText()),
        ]
        titleAndSubtitleContentTopPadding = 12

        subtitle = [
            .textColor(AppColors.Components.Text.main),
            .textOverflow(MultilineText(numberOfLines: 2)),
        ]

        bottomLeftBadge = [
            .backgroundColor(AppColors.Shared.System.background),
            .contentMode(.center)
        ]
        bottomLeftBadgeContentEdgeInsets = (8, 8)
        bottomLeftBadgePaddings = (.noMetric, 8, 8, .noMetric)

        topLeftBadge = [
            .backgroundColor(UIColor(red: 0.09, green: 0.09, blue: 0.11, alpha: 0.6)),
            .contentMode(.center)
        ]

        topLeftBadgeContentEdgeInsets = (4, 4)
        topLeftBadgePaddings = (8, 8, .noMetric, .noMetric)

        corner = Corner(radius: 4)
    }
}

struct CollectibleListItemImageViewTheme: URLImageViewStyleSheet {
    struct PlaceholderTheme: URLImagePlaceholderViewStyleSheet {
        let background: ViewStyle
        let image: ImageStyle
        let text: TextStyle

        init() {
            self.background = [
                .backgroundColor(AppColors.Shared.Layer.grayLighter)
            ]
            self.image = []
            self.text = [
                .textColor(AppColors.Components.Text.gray),
                .textOverflow(FittingText())
            ]
        }
    }

    let background: ViewStyle
    let content: ImageStyle
    let placeholder: URLImagePlaceholderViewStyleSheet?

    init() {
        self.background = []
        self.content = .aspectFill()
        self.placeholder = PlaceholderTheme()
    }
}

extension CollectibleListItemViewTheme {
    mutating func configureOverlayForOptedInCell() {
        overlay = overlay.modify([ .backgroundColor(AppColors.Shared.System.background) ])
        overlayAlpha = 0.4
    }
}
