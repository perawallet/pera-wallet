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

//   SwapProvider.swift

import Foundation

enum SwapProvider:
    RawRepresentable,
    CaseIterable,
    Codable,
    Equatable {
    case tinyman
    case tinymanV2
    case vestige
    case unknown(String)

    var rawValue: String {
        switch self {
        case .tinyman: return "tinyman"
        case .tinymanV2: return "tinyman-v2"
        case .vestige: return "vestige-v3"

        case .unknown(let aRawValue): return aRawValue
        }
    }

    static var allCases: [Self] = [
        .tinyman, .tinymanV2, vestige
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
}
