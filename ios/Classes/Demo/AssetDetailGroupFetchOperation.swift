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
//   AssetDetailGroupFetchOperation.swift


import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class AssetDetailGroupFetchOperation: MacaroonUtils.AsyncOperation {
    typealias Error = HIPNetworkError<NoAPIModel>
    
    var input: Input
    
    private(set) var result: Result<Output, Error> =
        .failure(.unexpected(UnexpectedError(responseData: nil, underlyingError: nil)))
    
    private var ongoingEndpoints: [Int: EndpointOperatable] = [:]

    private let api: ALGAPI
    private let completionQueue: DispatchQueue

    private let apiQueryLimit = 100
    
    init(
        input: Input,
        api: ALGAPI
    ) {
        let address = input.account.unwrap(\.address) ?? ""

        self.input = input
        self.api = api
        self.completionQueue = DispatchQueue(
            label: "pera.queue.operation.assetGroupFetch.\(address)",
            qos: .userInitiated
        )
    }
    
    override func main() {
        if finishIfCancelled() {
            return
        }
        
        if let error = input.error {
            result = .failure(error)
            finish()

            return
        }
        
        guard let account = input.account else {
            result = .failure(.unexpected(UnexpectedError(responseData: nil, underlyingError: nil)))
            finish()

            return
        }
        
        let assets = account.assets.someArray
        let newAssetIDs: [AssetID]
        
        if let cacheAccount = input.cachedAccounts.account(for: account.address) {
            newAssetIDs = assets.compactMap {
                let assetID = $0.id

                if cacheAccount.containsAsset(assetID) {
                    return nil
                } else {
                    return assetID
                }
            }
        } else {
            newAssetIDs = assets.map(\.id)
        }
        
        if self.finishIfCancelled() {
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        var newAssetDetails: [AssetID: AssetDecoration] = [:]
        var error: Error?
        
        newAssetIDs.chunked(by: apiQueryLimit).enumerated().forEach {
            order, subNewAssetIDs in
            
            dispatchGroup.enter()
            
            let endpoint =
                fetchAssetDetails(withIDs: subNewAssetIDs) { [weak self] result in
                    guard let self = self else {return }
                
                    self.ongoingEndpoints[order] = nil
                
                    switch result {
                    case .success(let subAssetDetails):
                        subAssetDetails.forEach {
                            newAssetDetails[$0.id] = $0
                        }
                    case .failure(let subError):
                        switch error {
                        case .none:
                            error = subError
                        case .some where !subError.isCancelled:
                            error = subError
                        default: break
                        }

                        self.cancelOngoingEndpoints()
                    }

                    dispatchGroup.leave()
                }
            ongoingEndpoints[order] = endpoint
        }
        
        dispatchGroup.notify(queue: completionQueue) { [weak self] in
            guard let self = self else { return }
            
            if let error = error {
                account.removeAllAssets()
                self.result = .failure(error)
            } else {
                if self.finishIfCancelled() {
                    return
                }

                var newStandardAssets: [StandardAsset] = []
                var newStandardAssetsIndexer: Account.StandardAssetIndexer = [:]

                var newCollectibles: [CollectibleAsset] = []
                var newCollectibleAssetsIndexer: Account.CollectibleAssetIndexer = [:]

                var optedInAssets: Set<AssetID> = []

                let pendingOptOutAssets = self.input.blockchainRequests.optOutAssets
                var optedOutAssets: Set<AssetID> = Set(pendingOptOutAssets.keys)

                let pendingSendPureCollectibleAssets = self.input.blockchainRequests.sendPureCollectibleAssets
                var sentPureCollectibleAssets: Set<AssetID> = Set(pendingSendPureCollectibleAssets.keys)
                
                assets.enumerated().forEach { index, asset in
                    let id = asset.id
                    
                    if let assetDetail = newAssetDetails[id] ?? self.input.cachedAssetDetails[id] {
                        if assetDetail.isCollectible {
                            let collectible = CollectibleAsset(asset: asset, decoration: assetDetail)
                            collectible.optedInAddress = account.address
                            newCollectibles.append(collectible)
                            newCollectibleAssetsIndexer[asset.id] = newCollectibleAssetsIndexer.count
                        } else {
                            let standardAsset = StandardAsset(asset: asset, decoration: assetDetail)
                            newStandardAssets.append(standardAsset)
                            newStandardAssetsIndexer[asset.id] = newStandardAssetsIndexer.count
                        }
                    }

                    /// <note>
                    /// Check if the opt-in request is granted.
                    if self.input.blockchainRequests.optInAssets[id] != nil {
                        optedInAssets.insert(id)
                    }

                    /// <note>
                    /// Check if the opt-out request is granted assuming initially that all pending
                    /// requests are granted. If it is still opted-in to the account, then we
                    /// determines that the request is still in progress.
                    if pendingOptOutAssets[id] != nil {
                        optedOutAssets.remove(id)
                    }

                    if pendingSendPureCollectibleAssets[id] != nil {
                        let isOwned = asset.amount != 0
                        if isOwned {
                            sentPureCollectibleAssets.remove(id)
                        }
                    }
                }
                
                account.setStandardAssets(
                    newStandardAssets,
                    newStandardAssetsIndexer
                )

                account.setCollectibleAssets(
                    newCollectibles,
                    newCollectibleAssetsIndexer
                )

                let blockchainUpdates = BlockchainAccountBatchUpdates(
                    optedInAssets: optedInAssets,
                    optedOutAssets: optedOutAssets,
                    sentPureCollectibleAssets: sentPureCollectibleAssets
                )
                let output = Output(
                    account: account,
                    newAssetDetails: newAssetDetails,
                    blockchainUpdates: blockchainUpdates
                )
                self.result = .success(output)
            }
            
            self.finish()
        }
    }

    override func finishIfCancelled() -> Bool {
        if !isCancelled {
            return false
        }

        result = .failure(.connection(.init(reason: .cancelled)))
        finish()

        return true
    }
    
    override func cancel() {
        cancelOngoingEndpoints()
        super.cancel()
    }
}

extension AssetDetailGroupFetchOperation {
    private func fetchAssetDetails(
        withIDs ids: [AssetID],
        onComplete handler: @escaping (Result<[AssetDecoration], Error>) -> Void
    ) -> EndpointOperatable {
        let draft = AssetFetchQuery(ids: ids, includeDeleted: true)
        return
            api.fetchAssetDetails(
                draft,
                queue: completionQueue,
                ignoreResponseOnCancelled: false
            ) { result in
                switch result {
                case .success(let assetList):
                    handler(.success(assetList.results))
                case .failure(let apiError, let apiErrorDetail):
                    let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                    handler(.failure(error))
                }
            }
    }
}

extension AssetDetailGroupFetchOperation {
    private func cancelOngoingEndpoints() {
        ongoingEndpoints.forEach {
            $0.value.cancel()
        }
        ongoingEndpoints = [:]
    }
}

extension AssetDetailGroupFetchOperation {
    struct Input {
        var account: Account?
        var cachedAccounts: AccountCollection = []
        var cachedAssetDetails: AssetDetailCollection = []
        var error: AssetDetailGroupFetchOperation.Error?
        var blockchainRequests: BlockchainAccountBatchRequest = .init()
    }
    
    struct Output {
        let account: Account
        let newAssetDetails: [AssetID: AssetDecoration]
        let blockchainUpdates: BlockchainAccountBatchUpdates
    }
}
