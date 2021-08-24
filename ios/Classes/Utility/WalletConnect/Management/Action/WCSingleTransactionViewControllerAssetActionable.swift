// Copyright 2019 Algorand, Inc.

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
    func openInExplorer(_ assetDetail: AssetDetail?)
    func openAssetURL(_ assetDetail: AssetDetail?)
    func displayAssetMetadata(_ assetDetail: AssetDetail?)
}

extension WCSingleTransactionViewControllerAssetActionable where Self: WCSingleTransactionViewController {
    func openInExplorer(_ assetDetail: AssetDetail?) {
        if let assetId = assetDetail?.id,
           let currentNetwork = api?.network {
            if currentNetwork == .mainnet {
                if let url = URL(string: "https://algoexplorer.io/asset/\(String(assetId))") {
                    open(url)
                }
                return
            }

            if let url = URL(string: "https://testnet.algoexplorer.io/asset/\(String(assetId))") {
                open(url)
            }
        }
    }

    func openAssetURL(_ assetDetail: AssetDetail?) {
        if let urlString = assetDetail?.url,
           let url = URL(string: urlString) {
            open(url)
        }
    }

    func displayAssetMetadata(_ assetDetail: AssetDetail?) {
        guard let assetDetail = assetDetail,
              let transactionData = try? JSONEncoder().encode(AssetDetailPresenter(assetDetail: assetDetail)),
              let object = try? JSONSerialization.jsonObject(with: transactionData, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) else {
            return
        }

        open(.jsonDisplay(jsonData: data, title: "wallet-connect-transaction-title-metadata".localized), by: .present)
    }
}

private struct AssetDetailPresenter: Encodable {
    let creator: String
    let total: UInt64
    let isDefaultFrozen: Bool?
    let unitName: String?
    let assetName: String?
    let url: String?
    let managerKey: String?
    let reserveAddress: String?
    let freezeAddress: String?
    let clawBackAddress: String?
    let fractionDecimals: Int
    let id: Int64
    var isDeleted: Bool?
    var isVerified: Bool = false

    init(assetDetail: AssetDetail) {
        id = assetDetail.id
        creator = assetDetail.creator
        total = assetDetail.total
        isDefaultFrozen = assetDetail.isDefaultFrozen
        unitName = assetDetail.unitName
        assetName = assetDetail.assetName
        url = assetDetail.url
        managerKey = assetDetail.managerKey
        reserveAddress = assetDetail.reserveAddress
        freezeAddress = assetDetail.freezeAddress
        clawBackAddress = assetDetail.clawBackAddress
        fractionDecimals = assetDetail.fractionDecimals
        isDeleted = assetDetail.isDeleted
        isVerified = assetDetail.isVerified
    }
}

extension AssetDetailPresenter {
    private enum CodingKeys: String, CodingKey {
        case id = "index"
        case total = "total"
        case isDefaultFrozen = "default-frozen"
        case unitName = "unit-name"
        case assetName = "name"
        case url = "url"
        case managerKey = "manager"
        case reserveAddress = "reserve"
        case freezeAddress = "freeze"
        case clawBackAddress = "clawback"
        case isVerified = "is_verified"
        case fractionDecimals = "decimals"
        case isDeleted = "deleted"
    }
}
