// Copyright 2019 Algorand, Inc.

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

import UIKit
import Macaroon

class RootViewController: UIViewController {
    
    private var shouldHideTestNetBanner: Bool {
        return tabBarViewController.parent == nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyleForNetwork(isTestNet: appConfiguration.api.isTestNet)
    }
    
    private lazy var pushNotificationController = PushNotificationController(api: appConfiguration.api)
    
    lazy var statusBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.zPosition = 1.0
        view.backgroundColor = Colors.General.testNetBanner
        return view
    }()

    let appConfiguration: AppConfiguration
    
    private var router: Router?

    private let onceWhenViewDidAppear = Once()

    private(set) var isDisplayingGovernanceBanner = true

    private lazy var wcTransactionSuccessModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .backgroundTouch
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 350.0))
    )

    private lazy var deepLinkRouter = DeepLinkRouter(rootViewController: self, appConfiguration: appConfiguration)
    
    private(set) lazy var tabBarViewController = TabBarController(configuration: appConfiguration.all())

    private var currentWCTransactionRequest: WalletConnectRequest?

    private var wcMainTransactionViewController: WCMainTransactionViewController?
    
    init(appConfiguration: AppConfiguration) {
        self.appConfiguration = appConfiguration
        super.init(nibName: nil, bundle: nil)
        self.router = Router(rootViewController: self)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.Background.primary

        initializeNetwork()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        onceWhenViewDidAppear.execute {
            changeUserInterfaceStyle(to: appConfiguration.api.session.userInterfaceStyle)
            addBanner()
            deepLinkRouter.initializeFlow()
        }
    }
}

extension RootViewController {
    @discardableResult
    func route<T: UIViewController>(
        to screen: Screen,
        from viewController: UIViewController,
        by style: Screen.Transition.Open,
        animated: Bool = true,
        then completion: EmptyHandler? = nil
    ) -> T? {
        return router?.route(to: screen, from: viewController, by: style, animated: animated, then: completion)
    }
}

extension RootViewController {
    func setupTabBarController(withInitial screen: Screen? = nil) {
        if tabBarViewController.parent != nil {
            return
        }

        addChild(tabBarViewController)
        view.addSubview(tabBarViewController.view)

        tabBarViewController.view.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        tabBarViewController.route = screen
        tabBarViewController.routeForDeeplink()
        tabBarViewController.didMove(toParent: self)
    }
}

extension RootViewController {
    func handleDeepLinkRouting(for screen: Screen) -> Bool {
        return deepLinkRouter.handleDeepLinkRouting(for: screen)
    }

    func openAsset(from notification: NotificationDetail, for account: String) {
        deepLinkRouter.openAsset(from: notification, for: account)
    }

    func hideGovernanceBanner() {
        isDisplayingGovernanceBanner = false
    }
}

extension RootViewController: AlgorandNetworkUpdatable { }

extension RootViewController: BannerDisplayable {
    var shouldDisplayBanner: Bool {
        return appConfiguration.api.isTestNet
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
        if let currentWCTransactionRequest = currentWCTransactionRequest {
            if currentWCTransactionRequest.isSameTransactionRequest(with: request) {
                return
            }

            appConfiguration.walletConnector.rejectTransactionRequest(currentWCTransactionRequest, with: .rejected(.alreadyDisplayed))

            wcMainTransactionViewController?.closeScreen(by: .dismiss, animated: false) {
                self.openMainViewController(animated: false, for: transactions, with: request, and: transactionOption)
            }
        } else {
            openMainViewController(animated: true, for: transactions, with: request, and: transactionOption)
        }
    }

    private func openMainViewController(
        animated: Bool,
        for transactions: [WCTransaction],
        with request: WalletConnectRequest,
        and transactionOption: WCTransactionOption?
    ) {
        let fullScreenPresentation = Screen.Transition.Open.customPresent(
            presentationStyle: .fullScreen,
            transitionStyle: nil,
            transitioningDelegate: nil
        )

        currentWCTransactionRequest = request

        /// If there's already a modal presented screen, open the request on top of that screen.
        let presentingController: UIViewController?
        if let controller = topMostController,
           controller.isModal {
            presentingController = controller
        } else {
            presentingController = self
        }

        wcMainTransactionViewController = presentingController?.open(
            .wcMainTransaction(
                transactions: transactions,
                transactionRequest: request,
                transactionOption: transactionOption
            ),
            by: fullScreenPresentation,
            animated: animated
        ) as? WCMainTransactionViewController

        wcMainTransactionViewController?.delegate = self
    }
}

extension RootViewController: WCMainTransactionViewControllerDelegate {
    func wcMainTransactionViewController(
        _ wcMainTransactionViewController: WCMainTransactionViewController,
        didSigned request: WalletConnectRequest,
        in session: WCSession?
    ) {
        resetCurrentWCTransaction()

        guard let wcSession = session else {
            return
        }

        presentWCTransactionSuccessMessage(for: wcSession)
    }

    private func presentWCTransactionSuccessMessage(for session: WCSession) {
        let transitionStyle = Screen.Transition.Open.customPresent(
            presentationStyle: .custom,
            transitionStyle: nil,
            transitioningDelegate: wcTransactionSuccessModalPresenter
        )

        let dappName = session.peerMeta.name

        /// <todo>
        /// These texts will be localized later.
        let warningAlert = WarningAlert(
            title: "Your transaction is being processed!",
            image: img("img-green-checkmark"),
            description: "The transaction has been signed and sent to \(dappName). Please visit \(dappName) for the remaining process.",
            actionTitle: "title-close".localized
        )

        asyncMainAfter(duration: 0.3) { [weak self] in
            guard let self = self else {
                return
            }

            self.open(.warningAlert(warningAlert: warningAlert), by: transitionStyle)
        }
    }

    func wcMainTransactionViewController(
        _ wcMainTransactionViewController: WCMainTransactionViewController,
        didRejected request: WalletConnectRequest
    ) {
        resetCurrentWCTransaction()
    }

    private func resetCurrentWCTransaction() {
        currentWCTransactionRequest = nil
        wcMainTransactionViewController = nil
    }
}

extension RootViewController: UserInterfaceChangable { }

extension RootViewController {
    func deleteAllData() {
        appConfiguration.session.reset(isContactIncluded: true)
        appConfiguration.walletConnector.resetAllSessions()
        NotificationCenter.default.post(name: .ContactDeletion, object: self, userInfo: nil)
        pushNotificationController.revokeDevice()
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
