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

class RootViewController: UIViewController {
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
        api: appConfiguration.api,
        bannerController: appConfiguration.bannerController
    )

    private var currentWCTransactionRequest: WalletConnectRequest?
    private var wcRequestScreen: WCMainTransactionScreen?
    private var wcTransactionSuccessTransition: BottomSheetTransition?

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
                appConfiguration.sharedDataController,
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

        let collectibleListViewController = CollectiblesViewController(
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
        shouldSign transactions: [WCTransaction],
        for request: WalletConnectRequest,
        with transactionOption: WCTransactionOption?
    ) {
        openMainTransactionScreen(transactions, for: request, with: transactionOption)
    }

    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        didInvalidate request: WalletConnectRequest
    ) {
        appConfiguration.walletConnector.rejectTransactionRequest(request, with: .invalidInput(.parse))
    }

    private func openMainTransactionScreen(
        _ transactions: [WCTransaction],
        for request: WalletConnectRequest,
        with transactionOption: WCTransactionOption?
    ) {
        openMainViewController(animated: true, for: transactions, with: request, and: transactionOption)

//        if let currentWCTransactionRequest = currentWCTransactionRequest {
//            if currentWCTransactionRequest.isSameTransactionRequest(with: request) {
//                return
//            }
//
//            appConfiguration.walletConnector.rejectTransactionRequest(currentWCTransactionRequest, with: .rejected(.alreadyDisplayed))
//
//            wcRequestScreen?.closeScreen(by: .dismiss, animated: false) {
//                self.openMainViewController(animated: false, for: transactions, with: request, and: transactionOption)
//            }
//        } else {
//            openMainViewController(animated: true, for: transactions, with: request, and: transactionOption)
//        }
    }

    private func openMainViewController(
        animated: Bool,
        for transactions: [WCTransaction],
        with request: WalletConnectRequest,
        and transactionOption: WCTransactionOption?
    ) {
        currentWCTransactionRequest = request

        let draft = WalletConnectRequestDraft(
            request: request,
            transactions: transactions,
            option: transactionOption
        )
        launchController.receive(deeplinkWithSource: .walletConnectRequest(draft))
    }
}

extension RootViewController: WCMainTransactionScreenDelegate {
    func wcMainTransactionScreen(
        _ wcMainTransactionScreen: WCMainTransactionScreen,
        didRejected request: WalletConnectRequest
    ) {
        resetCurrentWCTransaction()
        wcMainTransactionScreen.dismissScreen()
    }

    func wcMainTransactionScreen(
        _ wcMainTransactionScreen: WCMainTransactionScreen,
        didSigned request: WalletConnectRequest,
        in session: WCSession?
    ) {
        resetCurrentWCTransaction()

        guard let wcSession = session else {
            return
        }

        wcMainTransactionScreen.dismissScreen {
            [weak self] in
            guard let self = self else { return }

            self.presentWCTransactionSuccessMessage(for: wcSession)
        }
    }

    private func presentWCTransactionSuccessMessage(for session: WCSession) {
        let dappName = session.peerMeta.name
        let configurator = BottomWarningViewConfigurator(
            image: "icon-approval-check".uiImage,
            title: "wc-transaction-request-signed-warning-title".localized,
            description: .plain(
                "wc-transaction-request-signed-warning-message".localized(dappName, dappName)
            ),
            primaryActionButtonTitle: nil,
            secondaryActionButtonTitle: "title-close".localized
        )
        let transition = BottomSheetTransition(presentingViewController: findVisibleScreen())

        transition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )

        self.wcTransactionSuccessTransition = transition
    }

    private func resetCurrentWCTransaction() {
        currentWCTransactionRequest = nil
        wcRequestScreen = nil
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

                self.appConfiguration.walletConnector.disconnectFromAllSessions()
                self.appConfiguration.walletConnector.resetAllSessions()

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
