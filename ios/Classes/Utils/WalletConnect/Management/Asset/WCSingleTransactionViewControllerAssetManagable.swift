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
//   WCSingleTransactionViewControllerAssetManagable.swift

import Foundation

protocol WCSingleTransactionViewControllerAssetManagable:
    WCSingleTransactionViewControllerAssetActionable,
    AssetCachable {
    var asset: Asset? { get set }

    func setCachedAsset(then completion: @escaping EmptyHandler)
}

extension WCSingleTransactionViewControllerAssetManagable where Self: WCSingleTransactionViewController {
    func setCachedAsset(then completion: @escaping EmptyHandler) {
        guard let transactionDetail = transaction.transactionDetail,
              !transactionDetail.isAssetCreationTransaction else {
                  completion()
            return
        }

        guard let assetId = transactionDetail.assetId ?? transactionDetail.assetIdBeingConfigured else {
            if let wcV1Request = transactionRequest.wcV1Request {
                let params = WalletConnectV1RejectTransactionRequestParams(
                    v1Request: wcV1Request,
                    error: .invalidInput(.asset)
                )
                configuration.peraConnect.rejectTransactionRequest(params)
                completion()
                return
            }

            if let wcV2Request = transactionRequest.wcV2Request {
                let params = WalletConnectV2RejectTransactionRequestParams(
                    error: .invalidInput(.asset),
                    v2Request: wcV2Request
                )
                configuration.peraConnect.rejectTransactionRequest(params)
                completion()
                return
            }
            return
        }

        cacheAssetDetail(with: assetId) { [weak self] assetDetail in
            guard let self = self else {
                completion()
                return
            }

            guard let assetDetail = assetDetail else {
                if let wcV1Request = transactionRequest.wcV1Request {
                    let params = WalletConnectV1RejectTransactionRequestParams(
                        v1Request: wcV1Request,
                        error: .invalidInput(.unableToFetchAsset)
                    )
                    configuration.peraConnect.rejectTransactionRequest(params)
                    completion()
                    return
                }

                if let wcV2Request = transactionRequest.wcV2Request {
                    let params = WalletConnectV2RejectTransactionRequestParams(
                        error: .invalidInput(.unableToFetchAsset),
                        v2Request: wcV2Request
                    )
                    configuration.peraConnect.rejectTransactionRequest(params)
                    completion()
                    return
                }
                return
            }


            if assetDetail.isCollectible {
                self.asset = CollectibleAsset(asset: ALGAsset(id: assetId), decoration: assetDetail)
            } else {
                self.asset = StandardAsset(asset: ALGAsset(id: assetId), decoration: assetDetail)
            }

            completion()
        }
    }
}
