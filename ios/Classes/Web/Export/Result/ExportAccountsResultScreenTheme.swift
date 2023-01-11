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

//   ExportAccountsResultScreenTheme.swift

import Foundation
import MacaroonUIKit

struct ExportAccountsResultScreenTheme:
    LayoutSheet,
    StyleSheet {
    let background: ViewStyle
    let context: ResultViewTheme
    let contextEdgeInsets: LayoutPaddings
    let closeAction: ButtonStyle
    let closeActionEdgeInsets: LayoutPaddings
    let closeActionContentEdgeInsets: LayoutPaddings

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.context = ExportAccountsResultViewTheme(family)
        self.contextEdgeInsets = (72, 24, 8, 24)
        self.closeAction = [
            .title("title-close".localized),
            .titleColor([ .normal(Colors.Button.Primary.text) ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
            ])
        ]
        self.closeActionEdgeInsets = (16, 8, 16, 8)
        self.closeActionContentEdgeInsets = (8, 24, 12, 24)
    }
}
