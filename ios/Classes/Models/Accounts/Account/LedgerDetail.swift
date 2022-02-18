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
//  LedgerDetail.swift

import Foundation

final class LedgerDetail: Codable {
    let id: UUID?
    let name: String?
    var indexInLedger: Int?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        indexInLedger = try container.decodeIfPresent(Int.self, forKey: .indexInLedger)
    }
    
    init(id: UUID?, name: String?, indexInLedger: Int?) {
        self.id = id
        self.name = name
        self.indexInLedger = indexInLedger
    }
}

extension LedgerDetail {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case indexInLedger = "index"
    }
}
