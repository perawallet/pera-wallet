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

//   CurrencySelection.swift

import Foundation

struct CurrencyID: Equatable {
    var isAlgo: Bool {
        return localValue == Self.kValueALGO
    }
    var isUSD: Bool {
        return localValue == Self.kValueUSD
    }

    var cacheValue: String {
        return makeCacheValue()
    }

    let localValue: String
    let remoteValue: String
    let pairValue: String

    init(
        cacheValue: String?
    ) {
        let components = CurrencyIDComponents(value: cacheValue)

        let localValue = components.localValue
        let pairValue = components.pairValue

        switch localValue {
        case .none:
            let algoPairValue = pairValue ?? Self.kValueUSD
            self.localValue = Self.kValueALGO
            self.remoteValue = algoPairValue
            self.pairValue = algoPairValue
        case .some(let someLocalValue):
            switch someLocalValue {
            case Self.kValueALGO:
                let algoPairValue = pairValue ?? Self.kValueUSD
                self.localValue = someLocalValue
                self.remoteValue = algoPairValue
                self.pairValue = algoPairValue
            default:
                self.localValue = someLocalValue
                self.remoteValue = someLocalValue
                self.pairValue = pairValue ?? Self.kValueALGO
            }
        }
    }

    static func algo(
        pairID: CurrencyID? = nil
    ) -> CurrencyID {
        var components = CurrencyIDComponents()
        components.localValue = kValueALGO
        components.pairValue = pairID?.localValue ?? kValueUSD
        return CurrencyID(cacheValue: components.build())
    }

    static func fiat(
        localValue: String?,
        pairID: CurrencyID? = nil
    ) -> CurrencyID {
        var components = CurrencyIDComponents()
        components.localValue = localValue
        components.pairValue = pairID?.localValue ?? kValueALGO
        return CurrencyID(cacheValue: components.build())
    }
}

extension CurrencyID {
    static func == (
        lhs: CurrencyID,
        rhs: CurrencyID
    ) -> Bool {
        return
            lhs.localValue == rhs.localValue &&
            lhs.pairValue == rhs.pairValue
    }
}

extension CurrencyID {
    private func makeCacheValue() -> String {
        var components = CurrencyIDComponents()
        components.localValue = localValue
        components.pairValue = pairValue
        return components.build()
    }
}

extension CurrencyID {
    private static let kValueALGO = "ALGO"
    private static let kValueUSD = "USD"
}

private struct CurrencyIDComponents {
    var localValue: String?
    var pairValue: String?

    private let separator = "&"

    init(
        value: String? = nil
    ) {
        let components = value?.components(separatedBy: separator)
        self.localValue = components?[safe: 0]
        self.pairValue = components?[safe: 1]
    }

    func build() -> String {
        return [ localValue, pairValue ].compound(separator)
    }
}
