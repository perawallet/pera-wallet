// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AlgorandSecureBackupInstructionScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AlgorandSecureBackupInstructionsScreenTheme:
    LayoutSheet,
    StyleSheet {
    var background: ViewStyle
    var navigationBarEdgeInset: LayoutMargins
    var contextPaddings: LayoutPaddings
    var header: TextStyle
    var spacingBetweenInstructionsAndHeader: LayoutMetric
    var instruction: AlgorandSecureBackupInstructionItemViewTheme
    var instructionsSpacing: LayoutMetric
    var startAction: ButtonStyle
    var startActionContentEdgeInsets: UIEdgeInsets
    var startActionEdgeInsets: NSDirectionalEdgeInsets

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.navigationBarEdgeInset = (8, 24, .noMetric, 24)
        self.contextPaddings = (12, 24, 12, 24)
        self.header = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
            .font(Typography.bodyRegular())
        ]
        self.spacingBetweenInstructionsAndHeader = 40
        self.instruction = AlgorandSecureBackupInstructionItemViewTheme(family)
        self.instructionsSpacing = 24
        self.startAction = [
            .titleColor([ .normal(Colors.Button.Primary.text) ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .selected("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ])
        ]
        self.startActionContentEdgeInsets = .init(top: 14, left: 0, bottom: 14, right: 0)
        self.startActionEdgeInsets = .init(top: 36, leading: 24, bottom: 16, trailing: 24)
    }
}
