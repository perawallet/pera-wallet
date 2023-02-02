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

//   CurrencyFormatter.swift

import Foundation
import MacaroonUtils

/// <todo>
/// Maybe, we should rename it as NumberFormatter since we are using it for non-currency values.
final class CurrencyFormatter {
    static let shared: CurrencyFormatter = .init()

    var formattingContext: CurrencyFormattingContext = .listItem
    var currency: LocalCurrency?

    private let numberFormatter: NumberFormatter

    init() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        self.numberFormatter = numberFormatter
    }
}

extension CurrencyFormatter {
    func format(
        _ double: Double
    ) -> String? {
        return format(Decimal(double))
    }

    func format(
        _ decimal: Decimal
    ) -> String? {
        return format(NSDecimalNumber(decimal: decimal))
    }

    func format(
        _ decimalNumber: NSDecimalNumber
    ) -> String? {
        let contextHandler = formattingContext.makeHandler()
        let rules = contextHandler.makeRules(
            decimalNumber,
            for: currency
        )
        let input = contextHandler.makeInput(
            decimalNumber,
            for: currency
        )

        applyCommonRules()
        applyCurrencyRules()
        applyContextRules(rules)

        return format(input)
    }

    private func format(
        _ input: CurrencyFormattingContextInput
    ) -> String? {
        func finalString(from formattedString: String) -> String {
            var components: [String?] = []
            components.append(input.prefix)
            components.append(formattedString)
            return components.compound(" ")
        }

        let number = input.number

        guard let formattedString = numberFormatter.string(from: number) else {
            return nil
        }

        guard let suffix = input.suffix.unwrapNonEmptyString() else {
            return finalString(from: formattedString)
        }

        guard let endIndexOfNumber = formattedString.lastIndex(where: \.isNumber) else {
            return finalString(from: formattedString)
        }

        var decoratedFormattedString = formattedString
        decoratedFormattedString.insert(
            contentsOf: suffix,
            at: formattedString.index(after: endIndexOfNumber)
        )
        return finalString(from: decoratedFormattedString)
    }
}

extension CurrencyFormatter {
    private func applyCommonRules() {
        numberFormatter.locale = Locale.current
        numberFormatter.nilSymbol = ""
        numberFormatter.notANumberSymbol = CurrencyConstanst.unavailable
    }

    private func applyCurrencyRules() {
        numberFormatter.currencyCode = (currency?.id.localValue).someString
        numberFormatter.currencySymbol = (currency?.symbol).someString
        numberFormatter.internationalCurrencySymbol = (currency?.symbol).someString
    }

    private func applyContextRules(
        _ rules: CurrencyFormattingContextRules
    ) {
        let minimumFractionDigits = rules.minimumFractionDigits ?? 0
        let preferredMaximumFractionDigits = rules.maximumFractionDigits ?? 0
        let maximumFractionDigits = max(minimumFractionDigits, preferredMaximumFractionDigits)

        numberFormatter.roundingMode = rules.roundingMode ?? .halfEven
        numberFormatter.minimumFractionDigits = minimumFractionDigits
        numberFormatter.maximumFractionDigits = maximumFractionDigits
    }
}

enum CurrencyConstanst {
    static let unavailable = "N/A"
}
