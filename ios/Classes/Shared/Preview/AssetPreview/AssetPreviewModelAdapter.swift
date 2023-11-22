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
        let title = asset.naming.name.isNilOrEmpty
            ? "title-unknown".localized
            : asset.naming.name
        return AssetPreviewModel(
            icon: .url(nil, title: title),
            verificationTier: asset.verificationTier,
            title: title,
            subtitle: asset.naming.unitName,
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
            verificationTier: .trusted,
            title: "Algo",
            subtitle: "ALGO",
            primaryAccessory: algoAssetViewModel.amount,
            secondaryAccessory: algoAssetViewModel.valueInCurrency,
            currencyAmount: algoAssetViewModel.valueInUSD,
            asset: item.asset
        )
    }
}
