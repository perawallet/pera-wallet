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

//   CurrencyFormattingStandaloneContextHandler.swift

import Foundation

struct CurrencyFormattingStandaloneContextHandler: CurrencyFormattingContextHandling {
    private let constraints: CurrencyFormattingContextRules?

    init(
        constraints: CurrencyFormattingContextRules?
    ) {
        self.constraints = constraints
    }

    func makeRules(
        _ rawNumber: NSDecimalNumber,
        for currency: LocalCurrency?
    ) -> CurrencyFormattingContextRules {
        var rules: CurrencyFormattingContextRules
        if let currency = currency {
            if currency.isAlgo {
                rules = makeRulesForAlgoCurrency(rawNumber)
            } else {
                rules = makeRulesForFiatCurrency(rawNumber)
            }
        } else {
            rules = makeRulesForNoCurrency(rawNumber)
        }

        applyConstraintsIfNeeded(&rules)

        return rules
    }

    func makeInput(
        _ rawNumber: NSDecimalNumber,
        for currency: LocalCurrency?
    ) -> CurrencyFormattingContextInput {
        if let currency = currency, !currency.isAlgo {
            return makeInputForFiatCurrency(rawNumber)
        } else {
            return rawNumber
        }
    }
}

extension CurrencyFormattingStandaloneContextHandler {
    private func makeRulesForAlgoCurrency(
        _ rawNumber: NSDecimalNumber
    ) -> CurrencyFormattingContextRules {
        var rules = CurrencyFormattingContextRules()
        rules.roundingMode = .down
        rules.minimumFractionDigits = 2
        rules.maximumFractionDigits = 6
        return rules
    }

    private func makeRulesForFiatCurrency(
        _ rawNumber: NSDecimalNumber
    ) -> CurrencyFormattingContextRules {
        var rules = CurrencyFormattingContextRules()
        rules.roundingMode = .down

        switch abs(rawNumber.decimalValue) {
        case 0:
            rules.minimumFractionDigits = 2
            rules.maximumFractionDigits = 2
        case 0..<1:
            rules.minimumFractionDigits = 2
            rules.maximumFractionDigits = 6
        default:
            rules.minimumFractionDigits = 2
            rules.maximumFractionDigits = 2
        }

        return rules
    }

    private func makeRulesForNoCurrency(
        _ rawNumber: NSDecimalNumber
    ) -> CurrencyFormattingContextRules {
        var rules = CurrencyFormattingContextRules()
        rules.roundingMode = .down
        rules.minimumFractionDigits = 2
        rules.maximumFractionDigits = Int(Int64.max)
        return rules
    }
}

extension CurrencyFormattingStandaloneContextHandler {
    private func applyConstraintsIfNeeded(
        _ rules: inout CurrencyFormattingContextRules
    ) {
        guard let constraints = constraints else {
            return
        }

        if let roundingMode = constraints.roundingMode {
            rules.roundingMode = roundingMode
        }

        if let minimumFractionDigits = constraints.minimumFractionDigits {
            rules.minimumFractionDigits = minimumFractionDigits
        }

        if let maximumFractionDigits = constraints.maximumFractionDigits {
            rules.maximumFractionDigits = maximumFractionDigits
        }
    }
}

extension CurrencyFormattingStandaloneContextHandler {
    private func makeInputForFiatCurrency(
        _ rawNumber: NSDecimalNumber
    ) -> CurrencyFormattingContextInput {
        let minNonZeroInput = FiatCurrencyMinimumNonZeroInput()
        let minNonZeroValue = minNonZeroInput.number.decimalValue

        switch abs(rawNumber.decimalValue) {
        case 0: return rawNumber
        case 0..<minNonZeroValue: return minNonZeroInput
        default: return rawNumber
        }
    }
}
