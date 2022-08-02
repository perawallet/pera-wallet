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

//   CurrencySelectionLoadingViewTheme.swift

import Foundation
import MacaroonUIKit

struct CurrencySelectionLoadingViewTheme:
    LayoutSheet,
    StyleSheet {
    let corner: Corner
    let titleSize: LayoutSize
    let titleTopPadding: LayoutMetric

    let subtitleSize: LayoutSize
    let subtitleTopPadding: LayoutMetric

    let searchInputTheme: SearchInputViewTheme
    let searchInputHeight: LayoutMetric
    let searchInputTopPadding: LayoutMetric

    let currencySelectionItemsStackSpacing: LayoutMetric
    let currencySelectionItemsStackTopPadding: LayoutMetric

    let xlargeItem: CurrencySelectionItemLoadingViewTheme
    let mediumItem: CurrencySelectionItemLoadingViewTheme
    let largeItem: CurrencySelectionItemLoadingViewTheme
    let smallItem: CurrencySelectionItemLoadingViewTheme

    init(
        _ family: LayoutFamily
    ) {
        self.corner = Corner(radius: 4)

        self.titleSize = (104, 20)
        self.titleTopPadding = 28

        self.subtitleSize = (264, 20)
        self.subtitleTopPadding = 12

        self.searchInputTheme = SearchInputViewCommonTheme(
            placeholder: "settings-currency-search".localized,
            family: family
        )
        self.searchInputHeight = 40
        self.searchInputTopPadding = 44

        self.currencySelectionItemsStackSpacing = 5
        self.currencySelectionItemsStackTopPadding = 12

        self.xlargeItem = CurrencySelectionItemLoadingViewTheme(contentWidth: 123)
        self.mediumItem = CurrencySelectionItemLoadingViewTheme(contentWidth: 73)
        self.largeItem = CurrencySelectionItemLoadingViewTheme(contentWidth: 107)
        self.smallItem = CurrencySelectionItemLoadingViewTheme(contentWidth: 59)
    }
}
