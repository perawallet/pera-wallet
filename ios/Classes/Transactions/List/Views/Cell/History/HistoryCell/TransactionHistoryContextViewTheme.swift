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
//   TransactionHistoryContextViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct TransactionHistoryContextViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let titleLabel: TextStyle
    let titleMinWidthRatio: LayoutMetric
    let minSpacingBetweenTitleAndAmount: LayoutMetric
    let subtitleLabel: TextStyle
    let horizontalInset: LayoutMetric
    let verticalInset: LayoutMetric
    let subtitleTopInset: LayoutMetric
    let amount: TransactionAmountViewTheme

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background

        self.titleLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(15)),
        ]
        self.titleMinWidthRatio = 0.25
        self.minSpacingBetweenTitleAndAmount = 16

        self.subtitleLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.grayLighter),
            .font(Fonts.DMSans.regular.make(13)),
        ]

        self.horizontalInset = 24
        self.verticalInset = 14
        self.subtitleTopInset = 7
        self.amount = TransactionAmountViewSmallerTheme()
    }
}
