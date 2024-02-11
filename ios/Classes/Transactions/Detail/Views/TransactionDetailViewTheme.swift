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
//   TransactionDetailViewTheme.swift

import MacaroonUIKit

struct TransactionDetailViewTheme: LayoutSheet, StyleSheet {
    let backgroundColor: Color
    let separator: Separator
    let openInPeraExplorerButton: ButtonStyle
    let buttonsCorner: Corner

    let transactionAmountInformationViewTheme: TransactionAmountInformationViewTheme
    let transactionTextInformationViewTransactionIDTheme: TransactionTextInformationViewTheme
    let transactionTextInformationViewCommonTheme: TransactionTextInformationViewTheme
    let transactionUserInformationViewTheme: TransactionTextInformationViewTheme
    let commonTransactionAmountInformationViewTheme: TransactionAmountInformationViewTheme
    let transactionStatusInformationViewTheme: TransactionStatusInformationViewTheme
    let transactionContactInformationViewTheme: TransactionContactInformationViewTheme

    let buttonEdgeInsets: LayoutPaddings
    let openInPeraExplorerButtonLeadingPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let verticalStackViewTopPadding: LayoutMetric
    let bottomPaddingForSeparator: LayoutMetric
    let separatorTopPadding: LayoutMetric
    let spacingBetweenPropertiesAndActions: LayoutMetric
    let bottomInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.separator = Separator(color: Colors.Layer.grayLighter, size: 1)
        self.openInPeraExplorerButton = [
            .title("transaction-id-open-peraexplorer".localized),
            .titleColor([.normal(Colors.Button.Secondary.text)]),
            .font(Fonts.DMSans.medium.make(13)),
            .backgroundColor(Colors.Button.Secondary.background)
        ]
        self.transactionAmountInformationViewTheme = TransactionAmountInformationViewTheme(
            transactionAmountViewTheme: TransactionAmountViewBiggerTheme()
        ).configuredForInteraction()
        self.transactionTextInformationViewTransactionIDTheme = TransactionTextInformationViewTheme().configuredForInteraction()
        self.commonTransactionAmountInformationViewTheme = TransactionAmountInformationViewTheme().configuredForInteraction()
        self.transactionTextInformationViewCommonTheme = TransactionTextInformationViewTheme().configuredForInteraction()
        self.transactionUserInformationViewTheme = TransactionTextInformationViewTheme().configuredForInteraction()
        self.transactionStatusInformationViewTheme = TransactionStatusInformationViewTheme().configuredForInteraction()
        self.transactionContactInformationViewTheme = TransactionContactInformationViewTheme().configuredForInteraction()

        self.separatorTopPadding = -20
        self.buttonsCorner = Corner(radius: 18)
        self.buttonEdgeInsets = (8, 12, 8, 12)
        self.openInPeraExplorerButtonLeadingPadding = 16
        self.horizontalPadding = 24
        self.verticalStackViewTopPadding = 40
        self.bottomPaddingForSeparator = 40
        self.spacingBetweenPropertiesAndActions = 64
        self.bottomInset = 24
    }
}
