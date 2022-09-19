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
    let contentMinWidthRatio: LayoutMetric
    let contentPaddings: LayoutPaddings

    var background: ViewStyle

    let icon: ImageStyle
    let iconContentEdgeInsets: LayoutOffset
    let iconSize: LayoutSize

    var title: TextStyle

    var message: TextStyle
    let messageContentEdgeInsets: LayoutPaddings

    let actionHorizontalPaddings: LayoutHorizontalPaddings
    let action: ButtonStyle
    let actionCorner: Corner
    let actionContentEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily,
        contentBottomPadding: LayoutMetric = 20
    ) {
        contentMinWidthRatio = 0.5
        contentPaddings = (20, 24, contentBottomPadding, .noMetric)

        background = [
            .backgroundColor(Colors.Helpers.negative)
        ]

        icon = [
            .contentMode(.bottomLeft),
        ]
        iconContentEdgeInsets = (12, 12)
        iconSize = (24, 24)

        title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Defaults.background)
        ]
        message = [
            .textOverflow(FittingText()),
            .textColor(Colors.Defaults.background)
        ]
        messageContentEdgeInsets = (4, 0, 0, 0)

        actionHorizontalPaddings = (20, 24)
        action = [
            .titleColor([.normal(Colors.Button.Primary.text)]),
            .backgroundColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.12))
        ]
        actionCorner = Corner(radius: 4)
        actionContentEdgeInsets = (8, 16, 8, 16)
    }

    init(_ family: LayoutFamily) {
        self.init(family, contentBottomPadding: 20)
    }
}
