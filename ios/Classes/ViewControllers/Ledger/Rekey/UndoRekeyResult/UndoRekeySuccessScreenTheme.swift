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

//   UndoRekeySuccessScreenTheme.swift

import Foundation
import MacaroonUIKit

struct UndoRekeySuccessScreenTheme:
    LayoutSheet,
    StyleSheet {
    var background: ViewStyle
    var contextPaddings: LayoutPaddings
    var result: ResultViewTheme
    var primaryAction: ButtonStyle
    var primaryActionContentEdgeInsets: LayoutPaddings
    var primaryActionEdgeInsets: LayoutPaddings

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contextPaddings = (68, 24, 28, 24)
        self.result = UndoRekeySuccessResultViewTheme(family)
        self.primaryAction = [
            .title("title-done".localized),
            .titleColor([ .normal(Colors.Button.Primary.text) ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .selected("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ])
        ]
        self.primaryActionContentEdgeInsets = (16, 24, 16, 24)
        self.primaryActionEdgeInsets = (8, 24, 16, 24)
    }
}
