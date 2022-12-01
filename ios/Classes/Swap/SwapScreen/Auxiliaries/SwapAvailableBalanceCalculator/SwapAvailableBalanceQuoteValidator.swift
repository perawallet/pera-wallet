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

//   SwapAvailableBalanceQuoteValidator.swift

import Foundation

struct SwapAvailableBalanceQuoteValidator: SwapAvailableBalanceValidator {
    var eventHandler: EventHandler?

    private let account: Account
    private let quote: SwapQuote

    init(
        account: Account,
        quote: SwapQuote
    ) {
        self.account = account
        self.quote = quote
    }

    /// <note>
    /// Returns the remaining balance after min balance for the success case.
    /// Returns the min balance for failure cases.
    func validateAvailableSwapBalance() {
        guard let assetIn = quote.assetIn else { return }

        if assetIn.isAlgo {
            validateAvailableBalanceForAlgo()
            return
        }

        validateAvailableBalanceForAsset()
    }
}

extension SwapAvailableBalanceQuoteValidator {
    private func validateAvailableBalanceForAlgo() {
        guard var amountIn = quote.amountIn else {
            publishEvent(.failure(.amountInNotAvailable))
            return
        }

        addMinBalance(to: &amountIn)
        addPaddingForFee(to: &amountIn)
        addPeraFee(to: &amountIn)

        guard let remainingAlgoBalance = getRemainingAlgoBalance(from: amountIn) else {
            publishEvent(.failure(.insufficientAlgoBalance(amountIn)))
            return
        }

        publishEvent(.validated(remainingAlgoBalance))
    }

    private func validateAvailableBalanceForAsset() {
        var algoAmountToValidate: UInt64 = 0

        addMinBalance(to: &algoAmountToValidate)
        addPaddingForFee(to: &algoAmountToValidate)
        addPeraFee(to: &algoAmountToValidate)

        if getRemainingAlgoBalance(from: algoAmountToValidate) == nil {
            publishEvent(.failure(.insufficientAlgoBalance(algoAmountToValidate)))
            return
        }

        guard let remainingAssetBalance = getRemainingAssetBalance(from: algoAmountToValidate) else {
            publishEvent(.failure(.insufficientAssetBalance(quote.amountIn!)))
            return
        }

        publishEvent(.validated(remainingAssetBalance))
    }
}

extension SwapAvailableBalanceQuoteValidator {
    private func addMinBalance(
        to amount: inout UInt64
    ) {
        let minBalance = account.calculateMinBalance()
        amount += minBalance
    }

    private func addPaddingForFee(
        to amount: inout UInt64
    ) {
        amount += SwapQuote.feePadding
    }

    private func addPeraFee(
        to amount: inout UInt64
    ) {
        if let peraFee = quote.peraFee {
            amount += peraFee
        }
    }

    private func getRemainingAlgoBalance(
        from amount: UInt64
    ) -> UInt64? {
        let remainingAlgoBalanceResult = account.algo.amount.subtractingReportingOverflow(amount)

        if remainingAlgoBalanceResult.overflow {
            return nil
        }

        return remainingAlgoBalanceResult.partialValue
    }

    private func getRemainingAssetBalance(
        from amount: UInt64
    ) -> UInt64? {
        guard let amountIn = quote.amountIn,
              let assetIn = quote.assetIn,
              let assetInAccount = account[assetIn.id] else {
            return nil
        }

        let remainingAssetBalanceResult = assetInAccount.amount.subtractingReportingOverflow(amountIn)

        if remainingAssetBalanceResult.overflow {
            return nil
        }

        return remainingAssetBalanceResult.partialValue
    }
}

extension SwapAvailableBalanceQuoteValidator {
    enum BalanceValue {
        case balance(UInt64)
        case failure
    }
}
