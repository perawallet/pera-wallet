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
//  PendingAssetViewModel.swift

import Foundation

class PendingAssetViewModel {
    private(set) var assetDetail: AssetDetail?
    private(set) var detail: String?

    init(assetDetail: AssetDetail) {
        setAssetDetail(from: assetDetail)
        setDetail(from: assetDetail)
    }

    private func setAssetDetail(from assetDetail: AssetDetail) {
        self.assetDetail = assetDetail
    }

    private func setDetail(from assetDetail: AssetDetail) {
        if assetDetail.isRecentlyAdded {
            detail = "asset-add-confirmation-title".localized
            return
        }

        detail = "asset-remove-confirmation-title".localized
    }
}
