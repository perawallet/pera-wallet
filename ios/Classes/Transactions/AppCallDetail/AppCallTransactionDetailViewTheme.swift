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

//   AppCallTransactionDetailViewTheme.swift

import MacaroonUIKit

struct AppCallTransactionDetailViewTheme: LayoutSheet, StyleSheet {
    let backgroundColor: Color
    let topSeparator: Separator
    let bottomSeparator: Separator
    let openInPeraExplorerButton: ButtonStyle
    let buttonsCorner: Corner
    let senderViewTheme: TransactionTextInformationViewTheme
    let assetViewTheme: AppCallTransactionAssetInformationViewTheme
    let innerTransactionViewTheme: TransactionAmountInformationViewTheme
    let onCompletionViewTheme: TransactionTextInformationViewTheme
    let textInformationViewCommonTheme: TransactionTextInformationViewTheme
    let feeViewTheme: TransactionAmountInformationViewTheme
    let buttonEdgeInsets: LayoutPaddings
    let openInPeraExplorerButtonLeadingPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let verticalStackViewTopPadding: LayoutMetric
    let bottomPaddingForSeparator: LayoutMetric
    let separatorPadding: LayoutMetric
    let spacingBetweenPropertiesAndActions: LayoutMetric
    let bottomInset: LayoutMetric

    init(_ family: LayoutFamily) {
        backgroundColor = Colors.Defaults.background
        openInPeraExplorerButton = [
            .title("transaction-id-open-peraexplorer".localized),
            .titleColor([.normal(Colors.Button.Secondary.text)]),
            .font(Fonts.DMSans.medium.make(13)),
            .backgroundColor(Colors.Button.Secondary.background)
        ]
        senderViewTheme = TransactionTextInformationViewTheme().configuredForInteraction()
        textInformationViewCommonTheme = TransactionTextInformationViewTheme().configuredForInteraction()
        onCompletionViewTheme = TransactionTextInformationViewTheme().configuredForInteraction()
        feeViewTheme = TransactionAmountInformationViewTheme().configuredForInteraction()
        assetViewTheme = AppCallTransactionAssetInformationViewTheme()
        innerTransactionViewTheme = TransactionAmountInformationViewTheme(
            transactionAmountViewTheme: TransactionAmountViewBiggerTheme()
        ).configuredForInteraction()
        separatorPadding = -20
        buttonsCorner = Corner(radius: 18)
        buttonEdgeInsets = (8, 12, 8, 12)
        openInPeraExplorerButtonLeadingPadding = 16
        verticalStackViewTopPadding = 40
        bottomPaddingForSeparator = 40
        spacingBetweenPropertiesAndActions = 64
        bottomInset = 24
        horizontalPadding = 24
        let separatorColor = Colors.Layer.grayLighter
        let separatorSize: LayoutMetric = 1
        let separatorHorizontalPaddings = (horizontalPadding, horizontalPadding)
        topSeparator = Separator(
            color: separatorColor,
            size: separatorSize,
            position: .top(separatorHorizontalPaddings)
        )
        bottomSeparator = Separator(
            color: Colors.Layer.grayLighter,
            size: separatorSize,
            position: .bottom(separatorHorizontalPaddings)
        )
    }
}
