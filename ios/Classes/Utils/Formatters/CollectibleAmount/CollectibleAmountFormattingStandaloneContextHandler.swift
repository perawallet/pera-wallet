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

//   CollectibleAmountFormattingStandaloneContextHandler.swift

import Foundation

struct CollectibleAmountFormattingStandaloneContextHandler: CollectibleAmountFormattingContextHandling {
    func makeRules(
        _ rawNumber: NSDecimalNumber
    ) -> CollectibleAmountFormattingRules {
        var rules = CollectibleAmountFormattingRules()
        rules.roundingMode = .down
        rules.minimumFractionDigits = 0
        rules.maximumFractionDigits = Int(Int8.max)
        return rules
    }

    func makeInput(
        _ rawNumber: NSDecimalNumber
    ) -> CurrencyFormattingContextInput {
        return rawNumber
    }
}
