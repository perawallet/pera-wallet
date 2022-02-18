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
//   AssetAdditionPageBarItems.swift

import Foundation
import MacaroonUIKit
import UIKit

struct VerifiedAssetsPageBarItem: PageBarItem {
    let id: String
    let barButtonItem: PageBarButtonItem
    let screen: UIViewController

    init(screen: UIViewController) {
        self.id = AssetAdditionPageBarItemID.verified.rawValue
        self.barButtonItem = PrimaryPageBarButtonItem(title: "asset-verified-title".localized)
        self.screen = screen
    }
}

struct AllAssetsPageBarItem: PageBarItem {
    let id: String
    let barButtonItem: PageBarButtonItem
    let screen: UIViewController

    init(screen: UIViewController) {
        self.id = AssetAdditionPageBarItemID.all.rawValue
        self.barButtonItem = PrimaryPageBarButtonItem(title: "asset-all-title".localized)
        self.screen = screen
    }
}

enum AssetAdditionPageBarItemID: String {
    case verified = "verified"
    case all = "all"
}
