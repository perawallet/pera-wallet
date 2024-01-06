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

//   AlgorandSecureBackupMnemonicsScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AlgorandSecureBackupMnemonicsScreenTheme: LayoutSheet, StyleSheet {
    let background: ViewStyle
    let passphraseBackUpViewTheme: PassphraseBackUpViewTheme
    let cellHeight: LayoutMetric
    let defaultInset: LayoutMetric
    let navigationBarEdgeInset: LayoutMargins
    let header: TextStyle
    let peraLearn: [AttributedTextBuilder.Attribute]
    let peraLearnLinkAttributes: [AttributedTextBuilder.Attribute]
    let peraLearnTopOffset: LayoutMetric
    let passphraseTopOffset: LayoutMetric
    let passphraseHeight: LayoutMetric
    let actionsTopOffset: LayoutMetric
    let actionsPadding: LayoutMetric
    let copyAction: ButtonStyle
    let copyActionTitleEdgeInsets: UIEdgeInsets
    let regenerateKeyAction: ButtonStyle
    let regenerateKeyActionTitleEdgeInsets: UIEdgeInsets
    let storeAction: ButtonStyle
    let storeActionContentEdgeInsets: UIEdgeInsets
    let storeActionEdgeInsets: NSDirectionalEdgeInsets

    init(_ family: LayoutFamily) {
        background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        passphraseBackUpViewTheme = PassphraseBackUpViewTheme(family)
        cellHeight = 24
        defaultInset = 24
        navigationBarEdgeInset = (8, 24, .noMetric, 24)
        header = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
            .font(Typography.bodyRegular())
        ]
        peraLearn = [
            .textColor(Colors.Text.gray.uiColor),
            .font(Typography.bodyRegular().uiFont)
        ]
        peraLearnLinkAttributes = [
            .textColor(Colors.Helpers.positive.uiColor),
            .underline(UIColor.clear),
            .font(Typography.bodyBold().uiFont)
        ]
        peraLearnTopOffset = 12
        passphraseTopOffset = 48
        passphraseHeight = 232
        actionsTopOffset = 20
        actionsPadding = 16
        copyAction = [
            .icon([
                .normal("icon-copy-gray-24".templateImage),
                .highlighted("icon-copy-gray-24".templateImage)
            ]),
            .font(Typography.bodyMedium()),
            .titleColor([ .normal(Colors.Helpers.positive) ]),
            .tintColor(Colors.Helpers.positive),
            .title("algorand-secure-backup-mnemonics-copy-action-title".localized)
        ]
        copyActionTitleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
        regenerateKeyAction = [
            .icon([
                .normal("algorand-secure-backup-key".templateImage),
                .highlighted("algorand-secure-backup-key".templateImage)
            ]),
            .font(Typography.bodyMedium()),
            .titleColor([ .normal(Colors.Helpers.positive) ]),
            .tintColor(Colors.Helpers.positive),
            .title("algorand-secure-backup-mnemonics-regenerate-action-title".localized)
        ]
        regenerateKeyActionTitleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
        storeAction = [
            .titleColor([ .normal(Colors.Button.Primary.text) ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .selected("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ]),
            .title("algorand-secure-backup-mnemonics-store-action-title".localized)
        ]
        storeActionContentEdgeInsets = .init(top: 14, left: 0, bottom: 14, right: 0)
        storeActionEdgeInsets = .init(top: 36, leading: 24, bottom: 16, trailing: 24)
    }
}
