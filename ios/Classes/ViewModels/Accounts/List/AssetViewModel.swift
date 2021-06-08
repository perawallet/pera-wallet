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
//  AssetViewModel.swift

import UIKit

class AssetViewModel {
    private(set) var assetDetail: AssetDetail?
    private(set) var amount: String?

    init(assetDetail: AssetDetail, asset: Asset) {
        setAssetDetail(from: assetDetail)
        setAmount(from: assetDetail, with: asset)
    }

    private func setAssetDetail(from assetDetail: AssetDetail) {
        self.assetDetail = assetDetail
    }

    private func setAmount(from assetDetail: AssetDetail, with asset: Asset) {
        amount = asset.amount.assetAmount(fromFraction: assetDetail.fractionDecimals)
            .toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
    }
}
