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

//   CollectibleTransactionInfoViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct CollectibleTransactionInfoViewTheme:
    StyleSheet,
    LayoutSheet {
    let title: TextStyle
    let titleContentEdgeInsets: LayoutPaddings
    let value: TextStyle

    let icon: ImageStyle
    var iconContentEdgeInsets: LayoutOffset
    let iconSize: LayoutSize
    let iconCorner: Corner

    let valueWidthRatio: LayoutMetric
    let verticalPadding: LayoutMetric

    let separator: Separator

    init(
        _ family: LayoutFamily
    ) {
        title = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray)
        ]
        titleContentEdgeInsets = (0, 0, 0, 8)
        value = [
            .textAlignment(.right),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main)
        ]
        icon = [
            .contentMode(.topLeft),
            .isInteractable(false)
        ]
        iconContentEdgeInsets = (8, 0)
        iconSize = (24, 24)
        iconCorner = Corner(radius: 12)

        valueWidthRatio = 0.50
        verticalPadding = 16

        separator = Separator(color: Colors.Layer.grayLighter)
    }
}
