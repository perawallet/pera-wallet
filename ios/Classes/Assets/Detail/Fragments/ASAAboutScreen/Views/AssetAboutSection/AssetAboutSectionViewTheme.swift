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

//   AssetAboutSectionViewTheme.swift

import Foundation
import UIKit
import MacaroonUIKit

struct AssetAboutSectionViewTheme:
    StyleSheet,
    LayoutSheet {
    var titleEdgeInsets: LayoutPaddings
    var spacingBetweenTitleAndItems: LayoutMetric
    var itemSpacing: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        titleEdgeInsets = (0, 0, 0, 0)
        spacingBetweenTitleAndItems = 14
        itemSpacing = 0
    }
}
