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

//   ExportAccountsConfirmationListScreenTheme.swift

import Foundation
import MacaroonUIKit

struct ExportAccountsConfirmationListScreenTheme:
    LayoutSheet,
    StyleSheet {
    let background: ViewStyle
    let spacingBetweenListAndContinueAction: LayoutMetric
    let continueActionIndicator: ImageStyle
    let continueAction: ButtonStyle
    let continueActionHeight: LayoutMetric
    let cancelAction: ButtonStyle
    let actionEdgeInsets: LayoutPaddings
    let actionMargins: LayoutMargins
    let spacingBetweenActions: LayoutMetric
    let navigationBarEdgeInset: LayoutMargins
    let listContentTopInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.spacingBetweenListAndContinueAction = 16
        self.continueActionIndicator = [
            .image("button-loading-indicator")
        ]
        self.continueAction = [
            .title("title-continue".localized),
            .font(Typography.bodyMedium()),
            .titleColor([
                .normal(Colors.Button.Primary.text)
            ]),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted")
            ])
        ]
        self.continueActionHeight = 52
        self.cancelAction = [
            .title("title-cancel".localized),
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
        self.navigationBarEdgeInset = (8, 24, .noMetric, 24)
        self.listContentTopInset = 16
    }
}
