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

    private lazy var collectibleListScreen = CollectibleListViewController(
        dataController: CollectibleListLocalDataController(
            galleryAccount: .single(account),
            sharedDataController: sharedDataController
        ),
        configuration: configuration
    )

    private lazy var transactionActionButton = FloatingActionItemButton(hasTitleLabel: false)
    
    private let account: AccountHandle

    init(
        account: AccountHandle,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        super.init(configuration: configuration)
    }

    override func prepareLayout() {
        super.prepareLayout()
        add(collectibleListScreen)

        if !account.value.isWatchAccount() {
            addTransactionActionButton(theme)
        }
    }

    override func setListeners() {
        super.setListeners()
        setTransactionActionButtonAction()
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
        screen.observe(event: .performReceiveAction) {
            [weak self] in
            guard let self = self else { return }

            self.openReceiveCollectible()
        }
    }
}

extension AccountCollectibleListViewController {
    private func addTransactionActionButton(_ theme: Theme) {
        transactionActionButton.image = "fab-swap".uiImage

        view.addSubview(transactionActionButton)
        transactionActionButton.snp.makeConstraints {
            $0.setPaddings(theme.transactionActionButtonPaddings)
        }
    }

    private func setTransactionActionButtonAction() {
        transactionActionButton.addTarget(
            self,
            action: #selector(didTapTransactionActionButton),
            for: .touchUpInside
        )
    }

    @objc
    private func didTapTransactionActionButton() {
        let viewController = open(
            .transactionFloatingActionButton,
            by: .customPresentWithoutNavigationController(
                presentationStyle: .overCurrentContext,
                transitionStyle: nil,
                transitioningDelegate: nil
            ),
            animated: false
        ) as? TransactionFloatingActionButtonViewController

        viewController?.delegate = self
    }
}

extension AccountCollectibleListViewController: TransactionFloatingActionButtonViewControllerDelegate {
    func transactionFloatingActionButtonViewControllerDidSend(
        _ viewController: TransactionFloatingActionButtonViewController
    ) {
        let account = account.value

        log(SendAssetDetailEvent(address: account.address))

        let controller = open(
            .assetSelection(
                filter: nil,
                account: account
            ),
            by: .present
        ) as? SelectAssetViewController

        let closeBarButtonItem = ALGBarButtonItem(kind: .close) {
            controller?.closeScreen(
                by: .dismiss,
                animated: true
            )
        }

        controller?.leftBarButtonItems = [closeBarButtonItem]
    }

    func transactionFloatingActionButtonViewControllerDidReceive(
        _ viewController: TransactionFloatingActionButtonViewController
    ) {
        let account = account.value

        log(ReceiveAssetDetailEvent(address: account.address))

        let draft = QRCreationDraft(
            address: account.address,
            mode: .address,
            title: account.name
        )
        
        open(
            .qrGenerator(
                title: account.name ?? account.address.shortAddressDisplay,
                draft: draft,
                isTrackable: true
            ),
            by: .present
        )
    }

    func transactionFloatingActionButtonViewControllerDidBuy(
        _ viewController: TransactionFloatingActionButtonViewController
    ) {
        openBuyAlgo()
    }

    private func openBuyAlgo() {
        let draft = BuyAlgoDraft()
        draft.address = account.value.address

        launchBuyAlgo(draft: draft)
    }
}

extension AccountCollectibleListViewController {
    private func openReceiveCollectible() {
        let controller = open(
            .receiveCollectibleAssetList(
                account: account,
                dataController: ReceiveCollectibleAssetListAPIDataController(api!)
            ),
            by: .present
        ) as? ReceiveCollectibleAssetListViewController

        controller?.delegate = self

        let close = ALGBarButtonItem(kind: .close) {
            controller?.dismissScreen()
        }

        controller?.leftBarButtonItems = [close]
    }
}

extension AccountCollectibleListViewController: ReceiveCollectibleAssetListViewControllerDelegate {
    func receiveCollectibleAssetListViewController(
        _ controller: ReceiveCollectibleAssetListViewController,
        didCompleteTransaction account: Account
    ) {
        controller.dismissScreen {
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

extension AccountCollectibleListViewController {
    struct Theme: LayoutSheet, StyleSheet {
        let transactionActionButtonPaddings: LayoutPaddings

        init(_ family: LayoutFamily) {
            self.transactionActionButtonPaddings = (
                .noMetric,
                .noMetric,
                UIApplication.shared.safeAreaBottom + 24,
                24
            )
        }
    }
}
