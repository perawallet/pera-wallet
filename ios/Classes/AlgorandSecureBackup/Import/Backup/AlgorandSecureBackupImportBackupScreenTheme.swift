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

//   AlgorandSecureBackupImportBackupScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AlgorandSecureBackupImportBackupScreenTheme: LayoutSheet, StyleSheet {
    let background: ViewStyle
    let defaultInset: LayoutMetric
    let navigationBarEdgeInset: LayoutMargins
    let navigationTitle: String
    let header: TextStyle
    let uploadTopOffset: LayoutMetric
    let uploadHeight: LayoutMetric
    let actionsTopOffset: LayoutMetric
    let actionsPadding: LayoutMetric
    let pasteAction: ButtonStyle
    let pasteActionTitleEdgeInsets: UIEdgeInsets
    let nextAction: ButtonStyle
    let nextActionContentEdgeInsets: UIEdgeInsets
    let nextActionEdgeInsets: NSDirectionalEdgeInsets

    init(_ family: LayoutFamily) {
        background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        defaultInset = 24
        navigationBarEdgeInset = (8, 24, .noMetric, 24)
        navigationTitle = "algorand-secure-backup-import-backup-navigation-title".localized
        header = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
            .font(Typography.bodyRegular()),
            .text("algorand-secure-backup-import-backup-header".localized)
        ]
        uploadTopOffset = 102
        uploadHeight = 232
        actionsTopOffset = 20
        actionsPadding = 16
        pasteAction = [
            .icon([
                .normal("icon-paste".templateImage),
                .highlighted("icon-paste".templateImage)
            ]),
            .font(Typography.bodyMedium()),
            .titleColor([ .normal(Colors.Helpers.positive) ]),
            .tintColor(Colors.Helpers.positive),
            .title("algorand-secure-backup-import-backup-paste".localized)
        ]
        pasteActionTitleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
        nextAction = [
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
        nextActionContentEdgeInsets = .init(top: 14, left: 0, bottom: 14, right: 0)
        nextActionEdgeInsets = .init(top: 36, leading: 24, bottom: 16, trailing: 24)
    }
}
