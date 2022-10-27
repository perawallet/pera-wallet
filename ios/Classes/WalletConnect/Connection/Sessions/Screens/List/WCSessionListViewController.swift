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
import MacaroonUIKit

final class WCSessionListViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
    private lazy var listView: UICollectionView = {
        let collectionViewLayout = WCSessionListLayout.build()
        let collectionView =
        UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var disconnectAllActionViewGradient = GradientView()
    private lazy var disconnectAllActionView = MacaroonUIKit.Button()

    private lazy var listLayout = WCSessionListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = WCSessionListDataSource(listView)

    private var isLayoutFinalized = false

    private let dataController: WCSessionListDataController
    private let theme: WCSessionListViewControllerTheme

    init(
        dataController: WCSessionListDataController,
        theme: WCSessionListViewControllerTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        self.theme = theme

        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        title = "settings-wallet-connect-title".localized

        addBarButtons()
    }

    override func setListeners() {
        super.setListeners()

        listView.delegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()

        addUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let snapshot):
                self.listDataSource.apply(
                    snapshot,
                    animatingDifferences: self.isViewAppeared
                )

                self.showDisconnectAllActionIfNeeded()
            case .didStartDisconnectingFromSession,
                 .didStartDisconnectingFromSessions:
                self.startLoading()
            case .didDisconnectFromSessions:
                self.stopLoading()
            case .didFailDisconnectingFromSession:
                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "title-generic-error".localized
                )
            }
        }

        dataController.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        walletConnector.delegate = dataController
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isLayoutFinalized ||
           disconnectAllActionView.bounds.isEmpty {
            return
        }

        updateSafeAreaWhenDisconnectAllActionVisible(true)

        isLayoutFinalized = true
    }

    private func addUI() {
        addBackground()
        addList()
    }
}

extension WCSessionListViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addList() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
    
    private func addBarButtons() {
        let qrBarButtonItem = ALGBarButtonItem(kind: .qr) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.openQRScanner()
        }

        rightBarButtonItems = [qrBarButtonItem]
    }
}

extension WCSessionListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: section
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }
}

extension WCSessionListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .empty:
            linkInteractors(cell as! NoContentWithActionCell)
        case .session(let item):
            linkInteractors(
                cell as! WCSessionItemCell,
                session: item.session
            )
        }
    }
}

extension WCSessionListViewController {
    private func linkInteractors(
        _ cell: WCSessionItemCell,
        session: WCSession
    ) {
        cell.startObserving(event: .performOptions) {
            [weak self] in
            guard let self = self else {
                return
            }
            
            self.openDisconnectSessionMenu(for: session)
        }
    }

    private func openDisconnectSessionMenu(for session: WCSession) {
        let actionSheet = UIAlertController(
            title: nil,
            message: "wallet-connect-session-disconnect-message".localized(params: session.peerMeta.name),
            preferredStyle: .actionSheet
        )
        
        let disconnectAction = UIAlertAction(
            title: "title-disconnect".localized,
            style: .destructive
        ) { [weak self] _ in
            guard let self = self else {
                return
            }

            let snapshot = self.listDataSource.snapshot()

            self.dataController.disconnectSession(
                snapshot,
                session: session
            )
        }

        let cancelAction = UIAlertAction(
            title: "title-cancel".localized,
            style: .cancel
        )
        
        actionSheet.addAction(disconnectAction)
        actionSheet.addAction(cancelAction)

        present(
            actionSheet,
            animated: true
        )
    }
}

extension WCSessionListViewController {
    private func linkInteractors(_ cell: NoContentWithActionCell) {
        cell.startObserving(event: .performPrimaryAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.openQRScanner()
        }
    }
}

extension WCSessionListViewController {
    private func openQRScanner() {
        let qrScannerViewController = open(
            .qrScanner(canReadWCSession: true),
            by: .push
        ) as? QRScannerViewController
        qrScannerViewController?.delegate = self
    }
}

extension WCSessionListViewController: QRScannerViewControllerDelegate {
    func qrScannerViewControllerDidApproveWCConnection(
        _ controller: QRScannerViewController,
        session: WCSession
    ) {
        let snapshot = listDataSource.snapshot()

        dataController.addSessionItem(
            snapshot,
            session: session
        )
    }

    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didFail error: QRScannerError,
        completionHandler: EmptyHandler?
    ) {
        displaySimpleAlertWith(
            title: "title-error".localized,
            message: "qr-scan-should-scan-valid-qr".localized
        ) { _ in
            completionHandler?()
        }
    }
}

extension WCSessionListViewController {
    private func showDisconnectAllActionIfNeeded() {
        if !dataController.shouldShowDisconnectAllAction {
            if disconnectAllActionViewGradient.isDescendant(of: view),
               !disconnectAllActionViewGradient.isHidden {
                updateSafeAreaWhenDisconnectAllActionVisible(false)
                updateDisconnectAllActionVisibility(false)
            }
            return
        }

        if disconnectAllActionViewGradient.isDescendant(of: view),
           disconnectAllActionViewGradient.isHidden {
            updateSafeAreaWhenDisconnectAllActionVisible(true)
            updateDisconnectAllActionVisibility(true)
            return
        }

        addDisconnectAllActionViewGradient()
        addDisconnectAllActionView()
    }

    private func updateSafeAreaWhenDisconnectAllActionVisible(_ isVisible: Bool) {
        let safeAreaBottom: CGFloat

        if isVisible {
            safeAreaBottom =
            theme.spacingBetweenListAndDisconnectAllAction +
            disconnectAllActionView.frame.height +
            theme.disconnectAllActionMargins.bottom
        } else {
            safeAreaBottom = .zero
        }

        additionalSafeAreaInsets.bottom = safeAreaBottom
    }

    private func updateDisconnectAllActionVisibility(_ isVisible: Bool) {
        disconnectAllActionViewGradient.isHidden = !isVisible
    }

    private func addDisconnectAllActionViewGradient() {
        let color0 = Colors.Defaults.background.uiColor.withAlphaComponent(0)
        let color1 = Colors.Defaults.background.uiColor
        disconnectAllActionViewGradient.colors = [color0, color1]

        view.addSubview(disconnectAllActionViewGradient)
        disconnectAllActionViewGradient.snp.makeConstraints {
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addDisconnectAllActionView() {
        disconnectAllActionView.customizeAppearance(theme.disconnectAllAction)
        disconnectAllActionView.draw(corner: theme.disconnectAllActionCorner)

        disconnectAllActionViewGradient.addSubview(disconnectAllActionView)
        disconnectAllActionView.contentEdgeInsets = UIEdgeInsets(theme.disconnectAllActionEdgeInsets)
        disconnectAllActionView.snp.makeConstraints {
            let safeAreaBottom = view.compactSafeAreaInsets.bottom
            let bottom = safeAreaBottom + theme.disconnectAllActionMargins.bottom

            $0.top == theme.spacingBetweenListAndDisconnectAllAction
            $0.leading == theme.disconnectAllActionMargins.leading
            $0.bottom == bottom
            $0.trailing == theme.disconnectAllActionMargins.trailing
        }

        disconnectAllActionView.addTouch(
            target: self,
            action: #selector(performDisconnectAll)
        )
    }

    @objc
    private func performDisconnectAll() {
        let alertController = UIAlertController(
            title: nil,
            message: "wallet-connect-session-disconnect-all-message".localized,
            preferredStyle: .actionSheet
        )

        let disconnectAction = UIAlertAction(
            title: "title-disconnect".localized,
            style: .destructive
        ) { [weak self] _ in
            guard let self = self else {
                return
            }

            let snapshot = self.listDataSource.snapshot()

            self.dataController.disconnectAllSessions(snapshot)
        }

        let cancelAction = UIAlertAction(
            title: "title-cancel".localized,
            style: .cancel
        )

        alertController.addAction(disconnectAction)
        alertController.addAction(cancelAction)

        present(
            alertController,
            animated: true
        )
    }
}


extension WCSessionListViewController {
    private func startLoading() {
        loadingController?.startLoadingWithMessage("title-loading".localized)
    }

    private func stopLoading() {
        loadingController?.stopLoading()
    }
}
