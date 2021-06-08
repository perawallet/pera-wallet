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
//  Asset.swift

import Magpie

class Asset: Model {
    let creator: String?
    let amount: UInt64
    let isFrozen: Bool?
    let id: Int64
    let isDeleted: Bool?
}

extension Asset {
    enum CodingKeys: String, CodingKey {
        case creator = "creator"
        case amount = "amount"
        case isFrozen = "is-frozen"
        case id = "asset-id"
        case isDeleted = "deleted"
    }
}

extension Asset: Encodable { }

extension Asset: Equatable {
    static func == (lhs: Asset, rhs: Asset) -> Bool {
        return lhs.id == rhs.id && lhs.amount == rhs.amount
    }
}
