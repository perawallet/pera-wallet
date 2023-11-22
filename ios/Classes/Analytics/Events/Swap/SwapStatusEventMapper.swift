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

//   SwapStatusEventMapper.swift

import Foundation
import SwiftDate

struct SwapStatusEventMapper {
    private lazy var swapAssetValueFormatter = SwapAssetValueFormatter()
    private lazy var currencyFormatter = CurrencyFormatter()

    private let quote: SwapQuote
    private let parsedTransactions: [ParsedSwapTransaction]
    private let currency: CurrencyProvider

    init(
        quote: SwapQuote,
        parsedTransactions: [ParsedSwapTransaction],
        currency: CurrencyProvider
    ) {
        self.quote = quote
        self.parsedTransactions = parsedTransactions
        self.currency = currency
    }

    mutating func mapEventParams() -> SwapStatusEventParams? {
        guard let assetIn = quote.assetIn,
              let assetOut = quote.assetOut,
              let amountIn = quote.amountIn,
              let amountOut = quote.amountOut else {
            return nil
        }

        let decimalAmountIn = swapAssetValueFormatter.getDecimalAmount(of: amountIn, for: assetIn)
        let decimalAmountInUSDValue = quote.amountInUSDValue ?? 0
        let amountInAlgoValue = getAlgoValue(of: decimalAmountInUSDValue) ?? 0

        let decimalAmountOut = swapAssetValueFormatter.getDecimalAmount(of: amountOut, for: assetOut)
        let decimalAmountOutUSDValue = quote.amountOutUSDValue ?? 0
        let amountOutAlgoValue = getAlgoValue(of: decimalAmountOutUSDValue) ?? 0

        let peraFeeAsAlgo = Decimal(
            sign: .plus,
            exponent: -6,
            significand: Decimal(quote.peraFee ?? 0)
        )
        let peraFeeAsUSD = getUSDValue(of: peraFeeAsAlgo) ?? 0

        let decimalExchangeFee = swapAssetValueFormatter.getDecimalAmount(of: quote.exchangeFee ?? 0, for: assetIn)
        let usdValueOfExchangeFee = (decimalAmountInUSDValue / decimalAmountIn) * decimalExchangeFee
        let exchangeFeeAsAlgo = getAlgoValue(of: usdValueOfExchangeFee) ?? 0

        let swapTransactins = parsedTransactions.filter { $0.purpose != .optIn }
        let networkFeeAsAlgo = swapTransactins.reduce(0, { $0 + $1.allFees }).toAlgos

        return SwapStatusEventParams(
            inputASAID: "\(assetIn.id)",
            inputASAName: swapAssetValueFormatter.getAssetDisplayName(assetIn),
            inputAmountAsASA: decimalAmountIn,
            inputAmountAsUSD: decimalAmountInUSDValue,
            inputAmountAsAlgo: amountInAlgoValue,
            outputASAID: "\(assetOut.id)",
            outputASAName: swapAssetValueFormatter.getAssetDisplayName(assetOut),
            outputAmountAsASA: decimalAmountOut,
            outputAmountAsUSD: decimalAmountOutUSDValue,
            outputAmountAsAlgo: amountOutAlgoValue,
            swapDate: Date().toFormat("MMMM dd, yyyy - HH:mm"),
            swapDateTimestamp: Date().timeIntervalSince1970,
            peraFeeAsUSD: peraFeeAsUSD,
            peraFeeAsAlgo: peraFeeAsAlgo,
            exchangeFeeAsAlgo: exchangeFeeAsAlgo,
            networkFeeAsAlgo: networkFeeAsAlgo,
            swapperAddress: quote.swapperAddress ?? ""
        )
    }
}

extension SwapStatusEventMapper {
    private func getAlgoValue(of usdValue: Decimal) -> Decimal? {
        guard let currencyValue = currency.primaryValue,
              let rawCurrency = try? currencyValue.unwrap(),
              let usdToAlgoValue = rawCurrency.usdToAlgoValue else {
            return nil
        }

        return usdToAlgoValue * usdValue
    }

    private func getUSDValue(of algoValue: Decimal) -> Decimal? {
        guard let currencyValue = currency.primaryValue,
              let rawCurrency = try? currencyValue.unwrap(),
              let algoToUSDValue = rawCurrency.algoToUSDValue else {
            return nil
        }

        return algoToUSDValue * algoValue
    }
}

extension SwapStatusEventMapper {
    struct SwapStatusEventParams {
        let inputASAID: String
        let inputASAName: String
        let inputAmountAsASA: Decimal
        let inputAmountAsUSD: Decimal
        let inputAmountAsAlgo: Decimal
        let outputASAID: String
        let outputASAName: String
        let outputAmountAsASA: Decimal
        let outputAmountAsUSD: Decimal
        let outputAmountAsAlgo: Decimal
        let swapDate: String
        let swapDateTimestamp: Double
        let peraFeeAsUSD: Decimal
        let peraFeeAsAlgo: Decimal
        let exchangeFeeAsAlgo: Decimal
        let networkFeeAsAlgo: Decimal
        let swapperAddress: String
    }
}
