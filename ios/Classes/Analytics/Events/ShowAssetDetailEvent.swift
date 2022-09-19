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
//  ShowAssetDetailEvent.swift

import Foundation
import MacaroonVendors

struct ShowAssetDetailEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        assetID: AssetID?
    ) {
        self.name = .showAssetDetail
        self.metadata = [
            .assetID: assetID.unwrap(String.init) ?? "algos"
        ]
    }
}

extension AnalyticsEvent where Self == ShowAssetDetailEvent {
    static func showAssetDetail(
        assetID: AssetID?
    ) -> Self {
        return ShowAssetDetailEvent(assetID: assetID)
    }
}
