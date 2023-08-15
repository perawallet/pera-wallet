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

//   RekeyedAccountSelectionListScreenTheme.swift

import Foundation
import MacaroonUIKit

struct RekeyedAccountSelectionListScreenTheme:
    LayoutSheet,
    StyleSheet {
    var background: ViewStyle
    var spacingBetweenListAndPrimaryAction: LayoutMetric
    var primaryAction: ButtonStyle
    var secondaryAction: ButtonStyle
    var actionEdgeInsets: LayoutPaddings
    var actionMargins: LayoutMargins
    var spacingBetweenActions: LayoutMetric
    var navigationBarEdgeInset: LayoutMargins

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.spacingBetweenListAndPrimaryAction = 16
        self.primaryAction = [
            .font(Typography.bodyMedium()),
            .titleColor([
                .normal(Colors.Button.Primary.text),
                .disabled(Colors.Button.Primary.disabledText)
            ]),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ])
        ]
        self.secondaryAction = [
            .title("title-skip-for-now".localized),
            .font(Typography.bodyMedium()),
            .titleColor([
                .normal(Colors.Button.Secondary.text)
            ]),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted")
            ])
        ]
        self.actionEdgeInsets = (16, 8, 16, 8)
        self.actionMargins = (.noMetric, 24, 12, 24)
        self.spacingBetweenActions = 16
        self.navigationBarEdgeInset = (32, 24, .noMetric, 24)
    }
}
