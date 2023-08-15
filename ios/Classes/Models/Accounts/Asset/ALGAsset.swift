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
//  ALGAsset.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class ALGAsset:
    ALGAPIModel,
    Hashable {
    let creator: String?
    let amount: UInt64
    let isFrozen: Bool?
    let id: Int64
    let optedInAtRound: UInt64?

    init() {
        self.creator = nil
        self.amount = 0
        self.isFrozen = nil
        self.id = 1
        self.optedInAtRound = nil
    }

    init(id: AssetID) {
        self.id = id
        self.creator = nil
        self.amount = 0
        self.isFrozen = nil
        self.optedInAtRound = nil
    }

    init(asset: Asset) {
        self.id = asset.id
        self.creator = asset.creator?.address
        self.amount = asset.amount
        self.isFrozen = asset.isFrozen
        self.optedInAtRound = asset.optedInAtRound
    }
}

extension ALGAsset {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(id)
        hasher.combine(amount)
    }
    
    static func == (
        lhs: ALGAsset,
        rhs: ALGAsset
    ) -> Bool {
        return
            lhs.id == rhs.id &&
            lhs.amount == rhs.amount
    }
}

extension ALGAsset {
    private enum CodingKeys:
        String,
        CodingKey {
        case creator
        case amount
        case isFrozen = "is-frozen"
        case id = "asset-id"
        case optedInAtRound = "opted-in-at-round"
    }
}

extension ALGAsset {
    static func usdcAssetID(_ network: ALGAPI.Network) -> AssetID {
        switch network {
        case .mainnet: return 31566704
        case .testnet: return 10458941
        }
    }

    static func usdtAssetID(_ network: ALGAPI.Network) -> AssetID? {
        switch network {
        case .mainnet: return 312769
        case .testnet: return nil /// In the testnet, we don't have a verified USDt, so we assume there is none for now.
        }
    }
}
