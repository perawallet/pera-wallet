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

//   AssetFilterOptionsCache.swift

import Foundation

final class AssetFilterOptionsCache {
    private let userDefaults = UserDefaults.standard
    
    var hideAssetsWithNoBalanceInAssetList: Bool {
        get { userDefaults.bool(forKey: hideAssetsWithNoBalanceInAssetListKey) }
        set { userDefaults.set(newValue, forKey: hideAssetsWithNoBalanceInAssetListKey) }
    }

    var displayCollectibleAssetsInAssetList: Bool {
        get { userDefaults.bool(forKey: displayCollectibleAssetsInAssetListKey) }
        set { userDefaults.set(newValue, forKey: displayCollectibleAssetsInAssetListKey) }
    }

    var displayOptedInCollectibleAssetsInAssetList: Bool {
        get { userDefaults.bool(forKey: displayOptedInCollectibleAssetsInAssetListKey) }
        set { userDefaults.set(newValue, forKey: displayOptedInCollectibleAssetsInAssetListKey) }
    }

    private let hideAssetsWithNoBalanceInAssetListKey = "cache.key.hideAssetsWithNoBalanceInAssetList"
    private let displayCollectibleAssetsInAssetListKey = "cache.key.displayCollectibleAssetsInAssetList"
    private let displayOptedInCollectibleAssetsInAssetListKey = "cache.key.displayOptedInCollectibleAssetsInAssetList"
}
