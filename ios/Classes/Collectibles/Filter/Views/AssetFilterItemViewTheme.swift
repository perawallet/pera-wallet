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

//   AssetFilterItemViewTheme.swift

import Foundation
import UIKit
import MacaroonUIKit

struct AssetFilterItemViewTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var minimumHorizontalSpacing: LayoutMetric
    var title: TextStyle
    var titleMaxWidthRatio: LayoutMetric
    var description: TextStyle
    var descriptionTopMargin: LayoutMetric
    var toggle: ToggleTheme

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.minimumHorizontalSpacing = 8
        self.title = [
            .textColor(Colors.Text.main),
            .textOverflow(FittingText())
        ]
        self.titleMaxWidthRatio = 0.7
        self.description = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText())
        ]
        self.descriptionTopMargin = 8
        self.toggle = ToggleTheme(family)
    }
}
