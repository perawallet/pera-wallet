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

//   SelectedAccountPreviewViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SelectedAccountPreviewViewTheme: LayoutSheet, StyleSheet {
    let contentMinWidthRatio: LayoutMetric

    let horizontalPadding: LayoutMetric
    let verticalPadding: LayoutMetric

    let background: ViewStyle

    let separator: Separator

    let icon: ImageStyle
    let iconHorizontalPaddings: LayoutHorizontalPaddings
    let iconSize: LayoutSize

    var title: TextStyle
    var value: TextStyle

    let actionHorizontalPaddings: LayoutHorizontalPaddings
    let copyAction: ButtonStyle
    let scanQRAction: ButtonStyle
    let spacingBetweenActions: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        horizontalPadding = 24
        verticalPadding = 12

        contentMinWidthRatio = 0.5

        background = [
            .backgroundColor(Colors.Defaults.background)
        ]

        separator = Separator(color: Colors.Layer.grayLighter, size: 1, position: .top((0, 0)))

        icon = [
            .contentMode(.scaleAspectFit)
        ]
        iconHorizontalPaddings = (0, 12)
        iconSize = (24, 24)

        title = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.gray)
        ]
        value = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main)
        ]

        actionHorizontalPaddings = (8, horizontalPadding)
        spacingBetweenActions = 12
        copyAction = [
            .icon([ .normal("icon-copy-gray-24") ])
        ]
        scanQRAction = [
            .icon([ .normal("icon-qr-gray-24") ])
        ]
    }
}
