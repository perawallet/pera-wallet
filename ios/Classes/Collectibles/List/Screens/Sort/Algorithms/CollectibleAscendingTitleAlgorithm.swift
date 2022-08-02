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

//   CollectibleAscendingTitleAlgorithm.swift

import Foundation

struct CollectibleAscendingTitleAlgorithm: CollectibleSortingAlgorithm {
    let id: String
    let name: String

    init() {
        self.id = "cache.value.collectibleAscendingTitleAlgorithm"
        self.name = "title-alphabetically-a-to-z".localized
    }
}

extension CollectibleAscendingTitleAlgorithm {
    func getFormula(
        collectible: CollectibleAsset,
        otherCollectible: CollectibleAsset
    ) -> Bool {
        let collectibleTitle =
        collectible.title ??
        collectible.name ??
        collectible.id.stringWithHashtag

        let otherCollectibleTitle =
        otherCollectible.title ??
        otherCollectible.name ??
        otherCollectible.id.stringWithHashtag

        let comparison = collectibleTitle.localizedCaseInsensitiveCompare(otherCollectibleTitle)
        return comparison == .orderedAscending
    }
}
