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

//   CollectibleFilterOptions.swift

struct CollectibleFilterOptions {
    var displayOptedInCollectibleAssetsInCollectibleList: Bool {
        get { cache.displayOptedInCollectibleAssetsInCollectibleList }
        set { cache.displayOptedInCollectibleAssetsInCollectibleList = newValue }
    }

    var displayWatchAccountCollectibleAssetsInCollectibleList: Bool {
        get { cache.displayWatchAccountCollectibleAssetsInCollectibleList }
        set { cache.displayWatchAccountCollectibleAssetsInCollectibleList = newValue }
    }

    private let cache: CollectibleFilterOptionsCache

    init(cache: CollectibleFilterOptionsCache = .init()) {
        self.cache = cache
    }
}
