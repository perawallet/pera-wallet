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

//   ActionableBannerViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ActionableBannerViewTheme: LayoutSheet, StyleSheet {
    var background: ViewStyle
    var corner: Corner?
    let contentWidthRatio: LayoutMetric
    var contentPaddings: LayoutPaddings
    var icon: ImageStyle
    var iconContentEdgeInsets: LayoutOffset
    var title: TextStyle
    var message: TextStyle
    var messageContentEdgeInsets: LayoutPaddings
    var actionHorizontalPaddings: LayoutHorizontalPaddings
    let action: ButtonStyle
    let actionCorner: Corner
    let actionContentEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily,
        contentBottomPadding: LayoutMetric = 20
    ) {
        corner = nil
        contentWidthRatio = 0.6
        contentPaddings = (20, 24, contentBottomPadding, .noMetric)
        background = [
            .backgroundColor(Colors.Helpers.negative)
        ]
        icon = [
            .contentMode(.bottomLeft),
        ]
        iconContentEdgeInsets = (12, 12)
        title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Defaults.background)
        ]
        message = [
            .textOverflow(FittingText()),
            .textColor(Colors.Defaults.background)
        ]
        messageContentEdgeInsets = (4, 0, 0, 0)
        actionHorizontalPaddings = (0, 24)
        action = [
            .titleColor([.normal(Colors.Button.Primary.text)]),
            .backgroundColor(Colors.Defaults.background.uiColor.withAlphaComponent(0.12))
        ]
        actionCorner = Corner(radius: 4)
        actionContentEdgeInsets = (8, 16, 8, 16)
    }

    init(_ family: LayoutFamily) {
        self.init(family, contentBottomPadding: 20)
    }
}
