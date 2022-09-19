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
//   SingleLineTitleActionViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SingleLineTitleActionViewTheme: StyleSheet, LayoutSheet {
    let title: TextStyle
    let action: ButtonStyle

    let titleLeadingPadding: LayoutMetric
    let titleTrailingPadding: LayoutMetric
    let actionTrailingPadding: LayoutMetric
    let actionSize: LayoutSize

    init(_ family: LayoutFamily) {
        self.title = [
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(Colors.Text.main)
        ]
        self.action = [
            .icon([.normal("icon-options")])
        ]

        self.titleLeadingPadding = 24
        self.titleTrailingPadding = 8
        self.actionTrailingPadding = 16
        self.actionSize = LayoutSize(w: 40, h: 40)
    }
}
