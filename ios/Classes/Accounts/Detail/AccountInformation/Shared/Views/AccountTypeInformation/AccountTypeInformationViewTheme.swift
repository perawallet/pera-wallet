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

//   AccountTypeInformationViewTheme.swift

import Foundation
import MacaroonUIKit

struct AccountTypeInformationViewTheme:
    LayoutSheet,
    StyleSheet {
    var title: TextStyle
    var typeIconSize: LayoutSize
    var spacingBetweenTypeIconAndTitle: LayoutMetric
    var spacingBetweenTypeIconAndTypeTitle: LayoutMetric
    var typeTitle: TextStyle
    var spacingBetweenTypeTitleAndTypeFoonote: LayoutMetric
    var typeFootnote: TextStyle
    var spacingBetweenTypeFoonoteAndTypeDescription: LayoutMetric
    var typeDescription: TextStyle

    init(_ family: LayoutFamily) {
        self.title = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.gray)
        ]
        self.typeIconSize = (32, 32)
        self.spacingBetweenTypeIconAndTitle = 12
        self.spacingBetweenTypeIconAndTypeTitle = 12
        self.typeTitle = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main)
        ]
        self.spacingBetweenTypeTitleAndTypeFoonote = 12
        self.typeFootnote = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.gray)
        ]
        self.spacingBetweenTypeFoonoteAndTypeDescription = 12
        self.typeDescription = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray)
        ]
    }
}
