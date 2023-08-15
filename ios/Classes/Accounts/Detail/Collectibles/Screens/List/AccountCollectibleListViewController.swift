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
//   AccountCollectibleListViewController.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AccountCollectibleListViewController: BaseViewController {
    private lazy var theme = Theme()

    private lazy var bottomBannerController = BottomActionableBannerController(
        presentingView: view,
        configuration: BottomActionableBannerControllerConfiguration(
            bottomMargin: 0,
            contentBottomPadding: view.safeAreaBottom + 20
        )
    )

    private lazy var collectibleListScreen = CollectibleListViewController(
        query: query,
        dataController: dataController,
        copyToClipboardController: copyToClipboardController,
        galleryUIStyleCache: .init(),
        configuration: configuration
    )

    private lazy var optInActionView = FloatingActionItemButton(hasTitleLabel: false)

    private var account: AccountHandle
    private let query: CollectibleListQuery
    private let dataController: CollectibleListDataController
    private let copyToClipboardController: CopyToClipboardController

    init(
        account: AccountHandle,
        query: CollectibleListQuery,
        dataController: CollectibleListDataController,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        self.query = query
        self.dataController = dataController
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        analytics.track(.recordAccountDetailScreen(type: .tapCollectibles))
    }

    override func prepareLayout() {
        super.prepareLayout()
        add(collectibleListScreen)

        if !account.value.authorization.isWatch {
            addOptInAction()
            updateSafeAreaWhenOptInActionWasAdded()
        }
    }

    override func linkInteractors() {
        super.linkInteractors()
        linkInteractors(collectibleListScreen)
    }
}

extension AccountCollectibleListViewController {
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
                if self.account.value.authorization.isWatch {
                    return
                }

                self.analytics.track(.tapNFTReceive())
                self.openReceiveCollectible()
            case .didUpdateSnapshot:
                let address = self.account.value.address

                guard let updatedAccount = self.sharedDataController.accountCollection[address] else {
                    return
                }

                self.account = updatedAccount
            case .willDisplayListHeader:
                self.setOptInActionHidden(true)
            case .didEndDisplayingListHeader:
                self.setOptInActionHidden(false)
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
            }
        }
    }
}

extension AccountCollectibleListViewController {
    private func addOptInAction() {
        optInActionView.image = theme.optInActionIcon

        view.addSubview(optInActionView)

        optInActionView.snp.makeConstraints {
            let safeAreaBottom = view.compactSafeAreaInsets.bottom
            let bottom = safeAreaBottom + theme.optInActionBottomPadding

            $0.fitToSize(theme.optInActionSize)
            $0.trailing == theme.optInActionTrailingPadding
            $0.bottom == bottom
        }

        optInActionView.addTouch(
            target: self,
            action: #selector(openReceiveCollectible)
        )

        setOptInActionHidden(true)
    }

    private func setOptInActionHidden(_ hidden: Bool) {
        optInActionView.isHidden = hidden
    }

    private func updateSafeAreaWhenOptInActionWasAdded() {
        let listSafeAreaBottom =
            theme.spacingBetweenListAndAOptInAction +
            theme.optInActionSize.h +
            theme.optInActionBottomPadding
            additionalSafeAreaInsets.bottom = listSafeAreaBottom
    }
}

extension AccountCollectibleListViewController {
    @objc
    private func openReceiveCollectible() {
        view.endEditing(true)

        let aRawAccount = account.value
        if aRawAccount.authorization.isNoAuth {
            presentActionsNotAvailableForAccountBanner()
            return
        }

        open(
            .receiveCollectibleAssetList(account: account),
            by: .present
        )
    }
}

extension AccountCollectibleListViewController {
    private func presentActionsNotAvailableForAccountBanner() {
        bannerController?.presentErrorBanner(
            title: "action-not-available-for-account-type".localized,
            message: ""
        )
    }
}

extension AccountCollectibleListViewController {
    private func openFilterSelection() {
        var uiInteractions = AccountCollectibleListFilterSelectionViewController.UIInteractions()
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
            .accountCollectibleListFilterSelection(uiInteractions: uiInteractions),
            by: .present
        )
    }
}

extension AccountCollectibleListViewController {
    struct Theme: LayoutSheet, StyleSheet {
        let optInActionIcon: UIImage
        let optInActionSize: LayoutSize
        let optInActionTrailingPadding: LayoutMetric
        let optInActionBottomPadding: LayoutMetric
        let spacingBetweenListAndAOptInAction: LayoutMetric

        init(_ family: LayoutFamily) {
            optInActionIcon = "icon-circle-plus-64".uiImage
            optInActionSize = (64, 64)
            optInActionTrailingPadding = 24
            optInActionBottomPadding = 8
            spacingBetweenListAndAOptInAction = 4
        }
    }
}
