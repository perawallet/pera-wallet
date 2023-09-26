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
//   WCSingleTransactionRequestBottomViewTheme.swift

import Foundation
import MacaroonUIKit

struct WCSingleTransactionRequestBottomViewTheme: LayoutSheet, StyleSheet {
    let showTransactionDetailsButton: ButtonStyle
    let warningLabel: TextStyle
    let warningIcon: ImageStyle
    let networkFeeTitleLabel: TextStyle
    let networkFeeLabel: TextStyle
    let assetIcon: ImageStyle
    let assetTitleLabel: TextStyle
    let assetAmountLabel: TextStyle

    let warningIconTrailingOffset: LayoutMetric
    let warningIconSize: LayoutSize
    let warningIconLeadingOffset: LayoutMetric
    let networkFeeTitleLabelBottomOffset: LayoutMetric
    let networkFeeTitleLabelTrailingOffset: LayoutMetric
    let defaultHorizontalInset: LayoutMetric
    let showTransactionButtonTopOffset: LayoutMetric
    let assetIconSize: LayoutSize
    let assetIconLeadingOffset: LayoutMetric

    init(_ family: LayoutFamily) {
        showTransactionDetailsButton = [
            .titleColor([.normal(Colors.Link.primary)]),
            .font(Fonts.DMSans.bold.make(13))
        ]
        warningLabel = [
            .textColor(Colors.Helpers.negative),
            .font(Fonts.DMSans.medium.make(13))
        ]
        warningIcon = [
            .image("icon-red-warning")
        ]
        networkFeeTitleLabel = [
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(13)),
            .text("single-transaction-request-network-fee-title".localized)
        ]
        networkFeeLabel = [
            .textColor(Colors.Text.main),
            .font(Fonts.DMMono.regular.make(13))
        ]
        assetIcon = []
        assetTitleLabel = [
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(13)),
            .textOverflow(SingleLineText())
        ]
        assetAmountLabel = [
            .textColor(Colors.Text.main),
            .font(Fonts.DMMono.regular.make(13))
        ]

        warningIconTrailingOffset = -8
        warningIconSize = (15, 15)
        warningIconLeadingOffset = -8
        networkFeeTitleLabelBottomOffset = -12
        networkFeeTitleLabelTrailingOffset = 8
        defaultHorizontalInset = 24
        showTransactionButtonTopOffset = -8
        assetIconSize = (20, 20)
        assetIconLeadingOffset = 8
    }
}
