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

//   TransactionType.swift

import Foundation

enum TransactionType:
    ALGAPIModel,
    RawRepresentable,
    CaseIterable,
    Hashable {
    case applicationCall
    case assetConfig
    case assetFreeze
    case assetTransfer
    case keyreg
    case payment
    case unsupported(String)

    var rawValue: String {
        switch self {
        case .applicationCall: return "appl"
        case .assetConfig: return "acfg"
        case .assetFreeze: return "afrz"
        case .assetTransfer: return "axfer"
        case .keyreg: return "keyreg"
        case .payment: return "pay"
        case .unsupported(let someType): return someType
        }
    }

    static var allCases: [TransactionType] = [
        .applicationCall,
        .assetConfig,
        .assetFreeze,
        .assetTransfer,
        .keyreg,
        .payment
    ]

    init() {
        self = .random()
    }

    init?(rawValue: String) {
        let someType = Self.allCases.first(matching: (\.rawValue, rawValue))
        self = someType ?? .unsupported(rawValue)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

    static func == (
        lhs: TransactionType,
        rhs: TransactionType
    ) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension TransactionType {
    static func random() -> TransactionType {
        return .unsupported(UUID().uuidString)
    }
}
