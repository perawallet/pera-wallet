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
//   TransactionAssetViewModel.swift

import Foundation

class TransactionAssetViewModel {
    private(set) var isVerified = true
    private(set) var assetName: String?
    private(set) var assetId: String?
    private(set) var unitName: String?
    private(set) var isSeparatorHidden = false

    init(assetDetail: AssetDetail?, isLastElement: Bool) {
        setIsVerified(from: assetDetail)
        setAssetName(from: assetDetail)
        setAssetId(from: assetDetail)
        setUnitName(from: assetDetail)
        setIsSeparatorHidden(from: isLastElement)
    }

    private func setIsVerified(from assetDetail: AssetDetail?) {
        if let assetDetail = assetDetail {
            isVerified = assetDetail.isVerified
        } else {
            isVerified = true
        }
    }

    private func setAssetName(from assetDetail: AssetDetail?) {
        if let assetDetail = assetDetail {
            assetName = assetDetail.assetName
        } else {
            assetName = "asset-algos-title".localized
        }
    }

    private func setAssetId(from assetDetail: AssetDetail?) {
        if let assetId = assetDetail?.id {
            self.assetId = "\(assetId)"
        }
    }

    private func setUnitName(from assetDetail: AssetDetail?) {
        unitName = assetDetail?.unitName
    }

    private func setIsSeparatorHidden(from isLastElement: Bool) {
        isSeparatorHidden = isLastElement
    }
}
