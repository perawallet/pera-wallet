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

//   DiscoverAssetParameters.swift

import Foundation
import MacaroonUtils

struct DiscoverAssetParameters: JSONModel {
    let assetID: String
    let poolID: String?

    init(assetID: String) {
        self.assetID = assetID
        self.poolID = nil
    }

    init(asset: Asset) {
        if asset.isAlgo {
            self.assetID = "ALGO"
        } else {
            self.assetID = String(asset.id)
        }
        self.poolID = nil
    }
}

extension DiscoverAssetParameters {
    enum CodingKeys: String, CodingKey {
        case assetID = "tokenId"
        case poolID = "poolId"
    }
}
