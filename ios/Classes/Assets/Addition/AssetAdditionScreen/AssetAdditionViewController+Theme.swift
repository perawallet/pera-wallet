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
//   AssetAdditionViewController+Theme.swift

import MacaroonUIKit
import UIKit

extension AssetAdditionViewController {
    struct Theme: LayoutSheet, StyleSheet {
        let backgroundColor: Color

        let searchInputTheme: SearchInputViewTheme
        let searchInputHorizontalPadding: LayoutMetric
        let searchInputTopPadding: LayoutMetric
        
        let searchInputBackground: Effect
        let searchInputBackgroundHeight: LayoutMetric
        
        let listBackgroundColor: Color
        let listTopPadding: LayoutMetric
        
        init(_ family: LayoutFamily) {
            self.backgroundColor = Colors.Defaults.background

            self.searchInputTheme = SearchInputViewCommonTheme(
                placeholder: "asset-search-placeholder".localized,
                family: family
            )
            self.searchInputHorizontalPadding = 24
            self.searchInputTopPadding = 16
            
            var gradient = Gradient()
            gradient.colors = [
                Colors.Defaults.background.uiColor,
                Colors.Defaults.background.uiColor.withAlphaComponent(0)
            ]
            self.searchInputBackground = LinearGradientEffect(gradient: gradient)
            self.searchInputBackgroundHeight = 36

            self.listBackgroundColor = Colors.Defaults.background
            self.listTopPadding = 20
        }
    }
}
