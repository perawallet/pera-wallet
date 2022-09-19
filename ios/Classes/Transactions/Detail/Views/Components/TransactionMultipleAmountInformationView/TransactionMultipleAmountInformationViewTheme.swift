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
//   TransactionMultipleAmountInformationViewTheme.swift

import Foundation
import MacaroonUIKit

struct TransactionMultipleAmountInformationViewTheme: LayoutSheet, StyleSheet {
    let title: TextStyle
    let minimumSpacingBetweenTitleAndAmount: LayoutMetric
    let amountLeadingPadding: LayoutMetric
    let verticalTransactionAmountViewTheme: VerticalTransactionAmountViewTheme

    init(_ family: LayoutFamily = LayoutFamily.getCurrentLayoutFamily(), transactionAmountViewTheme: VerticalTransactionAmountViewTheme) {
        self.title = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(15))
        ]
        self.minimumSpacingBetweenTitleAndAmount = 16
        self.amountLeadingPadding = 137
        self.verticalTransactionAmountViewTheme = transactionAmountViewTheme
    }

    init(_ family: LayoutFamily) {
        self.init(
            family,
            transactionAmountViewTheme: VerticalTransactionAmountViewSmallerTheme(family)
        )
    }
}
