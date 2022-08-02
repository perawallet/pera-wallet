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
    static func adapt(
        _ item: AssetItem
    ) -> AssetPreviewModel {
        let assetViewModel = AssetViewModel(item)
        let asset = item.asset
        let title = asset.presentation.name.isNilOrEmpty
            ? "title-unknown".localized
            : asset.presentation.name
        return AssetPreviewModel(
            icon: .url(nil, title: title),
            verifiedIcon: asset.presentation.isVerified ? img("icon-verified-shield") : nil,
            title: title,
            subtitle: asset.presentation.unitName,
            primaryAccessory: assetViewModel.amount,
            secondaryAccessory: assetViewModel.valueInCurrency,
            currencyAmount: assetViewModel.valueInUSD,
            asset: asset
        )
    }

    static func adapt(
        _ item: AlgoAssetItem
    ) -> AssetPreviewModel {
        let algoAssetViewModel = AlgoAssetViewModel(item)
        return AssetPreviewModel(
            icon: .algo,
            verifiedIcon: img("icon-verified-shield"),
            title: "Algo",
            subtitle: "ALGO",
            primaryAccessory: algoAssetViewModel.amount,
            secondaryAccessory: algoAssetViewModel.valueInCurrency,
            currencyAmount: algoAssetViewModel.valueInUSD,
            asset: nil
        )
    }

    static func adaptAssetSelection(
        _ item: AssetItem
    ) -> AssetPreviewModel {
        let assetViewModel = AssetViewModel(item)
        let asset = item.asset
        let title = asset.presentation.name.isNilOrEmpty
            ? "title-unknown".localized
            : asset.presentation.name
        return AssetPreviewModel(
            icon: .url(nil, title: asset.presentation.name),
            verifiedIcon: asset.presentation.isVerified ? img("icon-verified-shield") : nil,
            title: title,
            subtitle: "ID \(asset.id)",
            primaryAccessory: assetViewModel.amount,
            secondaryAccessory: assetViewModel.valueInCurrency,
            currencyAmount: assetViewModel.valueInUSD,
            asset: asset
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

    static func adaptRemovingAsset(_ asset: Asset) -> PendingAssetPreviewModel {
        return PendingAssetPreviewModel(
            secondaryImage: asset.presentation.isVerified
                ? img("icon-verified-shield")
                : nil,
            assetPrimaryTitle: asset.presentation.name,
            assetSecondaryTitle: "ID \(asset.id)",
            assetStatus: "asset-removing-status".localized
        )
    }
}
