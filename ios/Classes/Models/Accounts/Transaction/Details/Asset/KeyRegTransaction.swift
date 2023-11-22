// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   KeyRegTransaction.swift

import Foundation

struct KeyRegTransaction: ALGAPIModel {
    let voteParticipationKey: String?
    let selectionParticipationKey: String?
    let stateProofKey: String?
    let voteFirstValid: UInt64?
    let voteLastValid: UInt64?
    let voteKeyDilution: UInt64?
    let nonParticipation: Bool

    init() {
        self.voteParticipationKey = nil
        self.selectionParticipationKey = nil
        self.stateProofKey = nil
        self.voteFirstValid = nil
        self.voteLastValid = nil
        self.voteKeyDilution = nil
        self.nonParticipation = false
    }
}

extension KeyRegTransaction {
    var isOnlineKeyRegTransaction: Bool {
        guard
            let voteParticipationKey,
            let selectionParticipationKey,
            voteKeyDilution != nil,
            voteFirstValid != nil,
            voteLastValid != nil
        else {
            return false
        }

        return !voteParticipationKey.isEmptyOrBlank && !selectionParticipationKey.isEmptyOrBlank
    }
}

extension KeyRegTransaction {
    private enum CodingKeys:
        String,
        CodingKey {
        case voteParticipationKey = "vote-participation-key"
        case selectionParticipationKey = "selection-participation-key"
        case stateProofKey = "state-proof-key"
        case voteFirstValid = "vote-first-valid"
        case voteLastValid = "vote-last-valid"
        case voteKeyDilution = "vote-key-dilution"
        case nonParticipation = "non-participation"
    }
}
