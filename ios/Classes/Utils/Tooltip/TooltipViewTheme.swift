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

//   TooltipViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct TooltipViewTheme:
    StyleSheet,
    LayoutSheet {
    let backgroundColor: Color

    let contentHorizontalMargins: LayoutHorizontalMargins
    let contentBottomMargin: LayoutMetric

    let corner: Corner

    let title: TextStyle
    let titleContentEdgeInsets: LayoutPaddings

    let arrowSize: LayoutSize

    init(
        _ family: LayoutFamily
    ) {
        backgroundColor = Colors.Toast.background

        contentHorizontalMargins = (24, 24)
        contentBottomMargin = 8

        corner = Corner(radius: 12)

        title = [
            .textColor(Colors.Toast.title),
            .textOverflow(FittingText()),
        ]
        titleContentEdgeInsets = (8, 16, 8, 16)

        arrowSize = (12, 8)
    }
}
