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

//   FullScreenContentViewControllerTheme.swift

import MacaroonUIKit
import UIKit

struct FullScreenContentViewControllerTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle

    let contentCorner: Corner

    let close: ButtonStyle
    let closeActionSize: LayoutSize
    let closeActionTopPadding: LayoutMetric
    let closeActionLeadingPadding: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        background = [
            .backgroundColor(UIColor.black)
        ]

        contentCorner = Corner(radius: 4)

        close = [
            .icon([.normal("icon-close-background")])
        ]
        closeActionSize = (44, 44)
        closeActionTopPadding = 12
        closeActionLeadingPadding = 20
    }
}
