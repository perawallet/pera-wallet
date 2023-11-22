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
//   WCSessionShortListViewController+Theme.swift

import MacaroonUIKit
import UIKit

extension WCSessionShortListViewController {
    struct Theme: LayoutSheet {
        let cellSize: LayoutSize

        init(_ family: LayoutFamily) {
            self.cellSize = (UIScreen.main.bounds.width, 44)
        }
    }
}

extension WCSessionShortListViewController.Theme {
    func calculateModalHeightAsBottomSheet(_ viewController: WCSessionShortListViewController) -> ModalHeight {
        return .preferred(
                calculateHeightAsBottomSheet(viewController)
            )
    }

    private func calculateHeightAsBottomSheet(_ viewController: WCSessionShortListViewController) -> LayoutMetric {
        let sessions = viewController.peraConnect.walletConnectCoordinator.getSessions()
        let numberOfItems = sessions.count
        let spacingBetweenItems =
            (numberOfItems - 1).cgFloat *
            viewController.sessionListView.theme.cellSpacing
        let listContentInset = viewController.sessionListView.collectionView.contentInset
        let listHeight = listContentInset.vertical + (CGFloat(numberOfItems) * cellSize.h) + spacingBetweenItems
        return listHeight
    }
}
