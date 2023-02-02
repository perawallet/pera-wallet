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

//
//   TransactionHistoryHeaderViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct TransactionHistoryHeaderViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let titleLabel: TextStyle
    let shareButton: ButtonStyle
    let filterButton: ButtonStyle

    let buttonHeight: LayoutMetric
    let buttonInset: LayoutMetric
    let horizontalInset: LayoutMetric
    let buttonContentInset: UIEdgeInsets
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.titleLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(15)),
        ]
        self.shareButton = [
            .icon([.normal("icon-csv")]),
            .backgroundImage([.normal("light-button-rect-background")]),
            .title("title-csv".localized),
            .titleColor([.normal(Colors.Helpers.positive)]),
            .font(Fonts.DMSans.medium.make(13))
        ]
        self.filterButton = [
            .icon([.normal("icon-transaction-filter-primary")]),
            .titleColor([.normal(Colors.Helpers.positive)]),
            .title("filter".localized),
            .font(Fonts.DMSans.medium.make(15))
        ]
        self.buttonHeight = 40
        self.buttonInset = 8
        self.horizontalInset = 24
        self.buttonContentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
}
