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

//   AppCallTransaction.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AppCallTransaction: ALGAPIModel {
    let appID: Int64?
    let onCompletion: OnCompletion?
    let accounts: [PublicKey]?
    let foreignAssets: [Int64]?

    init() {
        self.appID = nil
        self.onCompletion = nil
        self.accounts = nil
        self.foreignAssets = nil
    }
}

extension AppCallTransaction {
    private enum CodingKeys:
        String,
        CodingKey {
        case appID = "application-id"
        case onCompletion = "on-completion"
        case accounts
        case foreignAssets = "foreign-assets"
    }
}

enum OnCompletion:
    RawRepresentable,
    CaseIterable,
    Codable,
    Equatable {
    case noOp
    case optIn
    case closeOut
    case clear
    case update
    case delete
    case other(String)

    var rawValue: String {
        switch self {
        case .noOp: return "noop"
        case .optIn: return "optin"
        case .closeOut: return "closeout"
        case .clear: return "clear"
        case .update: return "update"
        case .delete: return "delete"
        case .other(let aRawValue): return aRawValue
        }
    }

    var uiRepresentation: String {
        switch self {
        case .noOp: return "NoOp"
        case .optIn: return "OptIn"
        case .closeOut: return "CloseOut"
        case .clear: return "ClearState"
        case .update: return "Update"
        case .delete: return "Delete"
        case .other(let aValue): return aValue
        }
    }

    static var allCases: [Self] = [
        .noOp, .optIn, .closeOut, .clear, .update, .delete
    ]

    init() {
        self = .other("")
    }

    init?(
        rawValue: String
    ) {
        let foundCase = Self.allCases.first { $0.rawValue == rawValue }
        self = foundCase ?? .other(rawValue)
    }
}
