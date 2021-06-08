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
//  LedgerAccountDetailViewDataSource.swift

import UIKit
import SVProgressHUD

class LedgerAccountDetailViewDataSource: NSObject {

    weak var delegate: LedgerAccountDetailViewDataSourceDelegate?

    private let api: AlgorandAPI

    init(api: AlgorandAPI) {
        self.api = api
        super.init()
    }

    func fetchAssets(for account: Account) {
        guard let assets = account.assets,
              !assets.isEmpty else {
            delegate?.ledgerAccountDetailViewDataSource(self, didReturn: account)
            return
        }

        SVProgressHUD.show(withStatus: "title-loading".localized)

        for (index, asset) in assets.enumerated() {
            if let assetDetail = api.session.assetDetails[asset.id] {
                account.assetDetails.append(assetDetail)

                if index == assets.count - 1 {
                    SVProgressHUD.showSuccess(withStatus: "title-done".localized)
                    SVProgressHUD.dismiss()
                    delegate?.ledgerAccountDetailViewDataSource(self, didReturn: account)
                }
            } else {

                self.api.getAssetDetails(with: AssetFetchDraft(assetId: "\(asset.id)")) { assetResponse in
                    switch assetResponse {
                    case .success(let assetDetailResponse):
                        self.composeAssetDetail(assetDetailResponse.assetDetail, of: account, with: asset.id)
                    case .failure:
                        account.removeAsset(asset.id)
                    }

                    if index == assets.count - 1 {
                        SVProgressHUD.showSuccess(withStatus: "title-done".localized)
                        SVProgressHUD.dismiss()
                        self.delegate?.ledgerAccountDetailViewDataSource(self, didReturn: account)
                    }
                }
            }
        }
    }

    private func composeAssetDetail(_ assetDetail: AssetDetail, of account: Account, with id: Int64) {
        var assetDetail = assetDetail
        setVerifiedIfNeeded(&assetDetail, with: id)
        account.assetDetails.append(assetDetail)
        api.session.assetDetails[id] = assetDetail
    }

    private func setVerifiedIfNeeded(_ assetDetail: inout AssetDetail, with id: Int64) {
        if let verifiedAssets = api.session.verifiedAssets,
            verifiedAssets.contains(where: { verifiedAsset -> Bool in
                verifiedAsset.id == id
            }) {
            assetDetail.isVerified = true
        }
    }
}

protocol LedgerAccountDetailViewDataSourceDelegate: class {
    func ledgerAccountDetailViewDataSource(
        _ ledgerAccountDetailViewDataSource: LedgerAccountDetailViewDataSource,
        didReturn account: Account
    )
}
