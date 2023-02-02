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

//   CollectibleAmountFormatter.swift

import Foundation

final class CollectibleAmountFormatter {
    private let numberFormatter = NumberFormatter()
}

extension CollectibleAmountFormatter {
    func format(
        _ decimal: Decimal
    ) -> String? {
        return format(NSDecimalNumber(decimal: decimal))
    }
    
    func format(
        _ decimalNumber: NSDecimalNumber
    ) -> String? {
        let contextHandler = CollectibleAmountFormattingHandler()
        let rules = contextHandler.makeRules(
            decimalNumber
        )
        let input = contextHandler.makeInput(
            decimalNumber
        )

        applyRules(rules)

        return format(input)
    }

    private func format(
        _ input: CurrencyFormattingContextInput
    ) -> String? {
        let number = input.number

        guard let formattedString = numberFormatter.string(from: number) else {
            return nil
        }

        guard let suffix = input.suffix.unwrapNonEmptyString() else {
            return formattedString
        }

        guard let endIndexOfNumber = formattedString.lastIndex(where: \.isNumber) else {
            return formattedString
        }

        let startIndexOfSuffix = formattedString.index(after: endIndexOfNumber)

        var finalString = formattedString
        finalString.insert(
            contentsOf: suffix,
            at: startIndexOfSuffix
        )
        return finalString
    }
}

extension CollectibleAmountFormatter {
    private func applyRules(
        _ rules: CollectibleAmountFormattingRules
    ) {
        numberFormatter.locale = rules.locale

        let minimumFractionDigits = rules.minimumFractionDigits ?? 0
        let preferredMaximumFractionDigits = rules.maximumFractionDigits ?? 0
        let maximumFractionDigits = max(minimumFractionDigits, preferredMaximumFractionDigits)

        numberFormatter.roundingMode = rules.roundingMode ?? .halfEven
        numberFormatter.minimumFractionDigits = minimumFractionDigits
        numberFormatter.maximumFractionDigits = maximumFractionDigits
    }
}
