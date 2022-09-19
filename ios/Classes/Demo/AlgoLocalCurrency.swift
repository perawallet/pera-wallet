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

//   AlgoLocalCurrency.swift

import Foundation

/// <todo>
/// Maybe the model support all assets, not just Algo.
struct AlgoLocalCurrency: LocalCurrency {
    let id: CurrencyID
    let name: String?
    let symbol: String?

    init(
        pairID: CurrencyID? = nil
    ) {
        self.id = CurrencyID.algo(pairID: pairID)
        self.name = "title-algorand".localized
        self.symbol = "\u{00A6}"
    }
}
