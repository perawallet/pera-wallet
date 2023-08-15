// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ManageAssetListLoadingViewTheme.swift

import MacaroonUIKit
import UIKit

struct ManageAssetListLoadingViewTheme:
    LayoutSheet,
    StyleSheet {
    let asset: ManageAssetListItemLoadingViewTheme
    let assetHeight: CGFloat
    let assetSeparator: Separator
    let numberOfAssets: Int
    
    init(_ family: LayoutFamily) {
        self.asset = ManageAssetListItemLoadingViewTheme(family)
        self.assetHeight = 87
        self.assetSeparator = Separator(
            color: Colors.Layer.grayLighter,
            size: 1,
            position: .bottom((56, 0))
        )
        self.numberOfAssets = 2
    }
}
