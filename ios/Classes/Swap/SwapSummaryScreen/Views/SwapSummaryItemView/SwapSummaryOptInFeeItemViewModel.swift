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

//   SwapSummaryOptInFeeItemViewModel.swift

import MacaroonUIKit
import UIKit

struct SwapSummaryOptInFeeItemViewModel: SwapSummaryItemViewModel {
    private(set) var title: TextProvider?
    private(set) var value: TextProvider?

    private lazy var swapAssetValueFormatter = SwapAssetValueFormatter()

    init(
        quote: SwapQuote,
        parsedTransactions: [ParsedSwapTransaction],
        currencyFormatter: CurrencyFormatter
    ) {
        bindTitle()
        bindValue(
            quote: quote,
            parsedTransactions: parsedTransactions,
            currencyFormatter: currencyFormatter
        )
    }
}

extension SwapSummaryOptInFeeItemViewModel {
    mutating func bindTitle() {
        title = "swap-summary-opt-in-fee-title"
            .localized
            .bodyRegular(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindValue(
        quote: SwapQuote,
        parsedTransactions: [ParsedSwapTransaction],
        currencyFormatter: CurrencyFormatter
    ) {
        let optInTransactins = parsedTransactions.filter { $0.purpose == .optIn }
        let totalOptInFees = optInTransactins.reduce(0, { $0 + $1.allFees }).toAlgos

        value = swapAssetValueFormatter.getFormattedAlgoAmount(
            decimalAmount: totalOptInFees,
            currencyFormatter: currencyFormatter
        )?.bodyRegular(lineBreakMode: .byTruncatingTail)
    }
}
