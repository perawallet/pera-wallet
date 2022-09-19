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

//   ASADiscoveryScreenAPIDataController.swift

import Foundation
import MagpieHipo

final class ASADiscoveryScreenAPIDataController: ASADiscoveryScreenDataController {
    var account: Account?
    var eventHandler: EventHandler?

    private(set) var asset: Asset

    private let api: ALGAPI
    private let sharedDataController: SharedDataController

    init(
        account: Account?,
        asset: AssetDecoration,
        api: ALGAPI,
        sharedDataController: SharedDataController
    ) {
        self.account = account

        if asset.isCollectible {
            self.asset = CollectibleAsset(decoration: asset)
        } else {
            self.asset = StandardAsset(decoration: asset)
        }

        self.api = api
        self.sharedDataController = sharedDataController
    }
}

extension ASADiscoveryScreenAPIDataController {
    func loadData() {
        if !asset.isFault {
            eventHandler?(.didLoadData)
            return
        }

        eventHandler?(.willLoadData)

        let draft = AssetDetailFetchDraft(id: asset.id)
        api.fetchAssetDetail(draft) {
            [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let newAsset):
                self.asset = StandardAsset(decoration: newAsset)
                self.eventHandler?(.didLoadData)
            case .failure(let apiError, let apiErrorDetail):
                let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                self.eventHandler?(.didFailToLoadData(error))
            }
        }
    }
}

extension ASADiscoveryScreenAPIDataController {
    func hasOptedIn() -> OptInStatus {
        guard let account = account else {
            return .rejected
        }

        return sharedDataController.hasOptedIn(
            assetID: asset.id,
            for: account
        )
    }

    func hasOptedOut() -> OptOutStatus {
        guard let account = account else {
            return .rejected
        }

        return sharedDataController.hasOptedOut(
            assetID: asset.id,
            for: account
        )
    }
}
