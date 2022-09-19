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
//   TransactionAmountInformationViewTheme.swift

import MacaroonUIKit
import UIKit

struct TransactionAmountInformationViewTheme:
    LayoutSheet,
    StyleSheet {
    var contentPaddings: NSDirectionalEdgeInsets
    var title: TextStyle
    var minimumSpacingBetweenTitleAndAmount: LayoutMetric
    var amountLeadingPadding: LayoutMetric
    var transactionAmountViewTheme: TransactionAmountViewTheme

    init(
        _ family: LayoutFamily = LayoutFamily.getCurrentLayoutFamily(),
        transactionAmountViewTheme: TransactionAmountViewTheme
    ) {
        self.contentPaddings = .zero
        self.title = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(15))
        ]
        self.minimumSpacingBetweenTitleAndAmount = 16
        self.amountLeadingPadding = 137
        self.transactionAmountViewTheme = transactionAmountViewTheme
    }

    init(
        _ family: LayoutFamily
    ) {
        self.init(
            family,
            transactionAmountViewTheme: TransactionAmountViewSmallerTheme()
        )
    }
}

extension TransactionAmountInformationViewTheme {
    func configuredForInteraction() -> TransactionAmountInformationViewTheme {
        var theme = TransactionAmountInformationViewTheme()
        theme.contentPaddings = .init(top: 12, leading: 24, bottom: 12, trailing: 24)
        return theme
    }
}
