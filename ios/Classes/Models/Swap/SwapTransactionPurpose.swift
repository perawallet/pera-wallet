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

//   SwapTransactionPurpose.swift

import Foundation

enum SwapTransactionPurpose:
    RawRepresentable,
    CaseIterable,
    Codable,
    Equatable {
    case optIn
    case swap
    case fee
    case unknown(String)

    var rawValue: String {
        switch self {
        case .optIn: return "opt-in"
        case .swap: return "swap"
        case .fee: return "fee"
        case .unknown(let aRawValue): return aRawValue
        }
    }

    static var allCases: [Self] = [
        .optIn, .swap, .fee
    ]

    init() {
        self = .unknown("")
    }

    init?(
        rawValue: String
    ) {
        let foundCase = Self.allCases.first { $0.rawValue == rawValue }
        self = foundCase ?? .unknown(rawValue)
    }

    var isSupported: Bool {
        if case .unknown = self {
            return false
        }

        return true
    }
}
