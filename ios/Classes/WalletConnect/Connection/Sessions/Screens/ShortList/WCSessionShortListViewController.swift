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
//   WCSessionShortListViewController.swift

import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class WCSessionShortListViewController: BaseViewController {
    weak var delegate: WCSessionShortListViewControllerDelegate?

    private lazy var theme = Theme()

    private(set) lazy var sessionListView = WCSessionShortListView()

    private lazy var dataSource = WCSessionShortListDataSource(walletConnector: walletConnector)
    private lazy var layoutBuilder = WCSessionShortListLayout(theme)

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        walletConnector.delegate = self
    }

    override func linkInteractors() {
        super.linkInteractors()
        sessionListView.setCollectionViewDataSource(dataSource)
        sessionListView.setCollectionViewDelegate(layoutBuilder)
        dataSource.delegate = self
        walletConnector.delegate = self
        sessionListView.delegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()
        addSessionListView()
    }
}

extension WCSessionShortListViewController {
    private func addSessionListView() {
        view.addSubview(sessionListView)
        sessionListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension WCSessionShortListViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return theme.calculateModalHeightAsBottomSheet(self)
    }
}

extension WCSessionShortListViewController: WCSessionShortListViewDelegate {
    func wcSessionShortListViewDidTapCloseButton(_ wcSessionShortListView: WCSessionShortListView) {
        delegate?.wcSessionShortListViewControllerDidClose(self)
        dismissScreen()
    }
}

extension WCSessionShortListViewController: WCSessionShortListDataSourceDelegate {
    func wcSessionShortListDataSource(_ wSessionListDataSource: WCSessionShortListDataSource, didOpenDisconnectMenuFrom cell: WCSessionShortListItemCell) {
        displayDisconnectionMenu(for: cell)
    }
}

extension WCSessionShortListViewController: WalletConnectorDelegate { }

extension WCSessionShortListViewController {
    private func index(of cell: WCSessionShortListItemCell) -> Int? {
        return sessionListView.collectionView.indexPath(for: cell)?.item
    }
}

extension WCSessionShortListViewController {
    private func displayDisconnectionMenu(for cell: WCSessionShortListItemCell) {
        guard let index = index(of: cell),
              let session = dataSource.session(at: index) else {
            return
        }

        let actionSheet = UIAlertController(
            title: nil,
            message: "wallet-connect-session-disconnect-message".localized(params: session.peerMeta.name),
            preferredStyle: .actionSheet
        )

        let disconnectAction = UIAlertAction(title: "title-disconnect".localized, style: .destructive) { [weak self] _ in
            guard let self = self else {
                return
            }

            self.analytics.track(
                .wcSessionDisconnected(
                    dappName: session.peerMeta.name,
                    dappURL: session.peerMeta.url.absoluteString,
                    address: session.walletMeta?.accounts?.first
                )
            )
            self.dataSource.disconnectFromSession(session)
            self.updateScreenAfterDisconnecting(from: session)

            if self.walletConnector.allWalletConnectSessions.isEmpty {
                self.delegate?.wcSessionShortListViewControllerDidClose(self)
                self.dismissScreen()
                return
            }
        }

        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel)

        actionSheet.addAction(disconnectAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
    }

    private func updateScreenAfterDisconnecting(from session: WCSession) {
        dataSource.updateSessions(walletConnector.allWalletConnectSessions)
        sessionListView.collectionView.reloadData()
    }
}

protocol WCSessionShortListViewControllerDelegate: AnyObject {
    func wcSessionShortListViewControllerDidClose(_ controller: WCSessionShortListViewController)
}
