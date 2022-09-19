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
//   EditAccountViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct EditAccountViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let doneButton: ButtonStyle
    let doneButtonContentEdgeInsets: LayoutPaddings
    let doneButtonCorner: Corner
    let verticalPadding: LayoutMetric
    let horizontalPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.doneButton = [
            .title("title-done".localized),
            .titleColor([ .normal(Colors.Button.Primary.text) ]),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(Colors.Button.Primary.background)
        ]
        self.doneButtonContentEdgeInsets = (14, 0, 14, 0)
        self.doneButtonCorner = Corner(radius: 4)
        self.verticalPadding = 16
        self.horizontalPadding = 24
    }
}
