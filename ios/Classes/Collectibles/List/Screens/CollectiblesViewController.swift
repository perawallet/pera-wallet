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

//   CollectiblesViewController.swift

import Foundation

final class CollectiblesViewController: BaseViewController {
    override var prefersLargeTitle: Bool {
        return true
    }

    override var analyticsScreen: ALGAnalyticsScreen? {
        return .init(name: .collectibleList)
    }

    private lazy var bottomBannerController = BottomActionableBannerController(
        presentingView: view,
        configuration: BottomActionableBannerControllerConfiguration(
            bottomMargin: view.safeAreaBottom + 64,
            contentBottomPadding: 20
        )
    )

    private lazy var collectibleListScreen = CollectibleListViewController(
        query: query,
        dataController: dataController,
        copyToClipboardController: copyToClipboardController,
        galleryUIStyleCache: .init(),
        configuration: configuration
    )

    private var isOptInBarButtonHidden = true

    private let query: CollectibleListQuery
    private let dataController: CollectibleListDataController
    private let copyToClipboardController: CopyToClipboardController

    init(
        query: CollectibleListQuery,
        dataController: CollectibleListDataController,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.query = query
        self.copyToClipboardController = copyToClipboardController
        self.dataController = dataController
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        bindNavigationItemTitle()
        setOptInBarButtonHidden(true)
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = false
        collectibleListScreen.tabBarHidden = false
    }

    override func prepareLayout() {
        super.prepareLayout()
        add(collectibleListScreen)
    }

    override func linkInteractors() {
        super.linkInteractors()
        linkInteractors(collectibleListScreen)
    }
}

extension CollectiblesViewController {
    private func setOptInBarButtonHidden(_ hidden: Bool) {
        if isOptInBarButtonHidden == hidden { return }

        if hidden {
            rightBarButtonItems = []
        } else {
            rightBarButtonItems = [ makeOptInBarButtonItem() ]
        }

        setNeedsRightBarButtonItemsUpdate()

        isOptInBarButtonHidden = hidden
    }

    private func makeOptInBarButtonItem() -> ALGBarButtonItem {
        return ALGBarButtonItem(kind: .add) {
            [unowned self] in
            self.endEditing()
            self.openReceiveCollectible()
        }
    }

    private func bindNavigationItemTitle() {
        title = "title-collectibles".localized
    }
}

extension CollectiblesViewController {
    private func linkInteractors(
        _ screen: CollectibleListViewController
    ) {
        screen.eventHandler = {
            [weak self] event in
            guard let self = self else {
                return
            }

            switch event {
            case .didTapReceive:
                self.openReceiveCollectible()
            case .willDisplayListHeader:
                self.setOptInBarButtonHidden(true)
            case .didEndDisplayingListHeader:
                self.setOptInBarButtonHidden(false)
            case .didFinishRunning(let hasError):
                if hasError {
                    self.bottomBannerController.presentFetchError(
                        title: "title-generic-error".localized,
                        message: "title-generic-response-description".localized,
                        actionTitle: "title-retry".localized,
                        actionHandler: {
                            [unowned self] in
                            self.bottomBannerController.dismissError()
                        }
                    )
                    return
                }

                self.bottomBannerController.dismissError()
            case .didTapFilter:
                self.openFilterSelection()
            default:
                break
            }
        }
    }
}

extension CollectiblesViewController {
    private func openReceiveCollectible() {
        open(
            .receiveCollectibleAccountList(
                dataController: ReceiveCollectibleAccountListAPIDataController(
                    sharedDataController
                )
            ),
            by: .present
        )
    }
}

extension CollectiblesViewController {
    private func openFilterSelection() {
        var uiInteractions = CollectiblesFilterSelectionViewController.UIInteractions()
        uiInteractions.didComplete = {
            [unowned self] in

            let filters = CollectibleFilterOptions()
            self.collectibleListScreen.reloadData(filters)

            self.dismiss(animated: true)
        }
        uiInteractions.didCancel = {
            [unowned self] in
            self.dismiss(animated: true)
        }

        open(
            .collectiblesFilterSelection(uiInteractions: uiInteractions),
            by: .present
        )
    }
}
