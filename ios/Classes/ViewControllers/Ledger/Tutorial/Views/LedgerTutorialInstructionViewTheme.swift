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
//   LedgerTutorialInstructionViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct LedgerTutorialInstructionViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let arrowImage: ImageStyle

    let horizontalInset: LayoutMetric
    let iconSize: LayoutSize
    let numberSize: LayoutSize
    let titleHorizontalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = UIColor.clear
        self.title = [
            .textOverflow(FittingText()),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.left),
            .textColor(Colors.Text.main)
        ]
        self.arrowImage = [
            .image("icon-arrow-gray-24")
        ]

        self.horizontalInset = 24
        self.iconSize = (24, 24)
        self.numberSize = (32, 32)
        self.titleHorizontalInset = -12
    }
}
