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

//   CollectibleGalleryUIActionsViewTheme.swift

import Foundation
import UIKit
import MacaroonUIKit

struct CollectibleGalleryUIActionsViewTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let searchInput: SearchInputViewTheme
    let spacingBetweenSearchInputAndGalleryUIStyleInput: LayoutMetric
    let galleryUIStyleInput: SegmentedControlTheme
    let gridUIStyleOption: Segment
    let listUIStyleOption: Segment

    init( _ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.searchInput = SearchInputViewCommonTheme(
            placeholder: "collectibles-list-input-placeholder".localized,
            family: family
        )
        self.spacingBetweenSearchInputAndGalleryUIStyleInput = 16
        self.galleryUIStyleInput = GalleryUIStyleInputTheme(family)
        self.gridUIStyleOption = GridUIStyleOptionTheme()
        self.listUIStyleOption = ListUIStyleOptionTheme()
    }
}

extension CollectibleGalleryUIActionsViewTheme {
    struct GalleryUIStyleInputTheme: SegmentedControlTheme {
        var background: MacaroonUIKit.ImageStyle?
        var divider: MacaroonUIKit.ImageStyle?
        var spacingBetweenSegments: CGFloat

        init(_ family: MacaroonUIKit.LayoutFamily) {
            spacingBetweenSegments = .zero
        }
    }

    struct GridUIStyleOptionTheme: Segment {
        var layout: Button.Layout
        var style: ButtonStyle
        var contentEdgeInsets: UIEdgeInsets

        init() {
            layout = .none
            style = [
                .icon([
                    .normal("icon-grid-style-segment"),
                    .selected("icon-grid-style-segment-selected")
                ])
            ]
            contentEdgeInsets = .zero
        }
    }

    struct ListUIStyleOptionTheme: Segment {
        var layout: Button.Layout
        var style: ButtonStyle
        var contentEdgeInsets: UIEdgeInsets

        init() {
            layout = .none
            style = [
                .icon([
                    .normal("icon-list-style-segment"),
                    .selected("icon-list-style-segment-selected")
                ])
            ]
            contentEdgeInsets = .zero
        }
    }
}
