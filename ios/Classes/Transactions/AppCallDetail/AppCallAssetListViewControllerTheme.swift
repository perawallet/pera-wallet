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

//   AppCallAssetListViewControllerTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AppCallAssetListViewControllerTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let listContentInset: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        listContentInset = (20, 0, 20, 0)
    }
}

extension AppCallAssetListViewControllerTheme {
    func calculateModalHeightAsBottomSheet(
        _ viewController: AppCallAssetListViewController
    ) -> ModalHeight {
        return .preferred(
            calculateHeightAsBottomSheet(viewController)
        )
    }

    private func calculateHeightAsBottomSheet(
        _ viewController: AppCallAssetListViewController
    ) -> LayoutMetric {
        let numberOfItems = viewController.dataController.assets.count
        let listContentInset = viewController.listView.contentInset
        let cellSize = 75.cgFloat /// <todo> How to calculate this dynamically from collectionView?

        var height =
        (numberOfItems.cgFloat * cellSize) +
        listContentInset.vertical +
        viewController.view.safeAreaBottom

        if let navigationController = viewController.navigationController {
            height += navigationController.navigationBar.bounds.height
        }

        return height.ceil()
    }
}
