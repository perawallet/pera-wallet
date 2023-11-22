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

//   WCSessionConnectionAccountCellTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct WCSessionConnectionAccountCellTheme:
    StyleSheet,
    LayoutSheet {
    let context: AccountListItemViewTheme
    let contextEdgeInsets: LayoutPaddings
    let spacingBetweenContextAndAccessory: LayoutMetric
    let accessorySize: LayoutSize
    let selectedAccessory: ImageStyle
    let unselectedAccessory: ImageStyle
    let separator: Separator

    init(_ family: LayoutFamily) {
        self.context = AccountListItemViewTheme(family)
        self.contextEdgeInsets = (14, 24, 14, 24)
        self.spacingBetweenContextAndAccessory = 20
        self.accessorySize = (24, 24)
        self.selectedAccessory = [
            .image("icon-checkbox-selected")
        ]
        self.unselectedAccessory = [
            .image("icon-checkbox-unselected")
        ]
        self.separator = Separator(
            color: Colors.Layer.grayLighter,
            position: .bottom((80, 24))
        )
    }

    subscript (accessory: WCSessionConnectionAccountListItemAccessory) -> ImageStyle {
        switch accessory {
        case .selected: return selectedAccessory
        case .unselected: return unselectedAccessory
        }
    }
}
