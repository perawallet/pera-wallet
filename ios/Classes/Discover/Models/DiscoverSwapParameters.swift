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

//   DiscoverSwapParameters.swift

import Foundation
import MacaroonUtils

struct DiscoverSwapParameters: JSONModel {
    let action: DiscoverSwapParameters.Action
    let assetIn: AssetID?
    let assetOut: AssetID?
}

extension DiscoverSwapParameters {
    enum Action: String, Codable {
        case buyAlgo = "buy-algo"
        case swapFromAlgo = "swap-from-algo"
        case swapToAsset = "swap-to-token"
        case swapFromAsset = "swap-from-token"
    }
}

extension DiscoverSwapParameters {
    enum CodingKeys: String, CodingKey {
        case action
        case assetIn = "asset_in"
        case assetOut = "asset_out"
    }
}
