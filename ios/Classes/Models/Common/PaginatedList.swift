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
//  PaginatedList.swift

import Foundation
import MagpieCore
import MacaroonUtils

class PaginatedList<Item> {
    var nextCursor: String? {
        return next?.queryParameters?[APIParamKey.cursor.rawValue]
    }

    let count: Int
    let next: URL?
    let previous: String?
    let results: [Item]

    init(
        pagination: PaginationComponents,
        results: [Item]
    ) {
        self.count = pagination.count ?? 0
        self.next = pagination.next
        self.previous = pagination.previous
        self.results = results
    }
}

struct Pagination: PaginationComponents {
    var count: Int?
    var next: URL?
    var previous: String?
}

protocol PaginationComponents {
    var count: Int? { get }
    var next: URL? { get }
    var previous: String? { get }
}
