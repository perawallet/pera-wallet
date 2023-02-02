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

//   CurrencyFormattingListItemContextHandler.swift

import Foundation

struct CurrencyFormattingListItemContextHandler: CurrencyFormattingContextHandling {
    func makeRules(
        _ rawNumber: NSDecimalNumber,
        for currency: LocalCurrency?
    ) -> CurrencyFormattingContextRules {
        if shouldRound(rawNumber) {
            return makeRoundingRules(rawNumber)
        } else {
            if let currency = currency, !currency.isAlgo {
                return makeNonRoundingRulesForFiatCurrency(rawNumber)
            } else {
                return makeNonRoundingRules(rawNumber)
            }
        }
    }

    func makeInput(
        _ rawNumber: NSDecimalNumber,
        for currency: LocalCurrency?
    ) -> CurrencyFormattingContextInput {
        if shouldRound(rawNumber) {
            return makeRoundingInput(rawNumber)
        } else {
            if let currency = currency, !currency.isAlgo {
                return makeNonRoundingInputForFiatCurrency(rawNumber)
            } else {
                return rawNumber
            }
        }
    }
}

extension CurrencyFormattingListItemContextHandler {
    private func makeRoundingRules(
        _ rawNumber: NSDecimalNumber
    ) -> CurrencyFormattingContextRules {
        var rules = CurrencyFormattingContextRules()
        rules.roundingMode = .down
        rules.minimumFractionDigits = 2
        rules.maximumFractionDigits = 2
        return rules
    }

    private func makeNonRoundingRules(
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
        case 1..<10:
            rules.minimumFractionDigits = 2
            rules.maximumFractionDigits = 4
        case 10..<10_000:
            rules.minimumFractionDigits = 2
            rules.maximumFractionDigits = 2
        default:
            rules.minimumFractionDigits = 0
            rules.maximumFractionDigits = 0
        }

        return rules
    }

    private func makeNonRoundingRulesForFiatCurrency(
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
}

extension CurrencyFormattingListItemContextHandler {
    private func shouldRound(
        _ rawNumber: NSDecimalNumber
    ) -> Bool {
        let minRoundingNumber = NSDecimalNumber(decimal: 1_000_000)
        return rawNumber.compare(minRoundingNumber) != .orderedAscending
    }

    private func makeRoundingInput(
        _ rawNumber: NSDecimalNumber
    ) -> CurrencyFormattingContextInput {
        let rounder = NumberRounder()
        rounder.roundingMode = .down
        rounder.supportedRoundingUnits = [
            MillionNumberRoundingUnit(),
            BillionNumberRoundingUnit(),
            TrillionNumberRoundingUnit(),
            QuadrillionNumberRoundingUnit(),
            QuintillionNumberRoundingUnit()
        ]
        return rounder.round(rawNumber)
    }

    private func makeNonRoundingInputForFiatCurrency(
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
