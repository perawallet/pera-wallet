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
//   AlgorandBlock.swift

import Magpie

class AlgorandBlock: Model {
    let rewardsRate: UInt64
    let rewardsResidue: UInt64

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rewardsContainer = try container.nestedContainer(keyedBy: RewardsCodingKeys.self, forKey: .block)
        rewardsRate = try rewardsContainer.decode(UInt64.self, forKey: .rewardsRate)
        rewardsResidue = try rewardsContainer.decode(UInt64.self, forKey: .rewardsResidue)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var rewardsContainer = container.nestedContainer(keyedBy: RewardsCodingKeys.self, forKey: .block)
        try rewardsContainer.encode(rewardsRate, forKey: .rewardsRate)
        try rewardsContainer.encode(rewardsResidue, forKey: .rewardsResidue)
    }
}

extension AlgorandBlock {
    private enum CodingKeys: String, CodingKey {
        case block = "block"
    }

    private enum RewardsCodingKeys: String, CodingKey {
        case rewardsRate = "rate"
        case rewardsResidue = "frac"
    }
}
