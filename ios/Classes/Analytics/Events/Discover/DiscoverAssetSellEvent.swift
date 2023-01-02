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

//   DiscoverAssetSellEvent.swift

import Foundation
import MacaroonVendors

struct DiscoverAssetSellEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(assetOutID: AssetID?, assetInID: AssetID?) {
        self.name = .discoverAssetSell

        var tempMetaData: ALGAnalyticsMetadata = [:]
        
        if let assetInID = assetInID {
            tempMetaData[.assetInID] = assetInID
        }
        if let assetOutID = assetOutID {
            tempMetaData[.assetOutID] = assetOutID
        }

        self.metadata = tempMetaData
    }
}

extension AnalyticsEvent where Self == DiscoverAssetSellEvent {
    static func sellAssetFromDiscover(assetOutID: AssetID?, assetInID: AssetID?) -> Self {
        return DiscoverAssetSellEvent(assetOutID: assetOutID, assetInID: assetInID)
    }
}
