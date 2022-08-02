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

//   RemoteCurrency.swift

import Foundation

protocol RemoteCurrency: LocalCurrency {
    var isFault: Bool { get }
    /// The value in fiat currency corresponding 1 algo
    var algoValue: Decimal? { get }
    /// The value in fiat currency corresponding 1 dollar
    var usdValue: Decimal? { get }
    var lastUpdateDate: Date { get }
}

extension RemoteCurrency {
    /// The value in algo corresponding 1 dollar
    var usdToAlgoValue: Decimal? {
        guard let usdValue = usdValue else {
            return nil
        }

        guard let algoValue = algoValue.unwrap(where: { $0 != 0 }) else {
            return nil
        }

        return usdValue / algoValue
    }

    /// The value in usd corresponding 1 algo
    var algoToUSDValue: Decimal? {
        guard let usdToAlgoValue = usdToAlgoValue else {
            return nil
        }

        if usdToAlgoValue == 0 {
            return 0
        }

        return 1 / usdToAlgoValue
    }
}
