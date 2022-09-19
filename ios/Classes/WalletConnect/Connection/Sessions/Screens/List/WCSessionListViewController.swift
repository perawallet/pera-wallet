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
//   WCSessionListViewController.swift

import UIKit
import MacaroonUtils

final class WCSessionListViewController: BaseViewController {
    private lazy var sessionListView = WCSessionListView()
    private lazy var noContentWithActionView = NoContentWithActionView()

    private lazy var dataSource = WCSessionListDataSource(walletConnector: walletConnector)
    private lazy var layoutBuilder = WCSessionListLayout(dataSource: dataSource)

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        walletConnector.delegate = self
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        addBarButtons()
    }

    override func configureAppearance() {
        title = "settings-wallet-connect-title".localized
        setListContentState()
    }

    override func linkInteractors() {
        super.linkInteractors()
        sessionListView.setDataSource(dataSource)
        sessionListView.setDelegate(layoutBuilder)
        dataSource.delegate = self

        noContentWithActionView.setListeners()
        noContentWithActionView.startObserving(event: .performPrimaryAction) {
            [weak self] in
            self?.openQRScanner()
        }
    }

    override func prepareLayout() {
        super.prepareLayout()
        noContentWithActionView.customize(NoContentWithActionViewCommonTheme())
        noContentWithActionView.bindData(WCSessionListNoContentViewModel())

        addSessionListView()
    }
}

extension WCSessionListViewController {
    private func addSessionListView() {
        view.addSubview(sessionListView)
        sessionListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension WCSessionListViewController {
    private func addBarButtons() {
        let qrBarButtonItem = ALGBarButtonItem(kind: .qr) { [weak self] in
            guard let self = self else {
                return
            }

            self.openQRScanner()
        }

        rightBarButtonItems = [qrBarButtonItem]
    }
}

extension WCSessionListViewController: WCSessionListDataSourceDelegate {
    func wSessionListDataSource(_ wSessionListDataSource: WCSessionListDataSource, didOpenDisconnectMenuFrom cell: WCSessionItemCell) {
        displayDisconnectionMenu(for: cell)
    }
}

extension WCSessionListViewController: WalletConnectorDelegate { }

extension WCSessionListViewController {
    private func setListContentState() {
        sessionListView.collectionView.contentState = dataSource.isEmpty ? .empty(noContentWithActionView) : .none
    }

    private func index(of cell: WCSessionItemCell) -> Int? {
        return sessionListView.collectionView.indexPath(for: cell)?.item
    }
}

extension WCSessionListViewController {
    private func openQRScanner() {
        let qrScannerViewController = open(.qrScanner(canReadWCSession: true), by: .push) as? QRScannerViewController
        qrScannerViewController?.delegate = self
    }
}

extension WCSessionListViewController: QRScannerViewControllerDelegate {
    func qrScannerViewControllerDidApproveWCConnection(_ controller: QRScannerViewController) {
        asyncMain { [weak self] in
            guard let self = self else {
                return
            }

            self.dataSource.updateSessions(self.walletConnector.allWalletConnectSessions)
            self.setListContentState()
            self.sessionListView.collectionView.reloadData()
        }
    }

    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            completionHandler?()
        }
    }
}

extension WCSessionListViewController {
    private func displayDisconnectionMenu(for cell: WCSessionItemCell) {
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
        }

        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel)

        actionSheet.addAction(disconnectAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
    }

    private func updateScreenAfterDisconnecting(from session: WCSession) {
        dataSource.updateSessions(walletConnector.allWalletConnectSessions)
        setListContentState()
        sessionListView.collectionView.reloadData()
    }
}
