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
//  API+Assets.swift

import Foundation
import MagpieCore
import MagpieExceptions

extension ALGAPI {
    @discardableResult
    func searchAssets(
        _ draft: AssetSearchQuery,
        ignoreResponseOnCancelled: Bool,
        onCompleted handler: @escaping (Response.ModelResult<AssetDecorationList>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.assetSearch)
            .method(.get)
            .query(draft)
            .ignoreResponseWhenEndpointCancelled(ignoreResponseOnCancelled)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func searchAssetsForDiscover(
        draft: SearchAssetsForDiscoverDraft,
        onCompleted handler: @escaping (Response.ModelResult<AssetDecorationList>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.assetSearch)
            .method(.get)
            .query(draft)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func fetchAssetDetails(
        _ draft: AssetFetchQuery,
        queue: DispatchQueue,
        ignoreResponseOnCancelled: Bool,
        onCompleted handler: @escaping (Response.ModelResult<AssetDecorationList>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.assets)
            .method(.get)
            .query(draft)
            .ignoreResponseWhenEndpointCancelled(ignoreResponseOnCancelled)
            .completionHandler(handler)
            .responseDispatcher(queue)
            .execute()
    }

    @discardableResult
    func fetchAssetDetail(
        _ draft: AssetDetailFetchDraft,
        ignoreResponseOnCancelled: Bool = true,
        onCompleted handler: @escaping (Response.ModelResult<AssetDecoration>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.assetDetail, args: "\(draft.id)")
            .method(.get)
            .ignoreResponseWhenEndpointCancelled(ignoreResponseOnCancelled)
            .completionHandler(handler)
            .execute()
    }
    
    @discardableResult
    func fetchAssetDetailFromNode(
        _ draft: AssetDetailFetchDraft,
        onCompleted handler: @escaping (Response.ModelResult<AssetDecoration>) -> Void
    ) -> EndpointOperatable {
        let assetDetailHandler: (Response.ModelResult<AssetDetail>) -> Void = { response in
            switch response {
            case .failure(let apiError, let apiModel):
                handler(.failure(apiError, apiModel))
            case .success(let assetDetail):
                let decoration = AssetDecoration(assetDetail: assetDetail)
                handler(.success(decoration))
            }
        }
        
        return EndpointBuilder(api: self)
            .base(.algod(network))
            .path(.assetDetail, args: "\(draft.id)")
            .method(.get)
            .completionHandler(assetDetailHandler)
            .execute()
    }

    @discardableResult
    func sendAssetSupportRequest(
        _ draft: AssetSupportDraft,
        onCompleted handler: @escaping (Response.Result<NoAPIModel, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.assetRequest)
            .method(.post)
            .body(draft)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func getVerifiedAssets(onCompleted handler: @escaping (Response.ModelResult<VerifiedAssetList>) -> Void) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.verifiedAssets)
            .method(.get)
            .query(LimitQuery())
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func getTrendingAssets(onCompleted handler: @escaping (Response.ModelResult<[AssetDecoration.APIModel]>) -> Void) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.trendingAssets)
            .method(.get)
            .completionHandler(handler)
            .execute()
    }
}
