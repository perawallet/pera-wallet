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
//   TransactionFilterViewController+Theme.swift

import MacaroonUIKit
import UIKit

extension TransactionFilterViewController {
    struct Theme: LayoutSheet {
        let cellSize: LayoutSize

        init(_ family: LayoutFamily) {
            let horizontalPadding: LayoutMetric = 24
            self.cellSize = (UIScreen.main.bounds.width - (2 * horizontalPadding), 60)
        }
    }
}

extension TransactionFilterViewController.Theme {
    func calculateModalHeightAsBottomSheet(_ viewController: TransactionFilterViewController) -> ModalHeight {
        return .preferred(
            calculateHeightAsBottomSheet(viewController)
        )
    }

    private func calculateHeightAsBottomSheet(_ viewController: TransactionFilterViewController) -> LayoutMetric {
        let numberOfItems = viewController.filterOptions.count
        let listContentInset = viewController.transactionFilterView.collectionView.contentInset
        let listHeight = listContentInset.top + (CGFloat(numberOfItems) * cellSize.h) + listContentInset.bottom
        return listHeight
    }
}
