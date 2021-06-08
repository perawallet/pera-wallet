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
//  AssetFetchQuery.swift

import Magpie

struct AssetSearchQuery: ObjectQuery {
    let status: AssetSearchFilter
    let query: String?
    let paginator: Paginator = .cursor
    let cursor: String?
    
    var queryParams: [QueryParam] {
        var params: [QueryParam] = []
        params.append(.init(.paginator, paginator.rawValue))

        if let cursor = cursor {
            params.append(.init(.cursor, cursor))
        }
        
        if let query = query {
            params.append(.init(.query, query))
        }
        
        switch status {
        case .all:
            return params
        default:
            if let statusValue = status.stringValue {
                params.append(.init(.status, statusValue))
            }
            return params
        }
    }
}

extension AssetSearchQuery {
    enum Paginator: String {
        case cursor = "cursor"
    }
}

struct TransactionSearchQuery: ObjectQuery {
    let id: String?
    
    var queryParams: [QueryParam] {
        var params: [QueryParam] = []
        if let id = id {
            params.append(.init(.transactionDetailId, id))
        }
        return params
    }
}
