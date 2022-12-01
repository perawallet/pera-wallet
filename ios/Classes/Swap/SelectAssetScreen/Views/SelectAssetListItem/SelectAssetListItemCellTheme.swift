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

//   SelectAssetListItemCellTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SelectAssetListItemCellTheme:
    StyleSheet,
    LayoutSheet {
    var context: AssetListItemTheme
    var contextEdgeInsets: LayoutPaddings
    var spacingBetweenContextAndAccessory: LayoutMetric
    var separator: Separator

    init(
        _ family: LayoutFamily
    ) {
        self.context = AssetListItemTheme(family)
        self.contextEdgeInsets = (20, 24, 20, 24)
        self.spacingBetweenContextAndAccessory = 12
        self.separator = Separator(color: Colors.Layer.grayLighter, position: .bottom((80, 24)))
    }
}
