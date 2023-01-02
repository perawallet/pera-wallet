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

//   MobileAPIAssetCache.swift

import Foundation
import MagpieCore

struct MobileAPIAssetCache: AssetCache {
    var eventHandler: EventHandler?

    private let api: ALGAPI
    private let loadingController: LoadingController
    private let sharedDataController: SharedDataController

    init(
        api: ALGAPI,
        loadingController: LoadingController,
        sharedDataController: SharedDataController
    ) {
        self.api = api
        self.loadingController = loadingController
        self.sharedDataController = sharedDataController
    }

    func cacheAssetDetail(_ id: AssetID) {
        if let assetDecoration = sharedDataController.assetDetailCollection[id] {
            eventHandler?(.didCacheAsset(assetDecoration))
            return
        }

        let draft = AssetDetailFetchDraft(id: id)
        let completionHandler: (Response.ModelResult<AssetDecoration>) -> Void = {
            result in
            
            self.loadingController.stopLoading()

            switch result {
            case .success(let assetDecoration):
                self.sharedDataController.assetDetailCollection[id] = assetDecoration
                eventHandler?(.didCacheAsset(assetDecoration))
            case .failure:
                eventHandler?(.didFailCachingAsset)

            }
        }

        loadingController.startLoadingWithMessage("title-loading".localized)

        api.fetchAssetDetail(draft) {
            result in
            switch result {
            case .success:
                completionHandler(result)
            case .failure:
                api.fetchAssetDetailFromNode(
                    draft,
                    onCompleted: completionHandler
                )
            }
        }
    }
}
