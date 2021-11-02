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
//  TransactionsQuery.swift

import Magpie

struct TransactionsQuery: ObjectQuery {
    let limit: Int?
    let from: String?
    let to: String?
    let next: String?
    let assetId: String?
    
    var queryParams: [QueryParam] {
        var params: [QueryParam] = []
        if let limit = limit {
            params.append(.init(.limit, limit))
        }
        
        if let from = from,
            let to = to {
            params.append(.init(.afterTime, from))
            params.append(.init(.beforeTime, to))
        }
        
        if let next = next {
            params.append(.init(.next, next))
        }
        
        if let assetId = assetId {
            params.append(.init(.assetIdFilter, assetId))
        }
        
        return params
    }
}

struct AccountQuery: ObjectQuery {
    let includesAll: Bool

    var queryParams: [QueryParam] {
        var params: [QueryParam] = []

        if includesAll {
            params.append(.init(.includesAll, includesAll))
        }

        return params
    }
}
