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
//  RootViewController.swift

import Foundation
import MacaroonUIKit
import MacaroonUtils
import UIKit

final class RootViewController: UIViewController {
    var areTabsVisible: Bool {
        return !mainContainer.items.isEmpty
    }

    private(set) var isDisplayingGovernanceBanner = true

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return determinePreferredStatusBarStyle(for: appConfiguration.api.network)
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return areTabsVisible ? mainContainer.preferredStatusBarUpdateAnimation : .fade
    }
    override var childForStatusBarStyle: UIViewController? {
        return areTabsVisible ? mainContainer : nil
    }
    override var childForStatusBarHidden: UIViewController? {
        return areTabsVisible ? mainContainer : nil
    }

    private lazy var mainContainer = TabBarController(
        swapDataStore: SwapDataLocalStore(),
        analytics: appConfiguration.analytics,
        api: appConfiguration.api,
        bannerController: appConfiguration.bannerController,
        loadingController: appConfiguration.loadingController,
        session: appConfiguration.session,
        sharedDataController: appConfiguration.sharedDataController
    )

    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: appConfiguration.session,
        api: appConfiguration.api
    )

    private lazy var walletConnectV2RequestHandler: WalletConnectV2RequestHandler = {
        let handler = WalletConnectV2RequestHandler(analytics: appConfiguration.analytics)
        handler.delegate = self
        return handler
    }()

    typealias HasOngoingWCRequest = Bool
    private var sessionsForOngoingWCRequests: [WalletConnectTopic: HasOngoingWCRequest] = [:]

    private var transitionToWCTransactionSignSuccessful: BottomSheetTransition?
    private var wcArbitraryDataSuccessTransition: BottomSheetTransition?

    let target: ALGAppTarget
    let appConfiguration: AppConfiguration
    let launchController: AppLaunchController

    init(
        target: ALGAppTarget,
        appConfiguration: AppConfiguration,
        launchController: AppLaunchController
    ) {
        self.target = target
        self.appConfiguration = appConfiguration
        self.launchController = launchController

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }
}

extension RootViewController {
    func launchTabsIfNeeded() {
        if areTabsVisible {
            return
        }

        let configuration = appConfiguration.all()
        let announcementAPIDataController = AnnouncementAPIDataController(
            api: configuration.api!,
            session: configuration.session!
        )

        let homeViewController = HomeViewController(
            swapDataStore: SwapDataLocalStore(),
            dataController: HomeAPIDataController(
                sharedDataController: appConfiguration.sharedDataController,
                session: appConfiguration.session,
                announcementDataController: announcementAPIDataController
            ),
            copyToClipboardController: ALGCopyToClipboardController(
                toastPresentationController: appConfiguration.toastPresentationController
            ),
            configuration: configuration
        )
        let homeTab = HomeTabBarItem(
            NavigationContainer(rootViewController: homeViewController)
        )

        let discoverViewController = DiscoverHomeScreen(configuration: configuration)
        let discoverTab = DiscoverTabBarItem(
            NavigationContainer(rootViewController: discoverViewController)
        )

        let collectibleListQuery = CollectibleListQuery(
            filteringBy: .init(),
            sortingBy: appConfiguration.sharedDataController.selectedCollectibleSortingAlgorithm
        )
        let collectibleListViewController = CollectiblesViewController(
            query: collectibleListQuery,
            dataController: CollectibleListLocalDataController(
                galleryAccount: .all,
                sharedDataController: appConfiguration.sharedDataController
            ),
            copyToClipboardController: ALGCopyToClipboardController(
                toastPresentationController: appConfiguration.toastPresentationController
            ),
            configuration: configuration
        )
        let collectiblesTab =
            CollectiblesTabBarItem(NavigationContainer(rootViewController: collectibleListViewController))

        let settingsViewController = SettingsViewController(configuration: configuration)
        let settingsTab =
            SettingsTabBarItem(NavigationContainer(rootViewController: settingsViewController))

        mainContainer.items = [
            homeTab,
            discoverTab,
            FixedSpaceTabBarItem(width: .noMetric),
            collectiblesTab,
            settingsTab
        ]

        setNeedsDiscoverTabBarItemUpdateIfNeeded()
    }

    func launch(
        tab: TabBarItemID
    ) {
        mainContainer.selectedTab = tab
    }

    func terminateTabs() {
        mainContainer.items = []
    }
}

extension RootViewController {
    private func setNeedsDiscoverTabBarItemUpdateIfNeeded() {
        mainContainer.setNeedsDiscoverTabBarItemUpdateIfNeeded()
    }
}

extension RootViewController: WalletConnectRequestHandlerDelegate {
    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        shouldSign arbitraryData: [WCArbitraryData],
        for request: WalletConnectRequest
    ) {
        let topic = request.url.topic
        guard let session = walletConnector.getWalletConnectSession(for: topic) else {
            let params = WalletConnectV1RejectTransactionRequestParams(
                v1Request: request,
                error: .invalidInput(.session)
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return
        }

        if hasOngoingWCRequest(for: topic) {
            let params = WalletConnectV1RejectTransactionRequestParams(
                v1Request: request,
                error: .rejected(.alreadyDisplayed)
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return
        }

        addOngoingWCRequest(for: topic)

        let draft = WalletConnectArbitraryDataSignRequestDraft(
            request: WalletConnectRequestDraft(wcV1Request: request),
            arbitraryData: arbitraryData,
            session: WCSessionDraft(wcV1Session: session)
        )
        launchController.receive(deeplinkWithSource: .walletConnectArbitraryDataSignRequest(draft))
    }

    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        didInvalidateArbitraryDataRequest request: WalletConnectRequest
    ) {
        let params = WalletConnectV1RejectTransactionRequestParams(
            v1Request: request,
            error: .invalidInput(.dataParse)
        )
        appConfiguration.peraConnect.rejectTransactionRequest(params)
    }

    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        shouldSign transactions: [WCTransaction],
        for request: WalletConnectRequest,
        with transactionOption: WCTransactionOption?
    ) {
        let topic = request.url.topic
        guard let session = walletConnector.getWalletConnectSession(for: topic) else {
            let params = WalletConnectV1RejectTransactionRequestParams(
                v1Request: request,
                error: .invalidInput(.session)
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return
        }

        if hasOngoingWCRequest(for: topic) {
            let params = WalletConnectV1RejectTransactionRequestParams(
                v1Request: request,
                error: .rejected(.alreadyDisplayed)
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return
        }

        addOngoingWCRequest(for: topic)

        let draft = WalletConnectTransactionSignRequestDraft(
            request: WalletConnectRequestDraft(wcV1Request: request),
            transactions: transactions,
            option: transactionOption,
            session: WCSessionDraft(wcV1Session: session)
        )
        launchController.receive(deeplinkWithSource: .walletConnectTransactionSignRequest(draft))
    }

    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        didInvalidateTransactionRequest request: WalletConnectRequest
    ) {
        let params = WalletConnectV1RejectTransactionRequestParams(
            v1Request: request,
            error: .invalidInput(.transactionParse)
        )
        appConfiguration.peraConnect.rejectTransactionRequest(params)
    }
}

extension RootViewController: PeraConnectObserver {
    func startObservingPeraConnectEvents() {
        appConfiguration.peraConnect.add(self)
    }

    func peraConnect(
        _ peraConnect: PeraConnect,
        didPublish event: PeraConnectEvent
    ) {
        switch event {
        case .transactionRequestV2(let request):
            if walletConnectV2RequestHandler.canHandle(request: request) {
                walletConnectV2RequestHandler.handle(request: request)
                return
            }

            let params = WalletConnectV2RejectTransactionRequestParams(
                error: .unsupportedMethods,
                v2Request: request
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
        default: break
        }
    }
}

extension RootViewController: WalletConnectV2RequestHandlerDelegate {
    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectV2RequestHandler,
        shouldSign transactions: [WCTransaction],
        for request: WalletConnectV2Request,
        with transactionOption: WCTransactionOption?
    ) {
        let wcV2Protocol = 
            appConfiguration.peraConnect.walletConnectCoordinator.walletConnectProtocolResolver.walletConnectV2Protocol

        let sessions = wcV2Protocol.getSessions()
        let topic = request.topic
        guard let session = sessions.first(matching: (\WalletConnectV2Session.topic, topic)) else {
            let params = WalletConnectV2RejectTransactionRequestParams(
                error: .noSessionForTopic,
                v2Request: request
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return
        }

        let requiredNamespaces = session.requiredNamespaces[WalletConnectNamespaceKey.algorand]
        guard let requiredNamespaces,
              request.chainId.namespace == WalletConnectNamespaceKey.algorand else {
            let params = WalletConnectV2RejectTransactionRequestParams(
                error: .unsupportedNamespace,
                v2Request: request
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return
        }

        let authorizedMethods = requiredNamespaces.methods
        let requestedMethod = request.method
        guard authorizedMethods.contains(requestedMethod) else {
            let params = WalletConnectV2RejectTransactionRequestParams(
                error: .unauthorizedMethod(requestedMethod),
                v2Request: request
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return
        }

        let authorizedChains = requiredNamespaces.chains ?? []
        let requestedChain = request.chainId
        guard authorizedChains.contains(requestedChain) else {
            let network = ALGAPI.Network(blockchain: requestedChain)
            let networkTitle = network.unwrap(\.rawValue.capitalized) ?? requestedChain.reference
            let params = WalletConnectV2RejectTransactionRequestParams(
                error: .unauthorizedChain(networkTitle),
                v2Request: request
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return
        }

        let requestedChainReference = requestedChain.reference
        guard
            requestedChainReference == algorandWalletConnectV2TestNetChainReference ||
            requestedChainReference == algorandWalletConnectV2MainNetChainReference
        else {
            let params = WalletConnectV2RejectTransactionRequestParams(
                error: .unsupportedChains,
                v2Request: request
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return
        }

        let supportedMethods =  WalletConnectMethod.allCases.map(\.rawValue)
        guard supportedMethods.contains(requestedMethod) else {
            let params = WalletConnectV2RejectTransactionRequestParams(
                error: .unsupportedMethods,
                v2Request: request
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return
        }

        if hasOngoingWCRequest(for: topic) {
            let params = WalletConnectV2RejectTransactionRequestParams(
                error: .rejected(.alreadyDisplayed),
                v2Request: request
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return
        }

        addOngoingWCRequest(for: topic)

        let draft = WalletConnectTransactionSignRequestDraft(
            request: WalletConnectRequestDraft(wcV2Request: request),
            transactions: transactions,
            session: WCSessionDraft(wcV2Session: session)
        )
        launchController.receive(deeplinkWithSource: .walletConnectTransactionSignRequest(draft))
    }

    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectV2RequestHandler,
        didInvalidateTransactionRequest request: WalletConnectV2Request
    ) {
        let params = WalletConnectV2RejectTransactionRequestParams(
            error: .invalidInput(.transactionParse),
            v2Request: request
        )
        appConfiguration.peraConnect.rejectTransactionRequest(params)
    }
}

extension RootViewController: WCMainArbitraryDataScreenDelegate {
    func wcMainArbitraryDataScreen(
        _ wcMainArbitraryDataScreen: WCMainArbitraryDataScreen,
        didRejected request: WalletConnectRequestDraft
    ) {
        clearOngoingWCRequest(for: request)

        wcMainArbitraryDataScreen.dismissScreen()
    }

    func wcMainArbitraryDataScreen(
        _ wcMainArbitraryDataScreen: WCMainArbitraryDataScreen,
        didSigned request: WalletConnectRequestDraft,
        in session: WCSessionDraft
    ) {
        clearOngoingWCRequest(for: request)

        wcMainArbitraryDataScreen.dismissScreen {
            [weak self] in
            guard let self else { return }
            self.presentWCArbitraryDataSuccessMessage(for: session)
        }
    }

    private func presentWCArbitraryDataSuccessMessage(for session: WCSessionDraft) {
        let dappName =
            session.wcV1Session?.peerMeta.name ??
            session.wcV2Session?.peer.name ??
            .empty
        let configurator = BottomWarningViewConfigurator(
            image: "icon-approval-check".uiImage,
            title: "wc-arbitrary-data-request-signed-warning-title".localized,
            description: .plain(
                "wc-arbitrary-data-request-signed-warning-message".localized(params: dappName, dappName)
            ),
            primaryActionButtonTitle: nil,
            secondaryActionButtonTitle: "title-close".localized
        )
        let transition = BottomSheetTransition(presentingViewController: findVisibleScreen())

        transition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )

        self.wcArbitraryDataSuccessTransition = transition
    }
}

extension RootViewController: WCMainTransactionScreenDelegate {
    func wcMainTransactionScreen(
        _ wcMainTransactionScreen: WCMainTransactionScreen,
        didSigned request: WalletConnectRequestDraft,
        in session: WCSessionDraft
    ) {
        clearOngoingWCRequest(for: session)

        wcMainTransactionScreen.dismissScreen {
            [weak self] in
            guard let self else { return }
            self.openWCTransactionSignSuccessful(session)
        }
    }

    func wcMainTransactionScreen(
        _ wcMainTransactionScreen: WCMainTransactionScreen,
        didRejected request: WalletConnectRequestDraft
    ) {
        clearOngoingWCRequest(for: request)
        
        wcMainTransactionScreen.dismissScreen()
    }

    private func openWCTransactionSignSuccessful(_ draft: WCSessionDraft) {
        let visibleScreen = findVisibleScreen()
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        let eventHandler: WCTransactionSignSuccessfulSheet.EventHandler = {
            [weak visibleScreen] event in
            guard let visibleScreen else { return }
            switch event {
            case .didClose:
                visibleScreen.presentedViewController?.dismiss(animated: true)
            }
        }

        transition.perform(
            .wcTransactionSignSuccessful(
                draft: draft,
                eventHandler: eventHandler
            ),
            by: .presentWithoutNavigationController
        )

        transitionToWCTransactionSignSuccessful = transition
    }
}

extension RootViewController {
    private func hasOngoingWCRequest(for topic: WalletConnectTopic) -> Bool {
        return sessionsForOngoingWCRequests[topic] != nil
    }

    private func addOngoingWCRequest(for topic: WalletConnectTopic) {
        sessionsForOngoingWCRequests[topic] = true
    }

    private func clearOngoingWCRequest(for session: WCSessionDraft) {
        let topic =
            session.wcV1Session?.urlMeta.topic ??
            session.wcV2Session?.topic
        guard let topic else { return }
        sessionsForOngoingWCRequests[topic] = nil
    }

    private func clearOngoingWCRequest(for request: WalletConnectRequestDraft) {
        let topic =
            request.wcV1Request?.url.topic ??
            request.wcV2Request?.topic
        guard let topic else { return }
        sessionsForOngoingWCRequests[topic] = nil
    }
}

extension RootViewController {
    func deleteAllData(
        onCompletion handler: @escaping BoolHandler
    ) {
        appConfiguration.loadingController.startLoadingWithMessage("title-loading".localized)

        appConfiguration.sharedDataController.stopPolling()

        pushNotificationController.revokeDevice() { [weak self] isCompleted in
            guard let self = self else {
                return
            }

            if isCompleted {
                self.appConfiguration.session.reset(includingContacts: true)

                self.appConfiguration.peraConnect.disconnectFromAllSessions()

                self.appConfiguration.sharedDataController.resetPolling()

                NotificationCenter.default.post(name: .ContactDeletion, object: self, userInfo: nil)
            } else {
                self.appConfiguration.sharedDataController.startPolling()
            }

             self.appConfiguration.loadingController.stopLoading()
             handler(isCompleted)
        }
    }
}

extension RootViewController {
    private func build() {
        addBackground()
        addMain()
    }

    private func addBackground() {
        view.backgroundColor = Colors.Defaults.background.uiColor
    }

    private func addMain() {
        addContent(mainContainer) {
            contentView in
            view.addSubview(contentView)
            contentView.snp.makeConstraints {
                $0.top == 0
                $0.leading == 0
                $0.bottom == 0
                $0.trailing == 0
            }
        }
    }
}

extension RootViewController {
    private var walletConnector: WalletConnectV1Protocol {
        return appConfiguration.walletConnector
    }
}

extension WalletConnectRequest {
    func isSameTransactionRequest(with request: WalletConnectRequest) -> Bool {
        if let firstId = id as? Int,
           let secondId = request.id as? Int {
            return firstId == secondId
        }

        if let firstId = id as? String,
           let secondId = request.id as? String {
            return firstId == secondId
        }

        if let firstId = id as? Double,
           let secondId = request.id as? Double {
            return firstId == secondId
        }

        return false
    }
}
