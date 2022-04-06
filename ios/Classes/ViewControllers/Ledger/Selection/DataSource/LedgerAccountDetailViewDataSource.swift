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
//  LedgerAccountDetailViewDataSource.swift

import MacaroonUtils
import UIKit

final class LedgerAccountDetailViewDataSource: NSObject {
    weak var delegate: LedgerAccountDetailViewDataSourceDelegate?

    private let sharedDataController: SharedDataController
    private let api: ALGAPI
    private let loadingController: LoadingController?

    init(
        sharedDataController: SharedDataController,
        api: ALGAPI,
        loadingController: LoadingController?
    ) {
        self.sharedDataController = sharedDataController
        self.api = api
        self.loadingController = loadingController

        super.init()
    }

    func fetchAssets(for account: Account) {
        guard let assets = account.assets,
              !assets.isEmpty else {
            delegate?.ledgerAccountDetailViewDataSource(self, didReturn: account)
            return
        }

        loadingController?.startLoadingWithMessage("title-loading".localized)

        var assetsToBeFetched: [AssetID] = []

        for asset in assets {
            if self.sharedDataController.assetDetailCollection[asset.id] == nil {
                assetsToBeFetched.append(asset.id)
            }
        }

        api.fetchAssetDetails(
            AssetFetchQuery(ids: assetsToBeFetched),
            queue: .main,
            ignoreResponseOnCancelled: false
        ) { [weak self] assetResponse in
            guard let self = self else {
                return
            }

            self.loadingController?.stopLoading()

            switch assetResponse {
            case let .success(assetDetailResponse):
                assetDetailResponse.results.forEach {
                    self.sharedDataController.assetDetailCollection[$0.id] = $0
                }

                for asset in assets {
                    if let assetDetail = self.sharedDataController.assetDetailCollection[asset.id] {
                        if assetDetail.isCollectible {
                            let collectible = CollectibleAsset(asset: asset, decoration: assetDetail)
                            account.append(collectible)
                        } else {
                            let standardAsset = StandardAsset(asset: asset, decoration: assetDetail)
                            account.append(standardAsset)
                        }
                    }
                }

                self.delegate?.ledgerAccountDetailViewDataSource(self, didReturn: account)
            case .failure:
                break
            }
        }
    }
}

protocol LedgerAccountDetailViewDataSourceDelegate: AnyObject {
    func ledgerAccountDetailViewDataSource(
        _ ledgerAccountDetailViewDataSource: LedgerAccountDetailViewDataSource,
        didReturn account: Account
    )
}
