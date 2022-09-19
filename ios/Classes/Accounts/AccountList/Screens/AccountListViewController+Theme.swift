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
//   AccountListViewController+Theme.swift

import MacaroonUIKit
import UIKit

extension AccountListViewController {
    struct Theme: LayoutSheet, StyleSheet {
        let backgroundColor: Color
        let accountListViewTheme: AccountListViewTheme
        let cellSize: LayoutSize

        init(_ family: LayoutFamily) {
            backgroundColor = Colors.Defaults.background
            accountListViewTheme = AccountListViewTheme()
            cellSize = (UIScreen.main.bounds.width - 48, 72)
        }
    }
}

extension AccountListViewController.Theme {
    func calculateModalHeightAsBottomSheet(_ viewController: AccountListViewController) -> ModalHeight {
        return .preferred(
            calculateHeightAsBottomSheet(viewController)
        )
    }

    private func calculateHeightAsBottomSheet(_ viewController: AccountListViewController) -> LayoutMetric {
        let numberOfItems = viewController.accountListDataSource.accounts.count
        let listContentInset = viewController.accountListView.accountsCollectionView.contentInset
        let listHeight = listContentInset.top + (CGFloat(numberOfItems) * cellSize.h) + listContentInset.bottom
        return listHeight
    }
}
