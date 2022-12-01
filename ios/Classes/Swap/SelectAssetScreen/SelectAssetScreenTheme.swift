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

//   SelectAssetScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SelectAssetScreenTheme:
    StyleSheet,
    LayoutSheet {
    let listBackgroundColor: Color
    let searchInputView: SearchInputViewTheme
    let searchInsets: NSDirectionalEdgeInsets
    let emptySectionInsets: UIEdgeInsets
    let assetSectionInsets: UIEdgeInsets

    init(
        _ family: LayoutFamily
    ) {
        self.listBackgroundColor = Colors.Defaults.background
        self.searchInputView = SearchInputViewCommonTheme(
            placeholder: "asset-search-placeholder".localized,
            family: family
        )
        self.searchInsets = NSDirectionalEdgeInsets((8, 24, .noMetric, 24))
        self.emptySectionInsets = UIEdgeInsets((20, 24, 0, 24))
        self.assetSectionInsets = UIEdgeInsets((16, 0, 0, 0))
    }
}
