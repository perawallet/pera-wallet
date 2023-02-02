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

//   CurrencyFormattingContextHandling.swift

import Foundation

protocol CurrencyFormattingContextHandling {
    func makeRules(
        _ rawNumber: NSDecimalNumber,
        for currency: LocalCurrency?
    ) -> CurrencyFormattingContextRules

    func makeInput(
        _ rawNumber: NSDecimalNumber,
        for currency: LocalCurrency?
    ) -> CurrencyFormattingContextInput
}

struct CurrencyFormattingContextRules {
    var roundingMode: RoundingMode?
    var minimumFractionDigits: Int?
    var maximumFractionDigits: Int?
}

extension CurrencyFormattingContextRules {
    typealias RoundingMode = NumberFormatter.RoundingMode
}

/// <todo> Rename to `NumberFormattingContextInput`, since it is also used for `CollectibleAmountFormatter`?
protocol CurrencyFormattingContextInput {
    var number: NSDecimalNumber { get }
    var prefix: String? { get }
    var suffix: String? { get }
}

extension NSDecimalNumber: CurrencyFormattingContextInput {
    var number: NSDecimalNumber {
        return self
    }
    var prefix: String? {
        return nil
    }
    var suffix: String? {
        return nil
    }
}

extension NumberRoundingResult: CurrencyFormattingContextInput {
    var prefix: String? {
        return nil
    }
    var suffix: String? {
        return abbreviation?.short
    }
}

struct FiatCurrencyMinimumNonZeroInput: CurrencyFormattingContextInput {
    let number: NSDecimalNumber = 0.000001
    let prefix: String? = "<"
    let suffix: String? = nil
}
