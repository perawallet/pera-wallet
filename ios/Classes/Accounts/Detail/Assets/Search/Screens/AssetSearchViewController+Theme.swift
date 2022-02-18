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
//   AssetSearchViewController+Theme.swift

import Foundation
import MacaroonUIKit
import UIKit

extension AssetSearchViewController {
    struct Theme: LayoutSheet, StyleSheet {
        let listBackgroundColor: Color
        let searchInputViewTheme: SearchInputViewTheme
        let topInset: LayoutMetric
        let horizontalPadding: LayoutMetric
        let collectionViewEdgeInsets: LayoutPaddings

        init(_ family: LayoutFamily) {
            self.listBackgroundColor = AppColors.Shared.System.background
            self.searchInputViewTheme = SearchInputViewCommonTheme(
                placeholder: "asset-search-placeholder".localized,
                family: family
            )
            self.topInset = 16
            self.horizontalPadding = 24
            self.collectionViewEdgeInsets = (24, 0, 0, 0)
        }
    }
}
