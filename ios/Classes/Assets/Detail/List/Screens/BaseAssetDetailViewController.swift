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

//   BaseAssetDetailViewController.swift

import Foundation
import MacaroonUIKit
import UIKit

class BaseAssetDetailViewController:
    TransactionsViewController,
    TransactionFloatingActionButtonViewControllerDelegate {
    private lazy var accountActionsMenuActionView = FloatingActionItemButton(hasTitleLabel: false)

    private lazy var theme = Theme()

    private let preferences: Preferences

    init(
        draft: TransactionListing,
        preferences: Preferences,
        copyToClipboardController: CopyToClipboardController?,
        configuration: ViewControllerConfiguration
    ) {
        self.preferences = preferences

        super.init(
            draft: draft,
            copyToClipboardController: copyToClipboardController,
            configuration: configuration
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if canAddAccountActionsMenuAction() {
            addAccountActionsMenuAction()
            updateSafeAreaWhenAccountActionsMenuActionWasAdded()
        }
    }
}

/// <mark>
/// TransactionFloatingActionButtonViewControllerDelegate
extension BaseAssetDetailViewController {
    func transactionFloatingActionButtonViewControllerDidSend(
        _ viewController: TransactionFloatingActionButtonViewController
    ) {
        log(SendAssetDetailEvent(address: accountHandle.value.address))

        switch draft.type {
        case .all:
            let controller = open(
                .assetSelection(
                    filter: nil,
                    account: accountHandle.value
                ),
                by: .present
            ) as? SelectAssetViewController
            let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak controller] in
                controller?.closeScreen(by: .dismiss, animated: true)
            }
            controller?.leftBarButtonItems = [closeBarButtonItem]
        case .asset:
            if let asset = asset {
                let draft = SendTransactionDraft(from: accountHandle.value, transactionMode: .asset(asset))
                let controller = open(.sendTransaction(draft: draft), by: .present) as? SendTransactionScreen
                let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak controller] in
                    controller?.closeScreen(by: .dismiss, animated: true)
                }
                controller?.leftBarButtonItems = [closeBarButtonItem]
            }
        case .algos:
            let draft = SendTransactionDraft(from: accountHandle.value, transactionMode: .algo)
            let controller = open(.sendTransaction(draft: draft), by: .present) as? SendTransactionScreen
            let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak controller] in
                controller?.closeScreen(by: .dismiss, animated: true)
            }
            controller?.leftBarButtonItems = [closeBarButtonItem]
        }
    }

    func transactionFloatingActionButtonViewControllerDidReceive(
        _ viewController: TransactionFloatingActionButtonViewController
    ) {
        log(ReceiveAssetDetailEvent(address: accountHandle.value.address))
        let draft = QRCreationDraft(address: accountHandle.value.address, mode: .address, title: accountHandle.value.name)
        open(.qrGenerator(title: accountHandle.value.name ?? accountHandle.value.address.shortAddressDisplay, draft: draft, isTrackable: true), by: .present)
    }

    func transactionFloatingActionButtonViewControllerDidBuy(
        _ viewController: TransactionFloatingActionButtonViewController
    ) {
        openBuyAlgo()
    }
}

extension BaseAssetDetailViewController {
    private func canAddAccountActionsMenuAction() -> Bool {
        let showsAccountActionsMenu = preferences.showsAccountActionsMenu
        let isNonWatchAccount = !accountHandle.value.isWatchAccount()
        return showsAccountActionsMenu && isNonWatchAccount
    }

    private func addAccountActionsMenuAction() {
        accountActionsMenuActionView.image = theme.accountActionsMenuActionIcon

        view.addSubview(accountActionsMenuActionView)

        accountActionsMenuActionView.snp.makeConstraints {
            let safeAreaBottom = view.compactSafeAreaInsets.bottom
            let bottom = safeAreaBottom + theme.accountActionsMenuActionBottomPadding

            $0.fitToSize(theme.accountActionsMenuActionSize)
            $0.trailing == theme.accountActionsMenuActionTrailingPadding
            $0.bottom == bottom
        }

        accountActionsMenuActionView.addTouch(
            target: self,
            action: #selector(openAccountActionsMenu)
        )
    }

    private func updateSafeAreaWhenAccountActionsMenuActionWasAdded() {
        let listSafeAreaBottom =
            theme.spacingBetweenListAndAccountActionsMenuAction +
            theme.accountActionsMenuActionSize.h +
            theme.accountActionsMenuActionBottomPadding
        additionalSafeAreaInsets.bottom = listSafeAreaBottom
    }
}

extension BaseAssetDetailViewController {
    @objc
    private func openAccountActionsMenu() {
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

    private func openBuyAlgo() {
        let draft = BuyAlgoDraft()
        draft.address = accountHandle.value.address

        launchBuyAlgo(draft: draft)
    }
}

extension BaseAssetDetailViewController {
    struct Preferences {
        var showsAccountActionsMenu = true
    }
}

extension BaseAssetDetailViewController {
    private struct Theme:
        StyleSheet,
        LayoutSheet {
        let accountActionsMenuActionIcon: UIImage
        let accountActionsMenuActionSize: LayoutSize
        let accountActionsMenuActionTrailingPadding: LayoutMetric
        let accountActionsMenuActionBottomPadding: LayoutMetric
        let spacingBetweenListAndAccountActionsMenuAction: LayoutMetric

        init(
            _ family: LayoutFamily
        ) {
            self.accountActionsMenuActionIcon = "fab-swap".uiImage
            self.accountActionsMenuActionSize = (64, 64)
            self.accountActionsMenuActionTrailingPadding = 24
            self.accountActionsMenuActionBottomPadding = 8
            self.spacingBetweenListAndAccountActionsMenuAction = 4
        }
    }
}
