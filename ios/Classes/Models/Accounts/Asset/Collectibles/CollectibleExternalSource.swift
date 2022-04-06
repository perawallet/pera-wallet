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

//   CollectibleExternalSource.swift

import Foundation
import UIKit

protocol CollectibleExternalSource {
    var image: UIImage? { get }
    var title: String { get }
    var url: String? { get }
}

struct AlgoExplorerExternalSource: CollectibleExternalSource {
    let image = img("icon-algo-explorer")
    let title = "collectible-detail-algo-explorer".localized

    let url: String?

    init(asset: AssetID, network: ALGAPI.Network) {
        switch network {
        case .mainnet:
            url = "https://algoexplorer.io/asset/\(String(asset))"
        case .testnet:
            url = "https://testnet.algoexplorer.io/asset/\(String(asset))"
        }
    }
}

struct NFTExplorerExternalSource: CollectibleExternalSource {
    let image = img("icon-nft-explorer")
    let title = "collectible-detail-nft-explorer".localized

    let url: String?

    init(asset: AssetID, network: ALGAPI.Network) {
        switch network {
        case .mainnet:
            url = "https://www.nftexplorer.app/asset/\(String(asset))"
        case .testnet:
            url = nil
        }
    }
}
