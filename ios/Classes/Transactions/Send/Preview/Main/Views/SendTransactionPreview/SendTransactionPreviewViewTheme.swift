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

//   SendTransactionPreviewViewTheme.swift

import MacaroonUIKit

struct SendTransactionPreviewViewTheme: LayoutSheet, StyleSheet {
    let backgroundColor: Color
    let separator: Separator

    let transactionTextInformationViewTheme: TransactionTextInformationViewTheme
    let transactionActionInformationViewTheme: TransactionActionInformationViewTheme
    let transactionAccountInformationViewCommonTheme: TitledTransactionAccountNameViewTheme
    let commonTransactionAmountInformationViewTheme: TransactionAmountInformationViewTheme
    let smallMultipleAmountInformationViewTheme: TransactionMultipleAmountInformationViewTheme
    let bigMultipleAmountInformationViewTheme: TransactionMultipleAmountInformationViewTheme

    let horizontalPadding: LayoutMetric
    let verticalStackViewSpacing: LayoutMetric
    let verticalStackViewTopPadding: LayoutMetric
    let bottomPaddingForSeparator: LayoutMetric
    let separatorTopPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.separator = Separator(color: Colors.Layer.grayLighter, size: 1)
        self.commonTransactionAmountInformationViewTheme = TransactionAmountInformationViewTheme()
        self.transactionActionInformationViewTheme = TransactionActionInformationViewTheme()
        self.transactionTextInformationViewTheme = TransactionTextInformationViewTheme()
        self.transactionAccountInformationViewCommonTheme = TitledTransactionAccountNameViewTheme(family)

        self.separatorTopPadding = -32
        self.horizontalPadding = 24
        self.verticalStackViewSpacing = 24
        self.verticalStackViewTopPadding = 72
        self.bottomPaddingForSeparator = 65
        self.smallMultipleAmountInformationViewTheme = TransactionMultipleAmountInformationViewTheme(family)
        self.bigMultipleAmountInformationViewTheme = TransactionMultipleAmountInformationViewTheme(
            family,
            transactionAmountViewTheme: VerticalTransactionAmountViewBiggerTheme(family)
        )
    }
}

