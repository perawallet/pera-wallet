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

//   OptInAssetListItemCellTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct OptInAssetListItemCellTheme:
    StyleSheet,
    LayoutSheet {
    var context: OptInAssetListItemViewTheme
    var contextEdgeInsets: LayoutPaddings
    var spacingBetweenContextAndAccessory: LayoutMetric
    var accessorySize: LayoutSize
    var addAccessory: ButtonStyle
    var checkAccessory: ButtonStyle
    var loadingAccessory: ButtonStyle
    var separator: Separator

    init(_ family: LayoutFamily) {
        self.context = OptInAssetListItemViewTheme(family)
        self.contextEdgeInsets = (20, 24, 20, 20)
        self.spacingBetweenContextAndAccessory = 8
        self.accessorySize = (44, 48)
        self.addAccessory = [
            .backgroundImage([ .normal("Card/shadow") ]),
            .icon([ .normal("List/Accessories/plus") ])
        ]
        self.checkAccessory = [
            .backgroundImage([ .normal("Card/shadowless") ]),
            .icon([ .normal("List/Accessories/check") ])
        ]
        self.loadingAccessory = [
            .backgroundImage([ .normal("Card/shadowless") ]),
            .icon([])
        ]
        self.separator = Separator(color: Colors.Layer.grayLighter, position: .bottom((80, 24)))
    }

    subscript (accessory: OptInAssetListItemAccessory) -> ButtonStyle {
        switch accessory {
        case .add: return addAccessory
        case .check: return checkAccessory
        case .loading: return loadingAccessory
        }
    }
}
