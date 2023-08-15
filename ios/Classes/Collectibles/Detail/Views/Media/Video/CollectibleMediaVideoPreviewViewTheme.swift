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

//   CollectibleMediaVideoPreviewViewTheme.swift

import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct CollectibleMediaVideoPreviewViewTheme:
    StyleSheet,
    LayoutSheet {
    let placeholder: URLImagePlaceholderViewLayoutSheet & URLImagePlaceholderViewStyleSheet
    let threeDAction: ButtonStyle
    let threeDActionContentEdgeInsets: LayoutPaddings
    let threeDModeActionPaddings: LayoutPaddings
    let fullScreenAction: ButtonStyle
    let fullScreenBadgePaddings: LayoutPaddings
    let corner: Corner

    init(
        _ family: LayoutFamily
    ) {
        placeholder = PlaceholderViewTheme()
        threeDAction = [
            .icon([.normal("icon-3d"), .highlighted("icon-3d")]),
            .backgroundImage([.normal("icon-3d-bg"), .highlighted("icon-3d-bg")]),
            .titleColor([ .normal(Colors.Text.white) ]),
            .title("collectible-detail-tap-3D".localized.footnoteMedium()),
        ]
        threeDActionContentEdgeInsets = (4, 8, 4, 8)
        threeDModeActionPaddings = (.noMetric, 16, 16, .noMetric)

        fullScreenAction = [
            .icon([ .normal("icon-full-screen"), .highlighted("icon-full-screen")])
        ]
        fullScreenBadgePaddings = (.noMetric, .noMetric, 16, 16)
        corner = Corner(radius: 12)
    }
}

extension CollectibleMediaVideoPreviewViewTheme {
    struct PlaceholderViewTheme:
        URLImagePlaceholderViewLayoutSheet,
        URLImagePlaceholderViewStyleSheet {
        var textPaddings: LayoutPaddings
        var background: ViewStyle
        var image: ImageStyle
        var text: TextStyle

        init(
            _ family: LayoutFamily
        ) {
            textPaddings = (8, 8, 8, 8)
            background = [
                .backgroundColor(Colors.Layer.grayLighter)
            ]
            image = []
            text = [
                .textColor(Colors.Text.gray),
                .textOverflow(FittingText())
            ]
        }
    }
}
