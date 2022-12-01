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

//   AccountNamePreviewViewTheme.swift

import MacaroonUIKit

struct AccountNamePreviewViewTheme:
    LayoutSheet,
    StyleSheet {
    var title: TextStyle
    var titleContentEdgeInsets: LayoutPaddings
    var subtitle: TextStyle
    var subtitleContentEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        title = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main)
        ]
        titleContentEdgeInsets = (2, 0, 2, 0)
        subtitle = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.grayLighter)
        ]
        subtitleContentEdgeInsets = (0, 0, 2, 0)
    }
}

extension AccountNamePreviewViewTheme {
    mutating func configureForAccountAccountListItemView() {
        titleContentEdgeInsets = (0, 0, 0, 0)
        subtitleContentEdgeInsets = (0, 0, 0, 0)
    }
}
