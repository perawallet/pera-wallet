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
//   AccountAssetListViewController+Theme.swift

import Foundation
import MacaroonUIKit
import UIKit

extension AccountAssetListViewController {
    struct Theme: LayoutSheet, StyleSheet {
        let listBackgroundColor: Color
        let accountActionsMenuActionIcon: UIImage
        let accountActionsMenuActionSize: LayoutSize
        let accountActionsMenuActionTrailingPadding: LayoutMetric
        let accountActionsMenuActionBottomPadding: LayoutMetric
        let spacingBetweenListAndAccountActionsMenuAction: LayoutMetric
        let minSpacingBetweenSearchInputFieldAndKeyboard: LayoutMetric

        init(
            _ family: LayoutFamily
        ) {
            self.listBackgroundColor = Colors.Defaults.background
            self.accountActionsMenuActionIcon = "icon-account-detail-quick".uiImage
            self.accountActionsMenuActionSize = (64, 64)
            self.accountActionsMenuActionTrailingPadding = 24
            self.accountActionsMenuActionBottomPadding = 8
            self.spacingBetweenListAndAccountActionsMenuAction = 4
            self.minSpacingBetweenSearchInputFieldAndKeyboard = 8
        }
    }
}
