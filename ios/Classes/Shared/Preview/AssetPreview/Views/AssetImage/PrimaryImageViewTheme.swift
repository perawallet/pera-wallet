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
//   PrimaryImageViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit
import MacaroonURLImage

protocol PrimaryImageViewTheme:
    LayoutSheet,
    StyleSheet {
    var image: URLImageViewStyleLayoutSheet { get }
}

struct AssetImageViewTheme: PrimaryImageViewTheme {
    var image: URLImageViewStyleLayoutSheet

    init(
        _ family: LayoutFamily
    ) {
        image = URLImageViewAssetTheme()
    }
}

struct URLImageViewAssetTheme: URLImageViewStyleLayoutSheet {
    struct PlaceholderStyleSheet: URLImagePlaceholderViewStyleSheet {
        var background: ViewStyle
        var image: ImageStyle
        var text: TextStyle

        init() {
            background = []
            image = [
                .image("asset-image-placeholder-border")
            ]
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
