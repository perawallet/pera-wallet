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

//   Portfolio.swift

import Foundation

struct Portfolio {
    let totalAlgoValue: Decimal
    let totalUSDValueOfAssets: Decimal

    init(
        account: Account
    ) {
        self.init(accounts: [account])
    }

    init(
        accounts: [Account]
    ) {
        var totalAlgoValue: Decimal = 0
        var totalUSDValueOfAssets: Decimal = 0

        accounts.forEach {
            totalAlgoValue += $0.algo.amount.toAlgos
            totalUSDValueOfAssets += $0.totalUSDValueOfAssets ?? 0
        }

        self.totalAlgoValue = totalAlgoValue
        self.totalUSDValueOfAssets = totalUSDValueOfAssets
    }
}
