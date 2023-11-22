// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCSessionDetailScreen.swift

import UIKit
import MacaroonUIKit
import MacaroonUtils

final class WCSessionDetailScreen:
    BaseViewController,
    UICollectionViewDelegateFlowLayout,
    PeraConnectObserver {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var theme = WCSessionDetailScreenTheme()

    private lazy var listView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: WCSessionDetailLayout.build()
    )
    private lazy var footerEffectView = EffectView()
    private lazy var actionsContextView = MacaroonUIKit.VStackView()
    private lazy var primaryActionView = MacaroonUIKit.Button()
    private lazy var secondaryActionView = MacaroonUIKit.Button()

    private lazy var listLayout = WCSessionDetailLayout(
        dataSource: dataSource,
        dataController: dataController
    )
    private lazy var dataSource = WCSessionDetailDataSource(
        collectionView: listView,
        dataController: dataController
    )

    private lazy var transitionToAdvancedPermissionsInfo = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionExtendSessionValidity =
        BottomSheetTransition(presentingViewController: self)

    private var isViewLayoutLoaded = false
    private var isAdditionalSafeAreaInsetsFinalized = false

    private var sessionPingRetryRepeater: Repeater?
    private var sessionPingRetryCount = 3
    private var sessionPingRetryInterval: TimeInterval {
        let interval = sessionPingTimeoutInSeconds / TimeInterval(sessionPingRetryCount)
        return interval.rounded()
    }
    private var sessionPingRepeater: Repeater?
    private var sessionPingRepeaterEndDate: Date?
    private let resetCheckStatusDelayAfterPingingResultInSeconds: TimeInterval = 3
    private let sessionPingTimeoutInSeconds: TimeInterval = 15

    private let dataController: WCSessionDetailDataController
    private let copyToClipboardController: CopyToClipboardController

    init(
        dataController: WCSessionDetailDataController,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)

        startObservingDataUpdates()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()

        startObservingPeraConnectEvents()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty {
            return
        }

        if !isViewLayoutLoaded {
            loadInitialData()
            isViewLayoutLoaded = true
        }

        updateUIWhenViewDidLayoutSubviews()
    }
}

extension WCSessionDetailScreen {
    private func startObservingDataUpdates() {
        dataController.eventHandler = {
            [weak self] event in
            guard let self else { return }

            switch event {
            case .didUpdate(let update):
                self.dataSource.apply(
                    update.snapshot,
                    to: update.section,
                    animatingDifferences: self.isViewAppeared
                )
                self.togglePrimaryActionStateIfNeeded()
            }
        }
    }

    private func loadInitialData() {
        dataController.load()
    }
}

extension WCSessionDetailScreen {
    private func startObservingPeraConnectEvents() {
        peraConnect.add(self)
    }
}

extension WCSessionDetailScreen {
    private func addUI() {
        addBackground()
        addList()
        addActions()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addList() {
        listView.showsVerticalScrollIndicator = false
        listView.showsHorizontalScrollIndicator = false
        listView.alwaysBounceVertical = true
        listView.backgroundColor = .clear

        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        listView.delegate = self
    }

    private func addActions() {
        addFooterGradient()
        addActionsContext()
    }

    private func addFooterGradient() {
        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]
        footerEffectView.effect = LinearGradientEffect(gradient: backgroundGradient)

        view.addSubview(footerEffectView)
        footerEffectView.snp.makeConstraints {
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addActionsContext() {
        footerEffectView.addSubview(actionsContextView)
        actionsContextView.spacing = theme.spacingBetweenActions

        actionsContextView.snp.makeConstraints {
            let safeAreaBottom = view.compactSafeAreaInsets.bottom
            let bottom = safeAreaBottom + theme.actionMargins.bottom

            $0.top == theme.spacingBetweenListAndPrimaryAction
            $0.leading == theme.actionMargins.leading
            $0.trailing == theme.actionMargins.trailing
            $0.bottom == bottom
        }

        /// <note> Session expiry date extendability is disabled for now. Date: 05.09.2023
//        let draft = dataController.getSessionDraft()
//        let isWCV2Session = draft.isWCv2Session
//        if isWCV2Session {
//            addPrimaryAction()
//        }

        addSecondaryAction()
    }

    private func addPrimaryAction() {
        primaryActionView.customizeAppearance(theme.primaryAction)

        primaryActionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        actionsContextView.addArrangedSubview(primaryActionView)

        primaryActionView.addTouch(
            target: self,
            action: #selector(performPrimaryAction)
        )

        togglePrimaryActionStateIfNeeded()
    }

    private func addSecondaryAction() {
        secondaryActionView.customizeAppearance(theme.secondaryAction)

        footerEffectView.addSubview(secondaryActionView)
        secondaryActionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)

        actionsContextView.addArrangedSubview(secondaryActionView)

        secondaryActionView.addTouch(
            target: self,
            action: #selector(performSecondaryAction)
        )
    }
}

extension WCSessionDetailScreen {
    private func updateUIWhenViewDidLayoutSubviews() {
        updateAdditionalSafeAreaInsetsWhenViewDidLayoutSubviews()
    }

    private func updateAdditionalSafeAreaInsetsWhenViewDidLayoutSubviews() {
        if isAdditionalSafeAreaInsetsFinalized {
            return
        }

        if secondaryActionView.bounds.isEmpty {
            return
        }

        let inset =
            theme.spacingBetweenListAndPrimaryAction +
            actionsContextView.frame.height +
            theme.actionMargins.bottom

        additionalSafeAreaInsets.bottom = inset

        isAdditionalSafeAreaInsetsFinalized = true
    }
}

extension WCSessionDetailScreen {
    @objc
    private func performPrimaryAction() {
        openExtendSessionValidity()
    }

    @objc
    private func performSecondaryAction() {
        loadingController?.startLoadingWithMessage("title-loading".localized)

        let draft = dataController.getSessionDraft()
        disconnectFromSession(draft)
    }

    private func disconnectFromSession(_ draft: WCSessionDraft) {
        if let wcV1Session = draft.wcV1Session {
            let params = WalletConnectV1SessionDisconnectionParams(session: wcV1Session)
            peraConnect.disconnectFromSession(params)
            return
        }

        if let wcV2Session = draft.wcV2Session {
            let params = WalletConnectV2SessionDisconnectionParams(session: wcV2Session)
            peraConnect.disconnectFromSession(params)
            return
        }
    }
}

extension WCSessionDetailScreen {
    private func openExtendSessionValidity() {
        let draft = dataController.getSessionDraft()
        guard let wcV2Session = draft.wcV2Session else { return }

        let eventHandler: ExtendWCSessionValiditySheet.EventHandler = {
            [unowned self] event in
            switch event {
            case .didConfirm:
                extendSessionValidity()
            case .didCancel:
                cancelExtendSessionValidity()
            }
        }

        transitionToAdvancedPermissionsInfo.perform(
            .extendWCSessionValidity(
                wcV2Session: wcV2Session,
                eventHandler: eventHandler
            ),
            by: .presentWithoutNavigationController
        )
    }

    private func extendSessionValidity() {
        /// <note> Session expiry date extendability is disabled for now. Date: 05.09.2023
    }

    private func cancelExtendSessionValidity() {
        dismiss(animated: true)
    }
}

/// <mark>
/// UICollectionViewDelegateFlowLayout
extension WCSessionDetailScreen {
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
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            referenceSizeForHeaderInSection: section
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

/// <mark>
/// UICollectionViewDelegate
extension WCSessionDetailScreen {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else { return }

        switch itemIdentifier {
        case .profile:
            startObservingProfileEvents(cell)
        case .connectionInfo:
            resumeSessionPingRepeaterIfNeeded()
            resumeSessionPingRetryRepeaterIfNeeded()

            startObservingConnectionInfoEvents(cell)
        case .advancedPermission(let item):
            switch item {
            case .header:
                startObservingAdvancedPermissionsHeaderEvents(cell)
            default:
                break
            }
        default: break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else { return }

        switch itemIdentifier {
        case .connectionInfo:
            pauseSessionPingRepeater()
            pauseSessionPingRetryRepeater()
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let account = getAccount(at: indexPath)?.value else {
            return nil
        }

        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath
        ) { _ in
            let copyActionItem = UIAction(item: .copyAddress) {
                [unowned self] _ in
                self.copyToClipboardController.copyAddress(account)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = collectionView.cellForItem(at: indexPath)
        else {
            return nil
        }

        return UITargetedPreview(
            view: cell,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = collectionView.cellForItem(at: indexPath)
        else {
            return nil
        }

        return UITargetedPreview(
            view: cell,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }
}

extension WCSessionDetailScreen {
    private func startObservingProfileEvents(_ cell: UICollectionViewCell) {
        let profileCell = cell as? WCSessionProfileCell
        profileCell?.startObserving(event: .didTapLink) {
            [unowned self] in
            let url = dataController.getDappURL()
            open(url)
        }
        profileCell?.startObserving(event: .didLongPressLink) {
            [unowned self] in
            let url = dataController.getDappURL()
            if let urlString = url?.absoluteString {
                copyToClipboardController.copyURL(urlString)
            }
        }
    }

    private func startObservingConnectionInfoEvents(_ cell: UICollectionViewCell) {
        let connectionInfoCell = cell as? WCSessionInfoCell
        connectionInfoCell?.startObserving(event: .performCheckSessionStatus) {
            [unowned self] in
            self.performCheckStatus()
        }
    }

    private func resumeSessionPingRepeaterIfNeeded() {
        if let sessionPingRepeater {
            sessionPingRepeater.resume()
        }
    }

    private func resumeSessionPingRetryRepeaterIfNeeded() {
        if let sessionPingRetryRepeater {
            sessionPingRetryRepeater.resume()
        }
    }

    private func startObservingAdvancedPermissionsHeaderEvents(_ cell: UICollectionViewCell) {
        let advancedPermissionsHeader = cell as? WCSessionAdvancedPermissionsHeader
        advancedPermissionsHeader?.startObserving(event: .performInfoAction) {
            [unowned self] in
            self.openAdvancedPermissionsInfo()
        }
    }
}

extension WCSessionDetailScreen {
    private func getAccount(at indexPath: IndexPath) -> AccountHandle? {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        guard case .connectedAccount(let item) = itemIdentifier else {
            return nil
        }

        return sharedDataController.accountCollection[item.address]
    }
}

extension WCSessionDetailScreen {
    private func openAdvancedPermissionsInfo() {
        let eventHandler: WCAdvancedPermissionsInfoSheet.EventHandler = {
            [unowned self] event in
            switch event {
            case .didClose:
                self.dismiss(animated: true)
            }
        }
        transitionToAdvancedPermissionsInfo.perform(
            .wcAdvancedPermissionsInfo(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }
}

extension WCSessionDetailScreen {
    private func togglePrimaryActionStateIfNeeded() {
        primaryActionView.isEnabled = dataController.isPrimaryActionEnabled
    }
}

extension WCSessionDetailScreen {
    private func performCheckStatus() {
        updateSessionStatusUIWhenUserDidTapCheckStatus()

        startSessionPingRetryRepeater()
    }

    private func updateSessionStatusUIWhenUserDidTapCheckStatus() {
        let progress = ALGProgress(
            totalUnitCount: 3,
            currentUnitCount: 1
        )
        let status = WCSessionStatus.pinging(progress: progress)
        updateSessionStatusUI(status)

        startSessionPingRepeater(with: progress)
    }

    private func startSessionPingRepeater(with progress: ALGProgress) {
        sessionPingRepeater = Repeater(intervalInSeconds: 0.5) {
            [weak self] in
            self?.handleSessionPingRepeaterTick(progress)
        }

        sessionPingRepeaterEndDate = Date() + sessionPingTimeoutInSeconds
        sessionPingRepeater?.resume()
    }

    private func handleSessionPingRepeaterTick(_ progress: ALGProgress) {
        guard
            let remainingTime = sessionPingRepeaterEndDate?.timeIntervalSinceNow,
            remainingTime > 1
        else {
            handleFailedSessionPing()
            return
        }

        let status = WCSessionStatus.pinging(progress: progress)
        updateSessionStatusUI(status)

        progress()

        if progress.isFinished {
            progress.currentUnitCount = 1
        }
    }

    private func handleFailedSessionPing() {
        guard
            let sessionPingRepeater,
            sessionPingRepeater.isRunning
        else {
            return
        }

        resetSessionPingRepeater()
        resetSessionPingRetryTimer()

        updateSessionStatusUI(.failed)

        resetSessionStatusUIAfterDelay()
    }

    private func handleActiveSessionPing() {
        guard
            let sessionPingRepeater,
            sessionPingRepeater.isRunning
        else {
            return
        }

        resetSessionPingRepeater()
        resetSessionPingRetryTimer()

        updateSessionStatusUI(.active)

        resetSessionStatusUIAfterDelay()
    }

    private func pauseSessionPingRepeater() {
        sessionPingRepeater?.pause()
    }

    private func resetSessionPingRepeater() {
        pauseSessionPingRepeater()
        sessionPingRepeater = nil
        sessionPingRepeaterEndDate = nil
    }

    private func updateSessionStatusUI(_ status: WCSessionStatus) {
        dataController.sessionInfoViewModel?.bindSessionStatus(status)

        guard let indexPath = dataSource.indexPath(for: .connectionInfo) else {
            return
        }

        asyncMain {
            [weak self] in
            let cell = self?.listView.cellForItem(at: indexPath) as? WCSessionInfoCell
            let viewModel = self?.dataController.sessionInfoViewModel?.sessionStatus
            cell?.bindSessionStatus(viewModel)
        }
    }

    private func resetSessionStatusUIAfterDelay() {
        let time: DispatchTime = .now() + resetCheckStatusDelayAfterPingingResultInSeconds
        let queue: DispatchQueue = .main
        queue.asyncAfter(deadline: time) {
            [weak self] in
            guard let self else { return }
            updateSessionStatusUI(.idle)
        }
    }

    private func startSessionPingRetryRepeater() {
        sessionPingRetryRepeater = Repeater(intervalInSeconds: sessionPingRetryInterval) {
            [weak self, weak sessionPingRetryRepeater] in
            guard let self else { return  }

            if let sessionPingRepeater,
               sessionPingRepeater.isRunning {
                pingSession()
            } else {
                sessionPingRetryRepeater?.pause()
            }
        }
        sessionPingRetryRepeater?.resume()
    }

    private func pingSession() {
        let draft = dataController.getSessionDraft()
        guard let wcV2Session = draft.wcV2Session else { return }

        let wcV2Protocol =
            peraConnect.walletConnectCoordinator.walletConnectProtocolResolver.walletConnectV2Protocol
        wcV2Protocol.pingSession(wcV2Session)
    }

    private func pauseSessionPingRetryRepeater() {
        sessionPingRetryRepeater?.pause()
    }

    private func resetSessionPingRetryTimer() {
        pauseSessionPingRetryRepeater()
        sessionPingRetryRepeater = nil
    }
}

extension WCSessionDetailScreen {
    func peraConnect(
        _ peraConnect: PeraConnect,
        didPublish event: PeraConnectEvent
    ) {
        switch event {
        case .pingV2(let topic):
            let draft = dataController.getSessionDraft()
            guard topic == draft.wcV2Session?.topic else { return }

            handleActiveSessionPing()
        case .didPingV2SessionFail(let session, _):
            let draft = dataController.getSessionDraft()
            guard session.topic == draft.wcV2Session?.topic else { return }

            handleFailedSessionPing()
        case .didDisconnectFromV1(let session):
            let draft = dataController.getSessionDraft()
            guard session == draft.wcV1Session else { return }

            asyncMain {
                [weak self] in
                guard let self else { return }

                loadingController?.stopLoading()

                eventHandler?(.didDisconnect)
            }
        case .didDisconnectFromV1Fail(let session, let error):
            let draft = dataController.getSessionDraft()
            guard session == draft.wcV1Session else { return }

            asyncMain {
                [weak self] in
                guard let self else { return }

                loadingController?.stopLoading()

                switch error {
                case .failedToDisconnectInactiveSession:
                    eventHandler?(.didDisconnect)
                case .failedToDisconnect:
                    bannerController?.presentErrorBanner(
                        title: "title-error".localized,
                        message: "title-generic-error".localized
                    )
                default: break
                }
            }
        case .didDisconnectFromV2(let session):
            let draft = dataController.getSessionDraft()
            guard session.topic == draft.wcV2Session?.topic else { return }

            asyncMain {
                [weak self] in
                guard let self else { return }

                loadingController?.stopLoading()

                eventHandler?(.didDisconnect)
            }
        case .didDisconnectFromV2Fail(let session, let error):
            let draft = dataController.getSessionDraft()
            guard session.topic == draft.wcV2Session?.topic else { return }

            asyncMain {
                [weak self] in
                guard let self else { return }
                loadingController?.stopLoading()

                bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: error.localizedDescription
                )
            }
        case .deleteSessionV2(let topic, _):
            let draft = dataController.getSessionDraft()
            guard topic == draft.wcV2Session?.topic else { return }

            asyncMain {
                [weak self] in
                guard let self else { return }

                loadingController?.stopLoading()

                eventHandler?(.didDisconnect)
            }
        default:
            break
        }
    }
}

extension WCSessionDetailScreen {
    enum Event {
        case didDisconnect
    }
}
