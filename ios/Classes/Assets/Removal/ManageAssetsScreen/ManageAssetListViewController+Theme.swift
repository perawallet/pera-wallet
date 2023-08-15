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
//   ManageAssetViewListController+Theme.swift

import MacaroonUIKit
import UIKit

extension ManageAssetListViewController {
    struct Theme: LayoutSheet, StyleSheet {
        let background: ViewStyle
        let horizontalPadding: LayoutMetric
        
        let title: TextStyle
        let titleTopPadding: LayoutMetric
        
        let subtitle: TextStyle
        let subtitleText: EditText
        let subtitleTopPadding: LayoutMetric
        
        let searchInputTheme: SearchInputViewTheme
        let searchInputTopPadding: LayoutMetric
        
        let searchInputBackground: Effect
        let spacingBetweenSearchInputAndSearchInputBackground: LayoutMetric
        
        let listViewBackgroundColor: Color
        let listTopPadding: LayoutMetric

        init(_ family: LayoutFamily) {
            self.background = [
                .backgroundColor(Colors.Defaults.background)
            ]
            
            self.horizontalPadding = 24
            
            let titleText =
                "asset-opt-out-title"
                    .localized
                    .titleMedium(lineBreakMode: .byTruncatingTail)
            self.title = [
                .text(titleText),
                .textOverflow(SingleLineText()),
                .textColor(Colors.Text.main)
            ]
            self.titleTopPadding = 32
            
            self.subtitle = [
                .textOverflow(FittingText()),
            ]

            var subtitleAttributes = Typography.bodyRegularAttributes()
            subtitleAttributes.insert(.textColor(Colors.Text.gray))

            self.subtitleText = .attributedString(
                "asset-remove-subtitle"
                    .localized
                    .attributed(
                        subtitleAttributes
                    )
            )

            self.subtitleTopPadding = 16
            
            self.searchInputTheme = SearchInputViewCommonTheme(
                placeholder: "account-detail-assets-search".localized,
                family: family
            )
            self.searchInputTopPadding = 40
            
            var gradient = Gradient()
            gradient.colors = [
                Colors.Defaults.background.uiColor,
                Colors.Defaults.background.uiColor.withAlphaComponent(0)
            ]
            self.searchInputBackground = LinearGradientEffect(gradient: gradient)
            self.spacingBetweenSearchInputAndSearchInputBackground = 36
            
            self.listViewBackgroundColor = Colors.Defaults.background
            self.listTopPadding = 20
        }
    }
}
