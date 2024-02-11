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
    var url: URL? { get }
}

struct PeraExplorerExternalSource: CollectibleExternalSource {
    let image = img("icon-pera-logo")
    let title = "collectible-detail-algo-explorer".localized
    let url: URL?

    init(asset: AssetID, network: ALGAPI.Network) {
        url = AlgorandWeb.PeraExplorer.asset(
            isMainnet: network == .mainnet,
            param: String(asset)
        ).link
    }
    
    init(address: String, network: ALGAPI.Network) {
        url = AlgorandWeb.PeraExplorer.address(
            isMainnet: network == .mainnet,
            param: address
        ).link
    }
}
