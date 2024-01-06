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

//   AlgorandSecureBackupAccountListScreenTheme.swift

import Foundation
import MacaroonUIKit

struct AlgorandSecureBackupAccountListScreenTheme:
    LayoutSheet,
    StyleSheet {
    let background: ViewStyle
    let spacingBetweenListAndContinueAction: LayoutMetric
    let continueAction: ButtonStyle
    let continueActionEdgeInsets: LayoutPaddings
    let continueActionContentEdgeInsets: LayoutMargins
    let navigationBarEdgeInset: LayoutMargins
    let listContentTopInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.spacingBetweenListAndContinueAction = 16
        self.continueAction = [
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
        self.continueActionEdgeInsets = (16, 8, 16, 8)
        self.continueActionContentEdgeInsets = (.noMetric, 24, 12, 24)
        self.navigationBarEdgeInset = (8, 24, .noMetric, 24)
        self.listContentTopInset = 40
    }

    func continueActionForExport(accountCount: Int) -> ButtonStyle {
        let title: String

        if accountCount == 0 {
            title = "algorand-secure-backup-account-list-action-title".localized
        } else if accountCount == 1 {
            title = "algorand-secure-backup-account-list-action-title-singular".localized
        } else {
            title = "algorand-secure-backup-account-list-action-title-plural".localized(params: "\(accountCount)")
        }

        var buttonStyleAttributes = [ButtonStyle.Attribute]()

        if let font = continueAction.font {
            buttonStyleAttributes.append(.font(font))
        }

        if let titleColor = continueAction.titleColor {
            buttonStyleAttributes.append(.titleColor(titleColor))
        }

        if let backgroundImage = continueAction.backgroundImage {
            buttonStyleAttributes.append(.backgroundImage(backgroundImage))
        }

        if let titleColor = continueAction.titleColor {
            buttonStyleAttributes.append(.titleColor(titleColor))
        }

        buttonStyleAttributes.append(.title(title))

        return ButtonStyle(attributes: buttonStyleAttributes)
    }

    func continueActionForRestore(accountCount: Int) -> ButtonStyle {
        let title: String

        if accountCount == 0 {
            title = "algorand-secure-backup-account-list-restore-action-title".localized
        } else if accountCount == 1 {
            title = "algorand-secure-backup-account-list-restore-action-title-singular".localized
        } else {
            title = "algorand-secure-backup-account-list-restore-action-title-plural".localized(params: "\(accountCount)")
        }

        var buttonStyleAttributes = [ButtonStyle.Attribute]()

        if let font = continueAction.font {
            buttonStyleAttributes.append(.font(font))
        }

        if let titleColor = continueAction.titleColor {
            buttonStyleAttributes.append(.titleColor(titleColor))
        }

        if let backgroundImage = continueAction.backgroundImage {
            buttonStyleAttributes.append(.backgroundImage(backgroundImage))
        }

        if let titleColor = continueAction.titleColor {
            buttonStyleAttributes.append(.titleColor(titleColor))
        }

        buttonStyleAttributes.append(.title(title))

        return ButtonStyle(attributes: buttonStyleAttributes)
    }
}
