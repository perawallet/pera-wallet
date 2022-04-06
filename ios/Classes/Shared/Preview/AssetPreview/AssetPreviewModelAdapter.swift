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
//   AssetPreviewModelAdapter.swift

import Foundation
import UIKit

enum AssetPreviewModelAdapter {
    static func adapt(_ adaptee: (asset: Asset, currency: Currency?)) -> AssetPreviewModel {
        let assetViewModel = AssetViewModel(asset: adaptee.asset, currency: adaptee.currency)
        return AssetPreviewModel(
            icon: nil,
            verifiedIcon: adaptee.asset.presentation.isVerified ? img("icon-verified-shield") : nil,
            title: adaptee.asset.presentation.name,
            subtitle: adaptee.asset.presentation.unitName,
            primaryAccessory: assetViewModel.amount,
            secondaryAccessory: assetViewModel.currencyAmount
        )
    }

    static func adapt(_ adaptee: (account: Account, currency: Currency?)) -> AssetPreviewModel {
        let algoAssetViewModel = AlgoAssetViewModel(account: adaptee.account, currency: adaptee.currency)
        return AssetPreviewModel(
            icon: .algo,
            verifiedIcon: img("icon-verified-shield"),
            title: "Algo",
            subtitle: "ALGO",
            primaryAccessory: algoAssetViewModel.amount,
            secondaryAccessory: algoAssetViewModel.currencyAmount
        )
    }

    static func adapt(_ asset: Asset) -> AssetPreviewModel {
        return AssetPreviewModel(
            icon: nil,
            verifiedIcon: asset.presentation.isVerified ? img("icon-verified-shield") : nil,
            title: asset.presentation.name,
            subtitle: asset.presentation.unitName,
            primaryAccessory: nil,
            secondaryAccessory: String(asset.id)
        )
    }

    static func adaptAssetSelection(_ adaptee: (asset: Asset, currency: Currency?)) -> AssetPreviewModel {
        let assetViewModel = AssetViewModel(asset: adaptee.asset, currency: adaptee.currency)
        return AssetPreviewModel(
            icon: nil,
            verifiedIcon: adaptee.asset.presentation.isVerified ? img("icon-verified-shield") : nil,
            title: adaptee.asset.presentation.name,
            subtitle: "ID \(adaptee.asset.id)",
            primaryAccessory: assetViewModel.amount,
            secondaryAccessory: assetViewModel.currencyAmount
        )
    }

    static func adaptPendingAsset(_ asset: StandardAsset) -> PendingAssetPreviewModel {
        let status: String
        switch asset.state {
        case let .pending(operation):
            switch operation {
            case .add:
                status = "asset-add-confirmation-title".localized
            case .remove:
                status = "asset-removing-status".localized
            }
        case .ready:
            status = ""
        }

        return PendingAssetPreviewModel(
            secondaryImage: asset.isVerified ? img("icon-verified-shield") : nil,
            assetPrimaryTitle: asset.name,
            assetSecondaryTitle: "ID \(asset.id)",
            assetStatus: status
        )
    }
}
