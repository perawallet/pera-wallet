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
//   AssetCachable.swift

import Foundation
import MagpieCore

protocol AssetCachable {
    func cacheAssetDetail(with id: Int64, completion: @escaping (AssetDecoration?) -> Void)
}

extension AssetCachable where Self: BaseViewController {
    // If the asset detail with id is already cached, returns it.
    // Else, fetches the asset detail from the api/node and caches it.
    func cacheAssetDetail(with id: Int64, completion: @escaping (AssetDecoration?) -> Void) {
        if let assetDecoration = self.sharedDataController.assetDetailCollection[id] {
            completion(assetDecoration)
            return
        }

        guard let api = api else {
            completion(nil)
            return
        }

        let draft = AssetDetailFetchDraft(id: id)
        let completionHandler: (Response.ModelResult<AssetDecoration>) -> Void = {
            [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let assetDecoration):
                self.sharedDataController.assetDetailCollection[id] = assetDecoration
                completion(assetDecoration)
            case .failure:
                completion(nil)
            }
        }

        api.fetchAssetDetail(draft) {
            [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                completionHandler(result)
            case .failure:
                guard let api = self.api else {
                    completion(nil)
                    return
                }

                api.fetchAssetDetailFromNode(
                    draft,
                    onCompleted: completionHandler
                )
            }
        }
    }
}
