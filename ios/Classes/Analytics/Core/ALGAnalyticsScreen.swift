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

//  ALGAnalyticsScreen.swift

import Foundation
import MacaroonVendors

struct ALGAnalyticsScreen: AnalyticsScreen {
    let name: String
    let metadata: ALGAnalyticsMetadata

    init(
        name: ALGAnalyticsScreenName,
        metadata: ALGAnalyticsMetadata = [:]
    ) {
        self.init(
            name: name.rawValue,
            metadata: metadata
        )
    }

    init(
        name: String,
        metadata: ALGAnalyticsMetadata = [:]
    ) {
        self.name = name
        self.metadata = metadata
    }
}

/// <note>
/// Naming convention:
/// Normally, it should match the actual screen name, but since we don't have any standard for
/// naming the screens, there will be some rules till the screen names are standardized.
/// - ...List for the list screens
/// - ...Detail for the detail screens
/// - Use the actual name for other screens
/// Sort:
/// Alphabetical order by value
enum ALGAnalyticsScreenName: String {
    case accountList = "screen_accounts"
    case assetDetail = "screen_asset_detail"
    case collectibleList = "screen_collectibles"
    case contactDetail = "screen_contact_detail"
    case contactList = "screen_contacts"
    case showQR = "screen_show_qr"
    case transactionDetail = "screen_transaction_detail"
}
