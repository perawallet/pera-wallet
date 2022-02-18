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
    let openInAlgoExplorerButton: ButtonStyle
    let openInGoalSeekerButton: ButtonStyle
    let buttonsCorner: Corner

    let transactionTextInformationViewTransactionIDTheme: TransactionTextInformationViewTheme
    let transactionTextInformationViewCommonTheme: TransactionTextInformationViewTheme
    let transactionAccountInformationViewCommonTheme: TitledTransactionAccountNameViewTheme
    let commonTransactionAmountInformationViewTheme: TransactionAmountInformationViewTheme
    let transactionStatusInformationViewTheme: TransactionStatusInformationViewTheme
    let transactionContactInformationViewTheme: TransactionContactInformationViewTheme
    let smallMultipleAmountInformationViewTheme: TransactionMultipleAmountInformationViewTheme
    let bigMultipleAmountInformationViewTheme: TransactionMultipleAmountInformationViewTheme

    let buttonEdgeInsets: LayoutPaddings
    let openInGoalSeekerButtonLeadingPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let verticalStackViewSpacing: LayoutMetric
    let verticalStackViewTopPadding: LayoutMetric
    let bottomPaddingForSeparator: LayoutMetric
    let separatorTopPadding: LayoutMetric
    let bottomInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.separator = Separator(color: AppColors.Shared.Layer.grayLighter, size: 1)
        self.openInAlgoExplorerButton = [
            .title("transaction-id-open-algoexplorer".localized),
            .titleColor([.normal(AppColors.Components.Button.Secondary.text)]),
            .font(Fonts.DMSans.medium.make(13)),
            .backgroundColor(AppColors.Components.Button.Secondary.background)
        ]
        self.openInGoalSeekerButton = [
            .title("transaction-id-open-goalseeker".localized),
            .titleColor([.normal(AppColors.Components.Button.Secondary.text)]),
            .font(Fonts.DMSans.medium.make(13)),
            .backgroundColor(AppColors.Components.Button.Secondary.background)
        ]
        self.transactionTextInformationViewTransactionIDTheme = TransactionTextInformationViewTransactionIDTheme()
        self.commonTransactionAmountInformationViewTheme = TransactionAmountInformationViewTheme()
        self.transactionTextInformationViewCommonTheme = TransactionTextInformationViewCommonTheme()
        self.transactionStatusInformationViewTheme = TransactionStatusInformationViewTheme()
        self.transactionContactInformationViewTheme = TransactionContactInformationViewTheme()
        self.transactionAccountInformationViewCommonTheme = TitledTransactionAccountNameViewTheme(family)

        self.separatorTopPadding = -32
        self.buttonsCorner = Corner(radius: 18)
        self.buttonEdgeInsets = (8, 12, 8, 12)
        self.openInGoalSeekerButtonLeadingPadding = 16
        self.horizontalPadding = 24
        self.verticalStackViewSpacing = 24
        self.verticalStackViewTopPadding = 72
        self.bottomPaddingForSeparator = 65
        self.bottomInset = 24
        self.smallMultipleAmountInformationViewTheme = TransactionMultipleAmountInformationViewTheme(family)
        self.bigMultipleAmountInformationViewTheme = TransactionMultipleAmountInformationViewTheme(
            family,
            transactionAmountViewTheme: VerticalTransactionAmountViewBiggerTheme(family)
        )
    }
}
