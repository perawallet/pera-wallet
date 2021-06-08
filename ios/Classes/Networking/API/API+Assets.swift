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
//  API+Assets.swift

import Magpie

extension AlgorandAPI {
    @discardableResult
    func getAssetDetails(
        with draft: AssetFetchDraft,
        then handler: @escaping (Response.ModelResult<AssetDetailResponse>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(indexerBase)
            .path("/v2/assets/\(draft.assetId)")
            .headers(indexerAuthenticatedHeaders())
            .completionHandler(handler)
            .build()
            .send()
    }
    
    @discardableResult
    func searchAssets(
        with draft: AssetSearchQuery,
        then handler: @escaping (Response.ModelResult<PaginatedList<AssetSearchResult>>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/assets/")
            .headers(mobileApiHeaders())
            .query(draft)
            .completionHandler(handler)
            .build()
            .send()
    }
    
    @discardableResult
    func sendAssetSupportRequest(with draft: AssetSupportDraft) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/asset-requests/")
            .method(.post)
            .headers(mobileApiHeaders())
            .body(draft)
            .build()
            .send()
    }
    
    @discardableResult
    func getVerifiedAssets(
        then handler: @escaping (Response.ModelResult<VerifiedAssetList>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/verified-assets/")
            .headers(mobileApiHeaders())
            .query(LimitQuery())
            .completionHandler(handler)
            .build()
            .send()
    }
}
