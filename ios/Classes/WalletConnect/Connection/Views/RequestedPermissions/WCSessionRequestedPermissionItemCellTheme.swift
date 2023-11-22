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

//   WCSessionRequestedPermissionItemCellTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct WCSessionRequestedPermissionItemCellTheme:
    StyleSheet,
    LayoutSheet {
    let context: SecondaryListItemViewTheme
    let contextEdgeInsets: LayoutPaddings
    let separator: Separator

    init(_ family: LayoutFamily) {
        self.context = WCSessionRequestedPermissionItemViewTheme(family)
        self.contextEdgeInsets = (12, 0, 0, 0)
        self.separator = Separator(color: Colors.Layer.grayLighter)
    }
}

struct WCSessionRequestedPermissionItemViewTheme: SecondaryListItemViewTheme {
    let contentEdgeInsets: LayoutPaddings
    let title: TextStyle
    let titleMinWidthRatio: LayoutMetric
    let titleMaxWidthRatio: LayoutMetric
    let minimumSpacingBetweenTitleAndAccessory: LayoutMetric
    let accessory: SecondaryListItemValueViewTheme

    init(
        _ family: LayoutFamily
    ) {
        self.contentEdgeInsets = (0, 0, 0, 0)
        self.title = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText())
        ]
        self.titleMinWidthRatio = 0.2
        self.titleMaxWidthRatio = 0.45
        self.minimumSpacingBetweenTitleAndAccessory = 12
        self.accessory = SecondaryListItemValueCommonViewTheme(family)
    }
}
