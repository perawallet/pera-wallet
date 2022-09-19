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
//   SingleLineIconTitleViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SingleLineIconTitleViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let icon: ImageStyle
    let title: TextStyle

    let iconSize: LayoutSize
    let verticalInset: LayoutMetric
    let titleHorizontalPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.icon = [
            .contentMode(.scaleAspectFit)
        ]
        self.title = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(Colors.Text.main)
        ]

        self.iconSize = LayoutSize(w: 24, h: 24)
        self.verticalInset = 18
        self.titleHorizontalPadding = 20
    }
}
