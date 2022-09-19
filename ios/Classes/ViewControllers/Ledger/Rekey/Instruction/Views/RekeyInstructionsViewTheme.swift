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
//   RekeyInstructionsViewTheme.swift

import MacaroonUIKit
import UIKit

struct RekeyInstructionsViewTheme: StyleSheet, LayoutSheet {
    let title: TextStyle
    let subtitle: TextStyle
    let headerTitle: TextStyle
    let startButtonTheme: ButtonTheme
    let instructionViewTheme: LargerInstructionItemViewTheme

    let horizontalPadding: LayoutMetric
    let titleTopPadding: LayoutMetric 
    let subtitleTopPadding: LayoutMetric
    let headerTopPadding: LayoutMetric
    let firstInstructionTopPadding: LayoutMetric
    let instructionSpacing: LayoutMetric
    let bottomPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.title = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.medium.make(32)),
            .textColor(Colors.Text.main),
            .text("rekey-instruction-title".localized)
        ]
        self.subtitle = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(Colors.Text.gray)
        ]
        self.headerTitle = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.medium.make(19)),
            .textColor(Colors.Text.main),
            .text("rekey-instruction-header".localized)
        ]
        self.startButtonTheme = ButtonPrimaryTheme()
        self.instructionViewTheme = LargerInstructionItemViewTheme()

        self.titleTopPadding = 2
        self.horizontalPadding = 24
        self.subtitleTopPadding = 16
        self.firstInstructionTopPadding = 24
        self.instructionSpacing = 28
        self.headerTopPadding = 60
        self.bottomPadding = 16
    }
}
