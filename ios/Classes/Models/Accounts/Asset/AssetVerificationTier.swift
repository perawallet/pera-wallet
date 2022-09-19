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

//   AssetVerificationTier.swift

import MacaroonUIKit

enum AssetVerificationTier:
    String,
    Codable,
    CaseIterable,
    Equatable {
    case trusted
    case verified
    case unverified
    case suspicious

    var rawValue: String {
        switch self {
        case .trusted: return "trusted"
        case .verified: return "verified"
        case .unverified: return "unverified"
        case .suspicious: return "suspicious"
        }
    }

    init() {
        self = .unverified // default case
    }

    init?(
        rawValue: String
    ) {
        let foundCase = Self.allCases.first { $0.rawValue == rawValue }
        self = foundCase ?? .unverified
    }
}

extension AssetVerificationTier {
    var isTrusted: Bool {
        return self == .trusted
    }
    var isVerified: Bool {
        return self == .verified
    }
    var isUnverified: Bool {
        return self == .unverified
    }
    var isSuspicious: Bool {
        return self == .suspicious
    }
}
