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

//   CollectibleDescendingTitleAlgorithm.swift

import Foundation

struct CollectibleDescendingTitleAlgorithm: CollectibleSortingAlgorithm {
    let id: String
    let name: String

    init() {
        self.id = "cache.value.collectibleDescendingTitleAlgorithm"
        self.name = "title-alphabetically-z-to-a".localized
    }
}

extension CollectibleDescendingTitleAlgorithm {
    func getFormula(
        collectible: CollectibleAsset,
        otherCollectible: CollectibleAsset
    ) -> Bool {
        let collectibleTitle =
            collectible.title ??
            collectible.name ??
            String(collectible.id)
        let otherCollectibleTitle =
            otherCollectible.title ??
            otherCollectible.name ??
            String(otherCollectible.id)

        if collectibleTitle != otherCollectibleTitle {
            let result = collectibleTitle.localizedCaseInsensitiveCompare(otherCollectibleTitle)
            return result == .orderedDescending
        }

        guard let collectibleOptedInAddress = collectible.optedInAddress else {
            return otherCollectible.optedInAddress == nil
        }

        guard let otherCollectibleOptedInAddress = otherCollectible.optedInAddress else {
            return true
        }

        let result = collectibleOptedInAddress.localizedCaseInsensitiveCompare(otherCollectibleOptedInAddress)
        return result == .orderedDescending
    }
}
