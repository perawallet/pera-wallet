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
//   RekeyTransitionItemViewTheme.swift

import MacaroonUIKit
import UIKit

struct RekeyTransitionItemViewTheme: StyleSheet, LayoutSheet {
    let image: ImageStyle
    let title: TextStyle
    let value: TextStyle

    let titleLabelTopPadding: LayoutMetric
    let valueLabelTopPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.image = [
            .contentMode(.scaleAspectFit)
        ]
        self.title = [
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.center),
            .textOverflow(FittingText()),
            .text("ledger-approval-title".localized)
        ]
        self.value = [
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(19)),
            .textAlignment(.center),
            .textOverflow(FittingText())
        ]
        self.titleLabelTopPadding = 16
        self.valueLabelTopPadding = 4
    }
}
