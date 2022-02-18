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
//  VerifiedAsset.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class VerifiedAsset: ALGAPIModel {
    let id: Int64

    init() {
        self.id = 0
    }
}

extension VerifiedAsset {
    private enum CodingKeys:
        String,
        CodingKey {
        case id = "asset_id"
    }
}

extension VerifiedAsset: Equatable {
    static func == (lhs: VerifiedAsset, rhs: VerifiedAsset) -> Bool {
        return lhs.id == rhs.id
    }
}
