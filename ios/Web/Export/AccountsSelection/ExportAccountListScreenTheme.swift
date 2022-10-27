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

//   ExportAccountListScreenTheme.swift

import Foundation
import MacaroonUIKit

struct ExportAccountListScreenTheme:
    LayoutSheet,
    StyleSheet {
    let background: ViewStyle
    let spacingBetweenListAndContinueAction: LayoutMetric
    let continueAction: ButtonStyle
    let closeAction: ButtonStyle
    let continueActionEdgeInsets: LayoutPaddings
    let continueActionContentEdgeInsets: LayoutMargins
    let navigationBarEdgeInset: LayoutMargins
    let listContentTopInset: LayoutMetric
    let noContentAdditionalHorizontalInset: LayoutHorizontalMargins

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.spacingBetweenListAndContinueAction = 16
        self.continueAction = [
            .title("title-continue".localized),
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
        self.closeAction = [
            .title("title-close".localized),
            .font(Typography.bodyMedium()),
            .titleColor([
                .normal(Colors.Button.Secondary.text),
                .disabled(Colors.Button.Secondary.disabledText)
            ]),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted"),
                .disabled("components/buttons/secondary/bg-disabled")
            ])
        ]
        self.continueActionEdgeInsets = (16, 8, 16, 8)
        self.continueActionContentEdgeInsets = (.noMetric, 24, 12, 24)
        self.navigationBarEdgeInset = (8, 24, .noMetric, 24)
        self.listContentTopInset = 16
        self.noContentAdditionalHorizontalInset = (30, 30)
    }
}
