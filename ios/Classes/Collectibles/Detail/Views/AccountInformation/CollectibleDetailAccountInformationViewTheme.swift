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

//   CollectibleDetailAccountInformationViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct CollectibleDetailAccountInformationViewTheme:
    StyleSheet,
    LayoutSheet {
    var icon: ImageStyle
    var iconSize: LayoutSize
    var spacingBetweenIconAndTitle: LayoutMetric
    var title: TextStyle
    var titleContentEdgeInsets: LayoutPaddings
    var spacingBetweenTitleAndAmount: LayoutMetric
    var amount: TextStyle
    var amountBorder: Border
    var amountContentEdgeInsets: LayoutPaddings

    init(_ family: LayoutFamily) {
        self.icon = [
            .tintColor(Colors.Text.main)
        ]
        self.iconSize = (16, 16)
        self.spacingBetweenIconAndTitle = 9
        self.title = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main)
        ]
        self.titleContentEdgeInsets = (4, 0, 4, 0)
        self.spacingBetweenTitleAndAmount = 8
        self.amount = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main)
        ]
        self.amountBorder = Border(color: Colors.Layer.grayLighter.uiColor, width: 1)
        self.amountContentEdgeInsets = (3, 11, 3, 11)
    }
}
