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

//   AlgorandSecureBackupAccountListAccountsHeaderViewTheme.swift

import Foundation
import UIKit
import MacaroonUIKit

struct AlgorandSecureBackupAccountListAccountsHeaderViewTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let minimumHorizontalSpacing: LayoutMetric
    let info: TextStyle
    let infoMinWidthRatio: LayoutMetric
    let actionLayout: MacaroonUIKit.Button.Layout
    let selectAllAction: ButtonStyle
    let partialSelectionAction: ButtonStyle
    let unselectAllAction: ButtonStyle

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.minimumHorizontalSpacing = 8
        self.info = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main),
        ]
        self.infoMinWidthRatio = 0.5
        self.selectAllAction = [
            .title("title-select-all".localized.bodyMedium(lineBreakMode: .byTruncatingTail)),
            .titleColor([ .normal(Colors.Link.primary) ]),
            .icon([ .normal("icon-checkbox-unselected") ])
        ]
        self.partialSelectionAction = [
            .title("title-select-all".localized.bodyMedium(lineBreakMode: .byTruncatingTail)),
            .titleColor([ .normal(Colors.Link.primary) ]),
            .icon([ .normal("icon-checkbox-partial-selected") ])
        ]
        self.unselectAllAction = [
            .title("title-unselect-all".localized.bodyMedium(lineBreakMode: .byTruncatingTail)),
            .titleColor([ .normal(Colors.Link.primary) ]),
            .icon([ .normal("icon-checkbox-selected") ])
        ]

        self.actionLayout = .imageAtRight(spacing: 12)
    }

    subscript (state: AlgorandSecureBackupAccountListAccountHeaderItemState) -> ButtonStyle {
        switch state {
        case .selectAll: return selectAllAction
        case .partialSelection: return partialSelectionAction
        case .unselectAll: return unselectAllAction
        }
    }
}
