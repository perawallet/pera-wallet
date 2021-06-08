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
//  AccountFetchOperation.swift

import UIKit
import Magpie

typealias AccountFetchHandler = (Account?, Error?) -> Void

class AccountFetchOperation: AsyncOperation {
    let accountInformation: AccountInformation
    let api: AlgorandAPI
    
    var onStarted: EmptyHandler?
    var onCompleted: AccountFetchHandler?
    
    init(accountInformation: AccountInformation, api: AlgorandAPI) {
        self.accountInformation = accountInformation
        self.api = api
        super.init()
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        api.fetchAccount(with: AccountFetchDraft(publicKey: accountInformation.address)) { response in
            switch response {
            case .success(let accountWrapper):
                accountWrapper.account.assets = accountWrapper.account.nonDeletedAssets()
                if accountWrapper.account.isThereAnyDifferentAsset() {
                    self.fetchAssets(for: accountWrapper.account)
                } else {
                    self.onCompleted?(accountWrapper.account, nil)
                }
            case let .failure(error, _):
                if error.isHttpNotFound {
                    self.onCompleted?(Account(accountInformation: self.accountInformation), nil)
                } else {
                    self.onCompleted?(nil, error)
                }
            }
            self.finish()
        }
        
        onStarted?()
    }
    
    func finish(with error: Error? = nil) {
        state = .finished
    }
}

extension AccountFetchOperation {
    private func fetchAssets(for account: Account) {
        guard let assets = account.assets else {
            onCompleted?(account, nil)
            return
        }
        
        var removedAssetCount = 0
        for asset in assets {
            if let assetDetail = api.session.assetDetails[asset.id] {
                account.assetDetails.append(assetDetail)
                
                if assets.count == account.assetDetails.count + removedAssetCount {
                    self.onCompleted?(account, nil)
                }
            } else {
                self.api.getAssetDetails(with: AssetFetchDraft(assetId: "\(asset.id)")) { assetResponse in
                    switch assetResponse {
                    case .success(let assetDetailResponse):
                        self.composeAssetDetail(
                            assetDetailResponse.assetDetail,
                            of: account,
                            with: asset.id,
                            removedAssetCount: &removedAssetCount
                        )
                    case .failure:
                        removedAssetCount += 1
                        account.removeAsset(asset.id)
                        if assets.count == account.assetDetails.count + removedAssetCount {
                            self.onCompleted?(account, nil)
                        }
                    }
                }
            }
        }
    }
    
    private func composeAssetDetail(_ assetDetail: AssetDetail, of account: Account, with id: Int64, removedAssetCount: inout Int) {
        guard let assets = account.assets else {
            onCompleted?(account, nil)
            return
        }
        
        var assetDetail = assetDetail
        setVerifiedIfNeeded(&assetDetail, with: id)
        account.assetDetails.append(assetDetail)
        api.session.assetDetails[id] = assetDetail
        
        if assets.count == account.assetDetails.count + removedAssetCount {
            self.onCompleted?(account, nil)
        }
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
