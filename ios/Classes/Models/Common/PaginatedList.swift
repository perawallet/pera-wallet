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
//  PaginatedList.swift

import Magpie

class PaginatedList<T: Model>: Model {
    let count: Int
    let next: URL?
    let previous: String?
    let results: [T]

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        count = try container.decodeIfPresent(Int.self, forKey: .count) ?? 0
        next = try container.decodeIfPresent(URL.self, forKey: .next)
        previous = try container.decodeIfPresent(String.self, forKey: .previous)
        results = try container.decode([T].self, forKey: .results)
    }
}

extension PaginatedList {
    func parsePaginationCursor() -> String? {
        guard let next = next,
              let cursor = next.queryParameters?[RequestParameter.cursor.rawValue] else {
            return nil
        }

        return cursor
    }
}

extension PaginatedList {
    enum CodingKeys: String, CodingKey {
        case count = "count"
        case next = "next"
        case previous = "previous"
        case results = "results"
    }
}
