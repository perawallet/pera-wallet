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
//   AssetCachable.swift

import Foundation

protocol AssetCachable {
    func cacheAssetDetail(with id: Int64, completion: @escaping (AssetDetail?) -> Void)
}

extension AssetCachable where Self: BaseViewController {
    // If the asset detail with id is already cached, returns it.
    // Else, fetches the asset detail from the api and caches it.
    func cacheAssetDetail(with id: Int64, completion: @escaping (AssetDetail?) -> Void) {
        guard let api = api else {
            completion(nil)
            return
        }

        if let assetDetail = api.session.assetDetails[id] {
            completion(assetDetail)
        } else {
            api.getAssetDetails(with: AssetFetchDraft(assetId: "\(id)")) { assetResponse in
                switch assetResponse {
                case .success(let assetDetailResponse):
                    var assetDetail = assetDetailResponse.assetDetail
                    self.setVerifiedIfNeeded(&assetDetail, with: id)
                    api.session.assetDetails[id] = assetDetail
                    completion(assetDetail)
                case .failure:
                    completion(nil)
                }
            }
        }
    }

    private func setVerifiedIfNeeded(_ assetDetail: inout AssetDetail, with id: Int64) {
        if let verifiedAssets = api?.session.verifiedAssets,
            verifiedAssets.contains(where: { verifiedAsset -> Bool in
                verifiedAsset.id == id
            }) {
            assetDetail.isVerified = true
        }
    }
}
