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

//   RekeyedAccountInformationAccountItemViewTheme.swift

import Foundation
import MacaroonUIKit

struct RekeyedAccountInformationAccountItemViewTheme:
    LayoutSheet,
    StyleSheet {
    var accountItem: AccountListItemWithActionViewTheme
    var accountItemMinHeight: LayoutMetric
    var dividerLine: ViewStyle
    var dividerLineMinWidth: LayoutMetric
    var dividerLineHeight: LayoutMetric
    var spacingBetweenDividerTitleAndLine: LayoutMetric
    var dividerTitle: TextStyle

    init(_ family: LayoutFamily) {
        self.accountItem = AccountListItemWithActionViewTheme(family)
        self.accountItemMinHeight = 80
        self.dividerLine = [ .backgroundColor(Colors.Layer.grayLighter) ]
        self.dividerLineMinWidth = 40
        self.dividerLineHeight = 1
        self.spacingBetweenDividerTitleAndLine = 20
        let dividerTitleText =
            "title-rekeyed-to"
                .localized
                .captionMedium(
                    alignment: .center,
                    lineBreakMode: .byTruncatingTail
                )
        self.dividerTitle = [
            .text(dividerTitleText),
            .textColor(Colors.Text.grayLighter),
            .textOverflow(SingleLineText())
        ]
    }
}
