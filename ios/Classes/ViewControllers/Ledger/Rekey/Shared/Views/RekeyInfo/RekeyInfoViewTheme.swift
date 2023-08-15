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

//   RekeyInfoViewTheme.swift

import Foundation
import MacaroonUIKit

struct RekeyInfoViewTheme:
    LayoutSheet,
    StyleSheet {
    var title: TextStyle
    var spacingBetweenTitleAndContent: LayoutMetric
    var accountItemContentPaddings: LayoutPaddings
    var accountItem: AccountListItemViewTheme
    var accountItemMinHeight: LayoutMetric
    var arrowImage: ImageStyle
    var arrowImageLayoutOffset: LayoutOffset

    init(_ family: LayoutFamily) {
        self.title = [
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineText())
        ]
        self.spacingBetweenTitleAndContent = 8
        self.accountItemContentPaddings = (16, 0, 16, 0)
        self.accountItem = AccountListItemViewTheme(family)
        self.accountItemMinHeight = 76
        self.arrowImage = [
            .image("arrow-down"),
            .contentMode(.right)
        ]
        self.arrowImageLayoutOffset = (8, 0)
    }
}
