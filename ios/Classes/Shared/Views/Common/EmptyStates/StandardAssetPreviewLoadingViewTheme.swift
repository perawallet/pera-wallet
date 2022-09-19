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

//   StandardAssetPreviewLoadingViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct StandardAssetPreviewLoadingViewTheme:
    StyleSheet,
    LayoutSheet {
    var corner: Corner
    var background: ViewStyle
    var contentEdgeInsets: LayoutPaddings
    var iconSize: LayoutSize
    var iconCorner: Corner
    var spacingBetweenIconAndInfo: LayoutMetric
    var infoSize: LayoutSize
    var spacingBetweeenPrimaryValueAndInfo: LayoutMetric
    var primaryValueSize: LayoutSize
    var spacingBetweeenPrimaryValueAndSecondaryValue: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        corner = Corner(radius: 4)
        contentEdgeInsets = (40, 0, 40, 0)
        background = [
            .backgroundColor(Colors.Helpers.heroBackground)
        ]
        iconSize = (40, 40)
        iconCorner = Corner(radius: iconSize.h / 2)
        spacingBetweenIconAndInfo = 20
        infoSize = (89, 20)
        spacingBetweeenPrimaryValueAndInfo = 8
        primaryValueSize = (210, 36)
        spacingBetweeenPrimaryValueAndSecondaryValue = 8
    }
}
