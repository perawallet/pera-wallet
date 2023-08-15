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
//   OptionsViewController+Theme.swift

import MacaroonUIKit
import UIKit

struct OptionsViewControllerTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var canvasPaddings: LayoutPaddings
    var verticalPadding: LayoutMetric
    var primaryContextPaddings: LayoutPaddings
    var secondaryContextPaddings: LayoutPaddings
    var tertiaryContextPaddings: LayoutPaddings
    var separator: Separator
    var button: ListItemButtonTheme

    init(
        _ family: LayoutFamily
    ) {
        background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        verticalPadding = 20
        let horizontalPadding: LayoutMetric = 24
        canvasPaddings = (verticalPadding, horizontalPadding, verticalPadding, horizontalPadding)
        primaryContextPaddings = (0, 0, 0, 0)
        secondaryContextPaddings = (verticalPadding, 0, 0, 0)
        tertiaryContextPaddings = (verticalPadding, 0, 0, 0)
        separator = Separator(
            color: Colors.Layer.grayLighter,
            size: 1,
            position: .bottom((horizontalPadding, horizontalPadding))
        )
        button = ListItemButtonTheme(family)
    }
}
