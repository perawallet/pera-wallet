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
//   BottomOverlayTheme.swift

import Foundation
import MacaroonUIKit
import MacaroonBottomOverlay

struct BottomOverlayCommonStyleSheet: BottomOverlayViewStyleSheet {
    var background: ViewStyle
    var backgroundShadow: MacaroonUIKit.Shadow?
    var backgroundSecondShadow: MacaroonUIKit.Shadow?
    var handle: ImageStyle

    init() {
        background = []
        handle = [
            .image("icon-bottom-sheet-handle")
        ]
    }
}


struct BottomOverlayCommonLayoutSheet: BottomOverlayViewLayoutSheet {
    var contentPaddings: LayoutPaddings
    var handleCenterOffsetX: LayoutMetric
    var handleTopPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        contentPaddings = (0, 0, 0, 0)
        handleCenterOffsetX = 0
        handleTopPadding = 0
    }
}

