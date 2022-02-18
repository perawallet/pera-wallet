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
//   AlgorandBlock.swift

import Foundation
import MacaroonUtils
import MagpieCore

final class AlgorandBlock: ALGEntityModel {
    let rewardsRate: UInt64
    let rewardsResidue: UInt64

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.rewardsRate = apiModel.block?.rate ?? 0
        self.rewardsResidue = apiModel.block?.frac ?? 0
    }

    func encode() -> APIModel {
        var rewards = APIModel.Rewards()
        rewards.rate = rewardsRate
        rewards.frac = rewardsResidue

        var apiModel = APIModel()
        apiModel.block = rewards
        return apiModel
    }
}

extension AlgorandBlock {
    struct APIModel: ALGAPIModel {
        var block: Rewards?

        init() {
            self.block = nil
        }
    }
}

extension AlgorandBlock.APIModel {
    struct Rewards: ALGAPIModel {
        var rate: UInt64?
        var frac: UInt64?

        init() {
            self.rate = nil
            self.frac = nil
        }
    }
}
