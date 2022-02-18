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

//
//   CurrencyHandle.swift

import Foundation
import MagpieCore
import MagpieHipo
import SwiftDate

enum CurrencyHandle: Equatable {
    typealias Error = HIPNetworkError<NoAPIModel>
    
    case idle
    case ready(currency: Currency, lastUpdateDate: Date)
    case failed(Error)
}

extension CurrencyHandle {
    var isAvailable: Bool {
        return value != nil
    }
    var isFailure: Bool {
        switch self {
        case .failed: return true
        default: return false
        }
    }
    var value: Currency? {
        switch self {
        case .ready(let currency, _): return currency
        default: return nil
        }
    }
}

extension CurrencyHandle {
    var isExpired: Bool {
        switch self {
        case .ready(_, let lastUpdateDate):
            let expireDate = lastUpdateDate + validDuration
            return Date.now().isAfterDate(
                expireDate,
                orEqual: true,
                granularity: .second
            )
        default:
            return true
        }
    }
    var validDuration: DateComponents {
        return 1.minutes
    }
}
