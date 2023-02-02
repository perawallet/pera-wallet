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
//   WCConnectionApprovalViewController.swift

import UIKit
import MacaroonBottomSheet
import MacaroonUIKit

final class WCConnectionApprovalViewController: BaseViewController {
    weak var delegate: WCConnectionApprovalViewControllerDelegate?
    
    let walletConnectSession: WalletConnectSession

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private var hasMultipleAccounts: Bool {
        let accounts = sharedDataController.accountCollection.filter { !$0.value.isWatchAccount() }
        return accounts.count > 1
    }

    private lazy var connectionApprovalView = WCConnectionApprovalView(hasMultipleAccounts: hasMultipleAccounts)

    private let preferences: WalletConnectorPreferences
    private let walletConnectSessionConnectionCompletionHandler: WalletConnectSessionConnectionCompletionHandler

    private var selectedAccount: AccountHandle?

    init(
        walletConnectSession: WalletConnectSession,
        preferences: WalletConnectorPreferences,
        walletConnectSessionConnectionCompletionHandler: @escaping WalletConnectSessionConnectionCompletionHandler,
        configuration: ViewControllerConfiguration
    ) {
        self.walletConnectSession = walletConnectSession
        self.preferences = preferences
        self.walletConnectSessionConnectionCompletionHandler = walletConnectSessionConnectionCompletionHandler
        super.init(configuration: configuration)

        if !hasMultipleAccounts {
            let selectedAccount =
                sharedDataController
                    .accountCollection
                    .first {
                        $0.value.type != .watch
                    }

            self.selectedAccount = selectedAccount
        }
    }

    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: Colors.Defaults.background)
        connectionApprovalView.bindData(WCConnectionApprovalViewModel(walletConnectSession))

        if let account = selectedAccount?.value {
            connectionApprovalView.bindData(WCConnectionAccountSelectionViewModel(account))
        }
    }

    override func prepareLayout() {
        super.prepareLayout()
        addConnectionApprovalView()
    }

    override func linkInteractors() {
        super.linkInteractors()
        connectionApprovalView.delegate = self
    }
}

extension WCConnectionApprovalViewController {
    private func addConnectionApprovalView() {
        view.addSubview(connectionApprovalView)
        connectionApprovalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension WCConnectionApprovalViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        .compressed
    }
}

extension WCConnectionApprovalViewController: WCConnectionApprovalViewDelegate {
    func wcConnectionApprovalViewDidApproveConnection(_ wcConnectionApprovalView: WCConnectionApprovalView) {
        guard let account = selectedAccount?.value else {
            return
        }

        analytics.track(
            .wcSessionApproved(
                topic: walletConnectSession.url.topic,
                dappName: walletConnectSession.dAppInfo.peerMeta.name,
                dappURL: walletConnectSession.dAppInfo.peerMeta.url.absoluteString,
                address: account.address
            )
        )

        DispatchQueue.main.async {
            self.walletConnectSessionConnectionCompletionHandler(
                self.walletConnectSession.getApprovedWalletConnectionInfo(
                    for: account.address
                )
            )
            self.delegate?.wcConnectionApprovalViewControllerDidApproveConnection(
                self,
                self.preferences
            )
        }
    }

    func wcConnectionApprovalViewDidRejectConnection(_ wcConnectionApprovalView: WCConnectionApprovalView) {
        analytics.track(
            .wcSessionRejected(
                topic: walletConnectSession.url.topic,
                dappName: walletConnectSession.dAppInfo.peerMeta.name,
                dappURL: walletConnectSession.dAppInfo.peerMeta.url.absoluteString
            )
        )

        DispatchQueue.main.async {
            self.walletConnectSessionConnectionCompletionHandler(self.walletConnectSession.getDeclinedWalletConnectionInfo())
            self.delegate?.wcConnectionApprovalViewControllerDidRejectConnection(self)
        }
    }

    func wcConnectionApprovalViewDidSelectAccountSelection(_ wcConnectionApprovalView: WCConnectionApprovalView) {
        open(.accountList(mode: .walletConnect(account: selectedAccount?.value), delegate: self), by: .push)
    }

    func wcConnectionApprovalViewDidOpenURL(_ wcConnectionApprovalView: WCConnectionApprovalView) {
        open(walletConnectSession.dAppInfo.peerMeta.url)
    }
}

extension WCConnectionApprovalViewController: AccountListViewControllerDelegate {
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: AccountHandle) {
        viewController.popScreen()

        selectedAccount = account
        connectionApprovalView.bindData(WCConnectionAccountSelectionViewModel(account.value))
    }

    func accountListViewControllerDidCancelScreen(_ viewController: AccountListViewController) {
        viewController.popScreen()
    }
}

protocol WCConnectionApprovalViewControllerDelegate: AnyObject {
    func wcConnectionApprovalViewControllerDidApproveConnection(
        _ wcConnectionApprovalViewController: WCConnectionApprovalViewController,
        _ preferences: WalletConnectorPreferences
    )
    func wcConnectionApprovalViewControllerDidRejectConnection(_ wcConnectionApprovalViewController: WCConnectionApprovalViewController)
}
