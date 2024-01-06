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

//   AlgorandSecureBackupRecoverMnemonicScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AlgorandSecureBackupRecoverMnemonicScreenTheme: LayoutSheet, StyleSheet {
    let accountRecoverViewTheme: AccountRecoverViewTheme
    let background: ViewStyle

    let bottomInset: LayoutMetric
    let horizontalPadding: LayoutMetric
    let inputSuggestionsFrame: CGRect
    let keyboardInset: LayoutMetric
    let inputViewHeight: LayoutMetric
    let nextAction: ButtonStyle
    let nextActionContentEdgeInsets: UIEdgeInsets
    let nextActionEdgeInsets: NSDirectionalEdgeInsets

    init(_ family: LayoutFamily) {
        self.accountRecoverViewTheme = AlogranSecureBackupImportMnemonicTheme()
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]

        self.horizontalPadding = 24
        self.bottomInset = 16
        self.inputSuggestionsFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        self.keyboardInset = 76
        self.inputViewHeight = 732
        self.nextAction = [
            .titleColor([ .normal(Colors.Button.Primary.text), .disabled(Colors.Button.Primary.disabledText) ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .selected("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ]),
            .title("title-next".localized)
        ]
        self.nextActionContentEdgeInsets = .init(top: 14, left: 0, bottom: 14, right: 0)
        self.nextActionEdgeInsets = .init(top: 36, leading: 24, bottom: 16, trailing: 24)
    }
}
