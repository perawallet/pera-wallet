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

//   SwapAccountSelectionListScreen.swift

import Foundation
import UIKit

final class SwapAccountSelectionListScreen<
    DataController: AccountSelectionListDataController
>: AccountSelectionListScreen<DataController>,
   SwapAssetFlowCoordinatorObserver {
    private weak var swapAssetFlowCoordinator: SwapAssetFlowCoordinator?

    init(
        navigationBarTitle: String,
        listView: UICollectionView,
        dataController: DataController,
        listLayout: AccountSelectionListLayout,
        listDataSource: DataSource,
        swapAssetFlowCoordinator: SwapAssetFlowCoordinator,
        theme: AccountSelectionListScreenTheme,
        eventHandler: @escaping EventHandler,
        configuration: ViewControllerConfiguration
    ) {
        self.swapAssetFlowCoordinator = swapAssetFlowCoordinator

        super.init(
            navigationBarTitle: navigationBarTitle,
            listView: listView,
            dataController: dataController,
            listLayout: listLayout,
            listDataSource: listDataSource,
            theme: theme,
            eventHandler: eventHandler,
            configuration: configuration
        )

        self.swapAssetFlowCoordinator?.add(self)
    }


    deinit {
        swapAssetFlowCoordinator?.remove(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        swapAssetFlowCoordinator?.add(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        swapAssetFlowCoordinator?.remove(self)
    }
}

/// SwapAssetFlowCoordinatorObserver
extension SwapAccountSelectionListScreen {
    func swapAssetFlowCoordinator(
        _ swapAssetFlowCoordinator: SwapAssetFlowCoordinator,
        didPublish event: SwapAssetFlowCoordinatorEvent
    ) {
        switch event {
        case .didApproveOptInToAsset(let asset):
            continueToOptInAsset(asset: asset)
        default:
            break
        }
    }
}
