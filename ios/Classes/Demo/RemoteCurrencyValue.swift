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

//   CurrencyResult.swift

import Foundation
import MagpieCore
import MagpieHipo

enum RemoteCurrencyValue: Equatable {
    case available(RemoteCurrency)
    case failure(CurrencyError)
}

extension RemoteCurrencyValue {
    var isAvailable: Bool {
        let currency = try? unwrap()
        return currency != nil
    }
}

extension RemoteCurrencyValue {
    func unwrap() throws -> RemoteCurrency {
        switch self {
        case .available(let currency): return currency
        case .failure(let error): throw error
        }
    }
}

extension RemoteCurrencyValue {
    static func ~= (
        lhs: RemoteCurrencyValue,
        rhs: RemoteCurrencyValue
    ) -> Bool {
        switch (lhs, rhs) {
        case (.available(let lhsCurrency), .available(let rhsCurrency)):
            return lhsCurrency.id == rhsCurrency.id
        case (.failure, .failure):
            return true
        default:
            return false
        }
    }

    static func == (
        lhs: RemoteCurrencyValue,
        rhs: RemoteCurrencyValue
    ) -> Bool {
        switch (lhs, rhs) {
        case (.available(let lhsCurrency), .available(let rhsCurrency)):
            return
                lhsCurrency.id == rhsCurrency.id &&
                lhsCurrency.algoValue == rhsCurrency.algoValue &&
                lhsCurrency.usdValue == rhsCurrency.usdValue
        case (.failure(let lhsError), .failure(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

enum CurrencyError:
    Error,
    Equatable {
    case networkFailed(HIPNetworkError<NoAPIModel>)
    case corrupted
}
