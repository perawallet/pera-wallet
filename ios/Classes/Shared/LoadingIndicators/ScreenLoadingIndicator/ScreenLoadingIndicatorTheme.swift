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
//   ScreenLoadingIndicatorTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ScreenLoadingIndicatorTheme: StyleSheet, LayoutSheet {
    let contentEdgeInsets: LayoutPaddings
    let background: MacaroonUIKit.Shadow
    let indicator: ImageStyle
    let title: TextStyle
    let titleTopMargin: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.contentEdgeInsets = (20, 40, 20, 40)
        self.background =
            MacaroonUIKit.Shadow(
                color: Colors.Defaults.background.uiColor,
                fillColor: Colors.Defaults.background.uiColor,
                opacity: 0.16,
                offset: (0, 20),
                radius: 80,
                cornerRadii: (8, 8),
                corners: .allCorners
            )
        self.indicator = [
            .image("loading-indicator"),
            .contentMode(.scaleAspectFill)
        ]
        self.title = [
            .textAlignment(.center),
            .textOverflow(SingleLineFittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(15))
        ]
        self.titleTopMargin = 20
    }
}
