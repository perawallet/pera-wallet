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

//   SwapSummaryScreenViewModel.swift

import MacaroonUIKit
import UIKit

struct SwapSummaryScreenViewModel: ViewModel {
    private(set) var receivedInfo: SwapSummaryItemViewModel?
    private(set) var paidInfo: SwapSummaryItemViewModel?
    private(set) var statusInfo: TransactionStatusViewModel?
    private(set) var accountInfo: SwapSummaryAccountViewModel?
    private(set) var algorandFeeInfo: SwapSummaryItemViewModel?
    private(set) var optInFeeInfo: SwapSummaryItemViewModel?
    private(set) var exchangeFeeInfo: SwapSummaryItemViewModel?
    private(set) var peraFeeInfo: SwapSummaryItemViewModel?
    private(set) var priceImpactInfo: SwapSummaryItemViewModel?

    init(
        account: Account,
        quote: SwapQuote,
        parsedTransactions: [ParsedSwapTransaction],
        currencyFormatter: CurrencyFormatter
    ) {
        bindReceivedInfo(
            quote: quote,
            parsedTransactions: parsedTransactions,
            currencyFormatter: currencyFormatter
        )
        bindPaidInfo(
            quote: quote,
            parsedTransactions: parsedTransactions,
            currencyFormatter: currencyFormatter
        )
        bindStatusInfo()
        bindAccountInfo(account)
        bindAlgorandFeeInfo(
            quote: quote,
            parsedTransactions: parsedTransactions,
            currencyFormatter: currencyFormatter
        )
        bindOptInFeeInfo(
            quote: quote,
            parsedTransactions: parsedTransactions,
            currencyFormatter: currencyFormatter
        )
        bindExchangeFeeInfo(
            quote: quote,
            currencyFormatter: currencyFormatter
        )
        bindPeraFeeInfo(
            quote: quote,
            currencyFormatter: currencyFormatter
        )
        bindPriceImpactInfo(quote)
    }
}

extension SwapSummaryScreenViewModel {
    mutating func bindReceivedInfo(
        quote: SwapQuote,
        parsedTransactions: [ParsedSwapTransaction],
        currencyFormatter: CurrencyFormatter
    ) {
        receivedInfo = SwapSummaryReceivedItemViewModel(
            quote: quote,
            parsedTransactions: parsedTransactions,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindPaidInfo(
        quote: SwapQuote,
        parsedTransactions: [ParsedSwapTransaction],
        currencyFormatter: CurrencyFormatter
    ) {
        paidInfo = SwapSummaryPaidItemViewModel(
            quote: quote,
            parsedTransactions: parsedTransactions,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindStatusInfo() {
        statusInfo = TransactionStatusViewModel(.completed)
    }

    mutating func bindAccountInfo(
        _ account: Account
    ) {
        accountInfo = SwapSummaryAccountViewModel(account)
    }

    mutating func bindAlgorandFeeInfo(
        quote: SwapQuote,
        parsedTransactions: [ParsedSwapTransaction],
        currencyFormatter: CurrencyFormatter
    ) {
        algorandFeeInfo = SwapSummaryAlgorandFeeItemViewModel(
            quote: quote,
            parsedTransactions: parsedTransactions,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindOptInFeeInfo(
        quote: SwapQuote,
        parsedTransactions: [ParsedSwapTransaction],
        currencyFormatter: CurrencyFormatter
    ) {
        let containsOptInTransaction = parsedTransactions.contains { $0.purpose == .optIn }
        if !containsOptInTransaction {
            return
        }

        optInFeeInfo = SwapSummaryOptInFeeItemViewModel(
            quote: quote,
            parsedTransactions: parsedTransactions,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindExchangeFeeInfo(
        quote: SwapQuote,
        currencyFormatter: CurrencyFormatter
    ) {
        exchangeFeeInfo = SwapSummaryExchangeFeeItemViewModel(
            quote: quote,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindPeraFeeInfo(
        quote: SwapQuote,
        currencyFormatter: CurrencyFormatter
    ) {
        peraFeeInfo = SwapSummaryPeraFeeItemViewModel(
            quote: quote,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindPriceImpactInfo(
        _ quote: SwapQuote
    ) {
        priceImpactInfo = SwapSummaryPriceImpactItemViewModel(quote)
    }
}
