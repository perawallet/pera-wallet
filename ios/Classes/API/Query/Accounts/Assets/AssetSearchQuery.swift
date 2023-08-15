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
//  AssetFetchQuery.swift

import MagpieCore

struct AssetSearchQuery: ObjectQuery {
    var query: String?
    var cursor: String?
    var type: AssetType?
    
    var queryParams: [APIQueryParam] {
        var params: [APIQueryParam] = []
        params.append(.init(.paginator, "cursor"))

        if let cursor = cursor {
            params.append(.init(.cursor, cursor))
        }
        
        if let query = query {
            params.append(.init(.query, query))
        }

        if let type = type {
            let hasCollectible = type == .collectible ? true : false
            params.append(.init(.hasCollectible, hasCollectible))
        }

        return params
    }
}
