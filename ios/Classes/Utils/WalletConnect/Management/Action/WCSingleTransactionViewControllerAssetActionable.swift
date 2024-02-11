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
//   WCSingleTransactionViewControllerAssetActionable.swift

import Foundation

protocol WCSingleTransactionViewControllerAssetActionable: WCSingleTransactionViewControllerActionable {
    func openInExplorer(_ asset: Asset?)
    func openAssetURL(_ asset: Asset?)
    func displayAssetMetadata(_ asset: Asset?)
    func openAssetDiscovery(_ asset: Asset?)
}

extension WCSingleTransactionViewControllerAssetActionable where Self: WCSingleTransactionViewController {
    func openInExplorer(_ asset: Asset?) {
        if let assetId = asset?.id,
           let currentNetwork = api?.network {
            if currentNetwork == .mainnet {
                if let url = URL(string: "https://explorer.perawallet.app/asset/\(String(assetId))/") {
                    open(url)
                }
                return
            }

            if let url = URL(string: "https://testnet.explorer.perawallet.app/asset/\(String(assetId))/") {
                open(url)
            }
        }
    }

    func openAssetURL(_ asset: Asset?) {
        if let urlString = asset?.url,
           let url = URL(string: urlString) {
            open(url)
        }
    }

    func displayAssetMetadata(_ asset: Asset?) {
        guard let asset = asset,
              let transactionData = try? JSONEncoder().encode(AssetDetailPresenter(asset: asset)),
              let object = try? JSONSerialization.jsonObject(with: transactionData, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) else {
            return
        }

        open(.jsonDisplay(jsonData: data, title: "wallet-connect-transaction-title-metadata".localized), by: .present)
    }

    func openAssetDiscovery(_ asset: Asset?) {
        guard let asset = asset else { return }

        let assetDecoration = AssetDecoration(asset: asset)

        let screen = Screen.asaDiscovery(
            account: nil,
            quickAction: nil,
            asset: assetDecoration
        )
        open(
            screen,
            by: .present
        )
    }
}

private struct AssetDetailPresenter: Encodable {
    let id: Int64
    let creator: String?
    let unitName: String?
    let assetName: String?
    let fractionDecimals: Int
    var isVerified: Bool = false

    init(asset: Asset) {
        let decoration = AssetDecoration(asset: asset)
        id = asset.id
        creator = decoration.creator?.address
        unitName = decoration.unitName
        assetName = decoration.name
        fractionDecimals = decoration.decimals
        isVerified = decoration.verificationTier.isVerified
    }
}

extension AssetDetailPresenter {
    private enum CodingKeys: String, CodingKey {
        case id = "index"
        case creator = "creator"
        case unitName = "unit-name"
        case assetName = "name"
        case isVerified = "is_verified"
        case fractionDecimals = "decimals"
    }
}
