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
    UICollectionViewDelegateFlowLayout,
    PeraConnectObserver,
    NotificationObserver {
    var notificationObservations: [NSObjectProtocol] = []

    private lazy var listView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: WCSessionListLayout.build()
    )

    private lazy var disconnectAllActionViewGradient = GradientView()
    private lazy var disconnectAllActionView = MacaroonUIKit.Button()

    private lazy var listLayout = WCSessionListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = WCSessionListDataSource(listView)

    private var isLayoutFinalized = false

    private var sessionPingTimeoutTimers: [WalletConnectTopic: Timer] = [:]
    private let sessionPingTimeoutInSeconds: TimeInterval = 5

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

        startObservingDataUpdates()
    }

    deinit {
        stopObservingNotifications()

        invalidateSessionPingTimeoutTimers()
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        title = "settings-wallet-connect-title".localized

        addBarButtons()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()

        observeWhenApplicationWillEnterForeground {
            [weak self] _ in
            self?.configureConnectionStatusOfVisibleCells()
        }

        startObservingPeraConnectUpdates()

        dataController.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        configureConnectionStatusOfVisibleCellsIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateUIWhenViewDidLayoutSubviews()
    }
}

extension WCSessionListViewController {
    private func configureConnectionStatusOfVisibleCellsIfNeeded() {
        if isViewFirstAppeared { return }
        
        configureConnectionStatusOfVisibleCells()
    }

    private func configureConnectionStatusOfVisibleCells() {
        listView.indexPathsForVisibleItems.forEach {
            indexPath in
            guard let listItem = listDataSource.itemIdentifier(for: indexPath) else { return }
            guard case let WCSessionListItem.session(item) = listItem else { return }

            let cell = listView.cellForItem(at: indexPath) as? WCSessionItemCell
            configureConnectionStatus(
                cell,
                for: item
            )
        }
    }
    
    private func configureConnectionStatus(
        _ cell: WCSessionItemCell?,
        for item: WCSessionListItemContainer
    ) {
        let session = item.session
        if let wcV1Session = session.wcV1Session {
            configureConnectionStatus(
                cell,
                for: wcV1Session
            )
            return
        }
        
        if let wcV2Session = session.wcV2Session {
            configureConnectionStatus(
                cell,
                for: wcV2Session
            )
            return
        }
    }
    
    private func configureConnectionStatus(
        _ cell: WCSessionItemCell?,
        for session: WCSession
    ) {
        let isConnected =
            peraConnect.walletConnectCoordinator.walletConnectProtocolResolver
                .walletConnectV1Protocol
                .isConnected(by: session.urlMeta.wcURL)
        cell?.status = isConnected ? .active : .failed
    }
    
    private func configureConnectionStatus(
        _ cell: WCSessionItemCell?,
        for session: WalletConnectV2Session
    ) {
        cell?.status = .idle
        
        let topic = session.topic
        
        let hasOngoingPingTimeoutTimer = sessionPingTimeoutTimers[topic] != nil
        if hasOngoingPingTimeoutTimer {
            return
        }
        
        pingSession(session)
        
        startPingSessionTimeoutTimer(
            for: topic,
            cell: cell
        )
    }
    
    private func pingSession(_ session: WalletConnectV2Session) {
        peraConnect.walletConnectCoordinator.walletConnectProtocolResolver
            .walletConnectV2Protocol
            .pingSession(session)
    }

    private func startPingSessionTimeoutTimer(
        for topic: WalletConnectTopic,
        cell: WCSessionItemCell?
    ) {
        let pingTimeoutTimer = Timer.scheduledTimer(
            withTimeInterval: sessionPingTimeoutInSeconds,
            repeats: false
        ) {
            [weak self, weak cell] _ in
            guard
                let self,
                let cell
            else {
                return
            }

            invalidateSessionPingTimeoutTimer(for: topic)

            handleFailedSessionPing(cell)
        }

        sessionPingTimeoutTimers[topic] = pingTimeoutTimer
    }

    private func handleSuccessfulSessionPing(_ cell: WCSessionItemCell?) {
        asyncMain {
            [weak cell] in
            cell?.status = .active
        }
    }

    private func handleFailedSessionPing(_ cell: WCSessionItemCell?) {
        asyncMain {
            [weak cell] in
            cell?.status = .failed
        }
    }

    private func invalidateSessionPingTimeoutTimer(for topic: WalletConnectTopic) {
        sessionPingTimeoutTimers[topic]?.invalidate()
        sessionPingTimeoutTimers[topic] = nil
    }

    private func invalidateSessionPingTimeoutTimers() {
        sessionPingTimeoutTimers.values.forEach { timer in
            timer.invalidate()
        }
    }
}

extension WCSessionListViewController {
    private func startObservingPeraConnectUpdates() {
        peraConnect.add(self)
    }

    private func startObservingDataUpdates() {
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
                self.addPullToRefreshIfNeeded()
            case .didStartDisconnectingFromSessions:
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
    }
}

extension WCSessionListViewController {
    func peraConnect(
        _ peraConnect: PeraConnect,
        didPublish event: PeraConnectEvent
    ) {
        switch event {
        case .pingV2(let topic):
            guard
                let listItem = dataController[topic],
                let indexPath = listDataSource.indexPath(for: listItem),
                let cell = listView.cellForItem(at: indexPath) as? WCSessionItemCell
            else {
                invalidateSessionPingTimeoutTimer(for: topic)
                return
            }

            invalidateSessionPingTimeoutTimer(for: topic)

            handleSuccessfulSessionPing(cell)
        case .didPingV2SessionFail(let session, _):
            let topic = session.topic
            
            guard
                let listItem = dataController[topic],
                let indexPath = listDataSource.indexPath(for: listItem),
                let cell = listView.cellForItem(at: indexPath) as? WCSessionItemCell
            else {
                invalidateSessionPingTimeoutTimer(for: topic)
                return
            }

            invalidateSessionPingTimeoutTimer(for: topic)

            handleFailedSessionPing(cell)
        default:
            break
        }
    }
}

extension WCSessionListViewController {
    private func updateUIWhenViewDidLayoutSubviews() {
        if isLayoutFinalized ||
           disconnectAllActionView.bounds.isEmpty {
            return
        }

        updateSafeAreaWhenDisconnectAllActionVisible(true)

        isLayoutFinalized = true
    }
}

extension WCSessionListViewController {
    private func addUI() {
        addBackground()
        addList()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addList() {
        listView.showsVerticalScrollIndicator = false
        listView.showsHorizontalScrollIndicator = false
        listView.backgroundColor = .clear

        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }

        listView.delegate = self
    }
    
    private func addBarButtons() {
        let qrBarButtonItem = ALGBarButtonItem(kind: .qr) {
            [weak self] in
            self?.openQRScanner()
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
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .session(let item):
            let screen = open(
                .wcSessionDetail(draft: item.session),
                by: .push
            ) as? WCSessionDetailScreen
            screen?.eventHandler = {
                [weak self, weak screen] event in
                guard
                    let self,
                    let screen
                else {
                    return
                }
                switch event {
                case .didDisconnect:
                    screen.popScreen()

                    self.presentSessionDeletedSuccessfullyBanner()
                }
            }
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .session(let item):
            configureConnectionStatus(
                cell as? WCSessionItemCell,
                for: item
            )
        case .empty:
            linkInteractors(cell as? NoContentWithActionCell)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .session(let item):
            guard let wcV2Session = item.session.wcV2Session else { return }

            let topic = wcV2Session.topic
            invalidateSessionPingTimeoutTimer(for: topic)
        default:
            break
        }
    }
}

extension WCSessionListViewController {
    private func presentSessionDeletedSuccessfullyBanner() {
        bannerController?.presentSuccessBanner(
            title: "wallet-connect-session-disconnected-successfully-message".localized
        )
    }
}

extension WCSessionListViewController {
    private func linkInteractors(_ cell: NoContentWithActionCell?) {
        cell?.startObserving(event: .performPrimaryAction) {
            [weak self] in
            self?.openQRScanner()
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
            title: "node-settings-action-delete-title".localized,
            style: .destructive
        ) { [weak self] _ in
            guard let self else { return  }

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
    private func addPullToRefreshIfNeeded() {
        if shouldEnablePullToRefresh() {
            addPullToRefresh()
        } else {
            removePullToRefresh()
        }
    }

    private func shouldEnablePullToRefresh() -> Bool {
        let sessionItems = listDataSource.snapshot(for: .sessions).items
        return sessionItems.isNonEmpty
    }

    private func addPullToRefresh() {
        guard listView.refreshControl == nil else { return }

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self,
            action: #selector(didPullToRefresh),
            for: .valueChanged
        )
        listView.refreshControl = refreshControl
    }

    private func removePullToRefresh() {
        listView.refreshControl?.endRefreshing()
        listView.refreshControl = nil
    }
}

extension WCSessionListViewController {
    @objc
    private func didPullToRefresh() {
        configureConnectionStatusOfVisibleCells()

        listView.refreshControl?.endRefreshing()
    }
}

extension WCSessionListViewController {
    private func startLoading() {
        asyncMain {
            [weak self] in
            self?.loadingController?.startLoadingWithMessage("title-loading".localized)
        }
    }

    private func stopLoading() {
        asyncMain {
            [weak self] in
            self?.loadingController?.stopLoading()
        }
    }
}
