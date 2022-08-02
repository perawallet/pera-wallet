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

//   CollectibleDescendingOptedInRoundAlgorithm.swift

import Foundation

struct CollectibleDescendingOptedInRoundAlgorithm: CollectibleSortingAlgorithm {
    let id: String
    let name: String

    init() {
        self.id = "cache.value.collectibleDescendingOptedInRoundAlgorithm"
        self.name = "title-newest-to-oldest".localized
    }
}

extension CollectibleDescendingOptedInRoundAlgorithm {
    func getFormula(
        collectible: CollectibleAsset,
        otherCollectible: CollectibleAsset
    ) -> Bool {
        let collectibleOptedInRound = collectible.optedInAtRound
        let otherCollectibleOptedInRound = otherCollectible.optedInAtRound

        guard let collectibleOptedInRound = collectibleOptedInRound,
              let otherCollectibleOptedInRound = otherCollectibleOptedInRound else {
            return false
        }

        return collectibleOptedInRound > otherCollectibleOptedInRound
    }
}
