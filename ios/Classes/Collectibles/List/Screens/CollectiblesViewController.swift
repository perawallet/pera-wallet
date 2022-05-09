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
    
    override var name: AnalyticsScreenName? {
        return .collectibles
    }

    private lazy var bottomBannerController = BottomActionableBannerController(
        presentingView: view,
        configuration: BottomActionableBannerControllerConfiguration(
            bottomMargin: view.safeAreaBottom + 48,
            contentBottomPadding: 20
        )
    )

    private lazy var collectibleListScreen = CollectibleListViewController(
        dataController: CollectibleListLocalDataController(
            galleryAccount: .all,
            sharedDataController: sharedDataController
        ),
        theme: .common,
        configuration: configuration
    )

    override func configureNavigationBarAppearance() {
        addBarButtons()
        bindNavigationItemTitle()
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
    private func addBarButtons() {
        let addBarButtonItem = ALGBarButtonItem(kind: .add) { [weak self] in
            guard let self = self else {
                return
            }

            self.openReceiveCollectible()
        }

        rightBarButtonItems = [addBarButtonItem]
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
            default:
                break
            }
        }
    }
}

extension CollectiblesViewController {
    private func openReceiveCollectible() {
        let controller = open(
            .receiveCollectibleAccountList(
                dataController: ReceiveCollectibleAccountListAPIDataController(
                    sharedDataController
                )
            ),
            by: .present
        ) as? ReceiveCollectibleAccountListViewController

        controller?.delegate = self
    }
}

extension CollectiblesViewController: ReceiveCollectibleAccountListViewControllerDelegate {
    func receiveCollectibleAccountListViewController(
        _ controller: ReceiveCollectibleAccountListViewController,
        didCompleteTransaction account: Account
    ) {
        controller.dismissScreen() {
            let draft = QRCreationDraft(
                address: account.address,
                mode: .address,
                title: account.name
            )

            self.open(
                .qrGenerator(
                    title: account.name ?? account.address.shortAddressDisplay,
                    draft: draft,
                    isTrackable: true
                ),
                by: .present
            )
        }
    }
}
