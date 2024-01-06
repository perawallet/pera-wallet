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
//  AppDelegate.swift

import CoreData
import Firebase
import FirebaseCrashlytics
import Foundation
import MacaroonUIKit
import MacaroonUtils
import SwiftDate
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate:
    UIResponder,
    UIApplicationDelegate,
    AppLaunchUIHandler,
    SharedDataControllerObserver,
    NotificationObserver {
    static var shared: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }

    var window: UIWindow?

    var notificationObservations: [NSObjectProtocol] = []

    private(set) lazy var persistentContainer = createPersistentContainer()
    private(set) lazy var appConfiguration = createAppConfiguration()

    private lazy var appLaunchController = createAppLaunchController()
    private lazy var session = createSession()
    private lazy var api = createAPI()
    private lazy var sharedDataController = createSharedDataController()
    private lazy var walletConnectCoordinator = createWalletConnectCoordinator()
    private lazy var loadingController = createLoadingController()
    private lazy var toastPresentationController = createToastPresentationController()
    private lazy var bannerController = createBannerController()
    private lazy var analytics = createAnalytics()
    private lazy var peraConnect = createPeraConnect()
    private lazy var router = createRouter()
    private lazy var rootViewController = createRootViewController()
    private lazy var pushNotificationController = createPushNotificationController()
    private lazy var lastSeenNotificationController = createLastSeenNotificationController()

    private lazy var networkBannerView = UIView()
    private lazy var containerBlurView = UIVisualEffectView()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setupAppTarget()
        setupAppLibs()
        runMigrations()

        prepareForLaunch()

        makeWindow()
        makeNetworkBanner()

        launch(with: launchOptions)
        
        walletConnectCoordinator.setup()

        return true
    }
    
    func applicationWillEnterForeground(
        _ application: UIApplication
    ) {
        removeBlurOnWindow()

        lastSeenNotificationController.checkStatus()
    }
    
    func applicationDidBecomeActive(
        _ application: UIApplication
    ) {
        setNeedsUserInterfaceStyleUpdateIfNeeded()
        setNeedsNetworkBannerUpdateIfNeeded()

        appLaunchController.becomeActive()

        lastSeenNotificationController.checkStatus()
    }
    
    func applicationWillResignActive(
        _ application: UIApplication
    ) {
        appLaunchController.resignActive()
    }
    
    func applicationDidEnterBackground(
        _ application: UIApplication
    ) {
        appLaunchController.enterBackground()

        showBlurOnWindow()
    }

    func applicationWillTerminate(
        _ application: UIApplication
    ) {
        saveContext()

        appLaunchController.terminate()
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        authorizeNotifications(for: deviceToken)
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        NotificationCenter.default.post(
            name: .NotificationDidReceived,
            object: self,
            userInfo: nil
        )
        
        appLaunchController.receive(
            deeplinkWithSource: .remoteNotification(
                userInfo,
                waitForUserConfirmation: UIApplication.shared.isActive
            )
        )
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        if let moonPayParams = url.extractMoonPayParams() {
            NotificationCenter.default.post(
                name: .didRedirectFromMoonPay,
                object: self,
                userInfo: [MoonPayParams.notificationObjectKey: moonPayParams]
            )

            return true
        }

        if let inAppBrowserDeeplinkURL = url.inAppBrowserDeeplinkURL {
            let destination = DiscoverExternalDestination.redirection(inAppBrowserDeeplinkURL, api.network)
            receive(deeplinkWithSource: .externalInAppBrowser(destination))
            return true
        }

        let deeplinkQR = DeeplinkQR(url: url)

        if let walletConnectURL = deeplinkQR.walletConnectUrl() {
            receive(deeplinkWithSource: .walletConnectSessionRequest(walletConnectURL))
            return true
        }

        if let qrText = deeplinkQR.qrText() {
            receive(deeplinkWithSource: .qrText(qrText))
            return true
        }

        return false
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL
        else {
            return false
        }

        let deeplinkQR = DeeplinkQR(url: incomingURL)

        if let walletConnectURL = deeplinkQR.walletConnectUrl() {
            receive(deeplinkWithSource: .walletConnectSessionRequest(walletConnectURL))
            return true
        }

        if let qrText = deeplinkQR.qrText() {
            receive(deeplinkWithSource: .qrText(qrText))
            return true
        }

        return false
    }
}

extension AppDelegate {
    func prepareForLaunch() {
        appLaunchController.prepareForLaunch()
    }
    
    func launch(
        with options: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        let src: DeeplinkSource?
        
        if let userInfo = options?[.remoteNotification] as? DeeplinkSource.UserInfo {
            src = .remoteNotification(userInfo, waitForUserConfirmation: false)
        } else if let url = options?[.url] as? URL {
            if let inAppBrowserDeeplinkURL = url.inAppBrowserDeeplinkURL {
                let destination = DiscoverExternalDestination.redirection(inAppBrowserDeeplinkURL, api.network)

                src = .externalInAppBrowser(destination)
            } else {
                let deeplinkQR = DeeplinkQR(url: url)

                if let qrText = deeplinkQR.qrText() {
                    src = .qrText(qrText)
                } else {
                    src = nil
                }
            }
        } else {
            src = nil
        }

        appLaunchController.launch(deeplinkWithSource: src)
    }
    
    func launchOnboarding() {
        appLaunchController.launchOnboarding()
    }
    
    func launchMain(
        completion: (() -> Void)? = nil
    ) {
        appLaunchController.launchMain(completion: completion)
    }
    
    func launchMainAfterAuthorization(
        presented viewController: UIViewController
    ) {
        appLaunchController.launchMainAfterAuthorization(presented: viewController)
    }
    
    @discardableResult
    func route<T: UIViewController>(
        to screen: Screen,
        from viewController: UIViewController,
        by style: Screen.Transition.Open,
        animated: Bool = true,
        then completion: EmptyHandler? = nil
    ) -> T? {
        return router.route(
            to: screen,
            from: viewController,
            by: style,
            animated: animated,
            then: completion
        )
    }
    
    func findVisibleScreen() -> UIViewController {
        return router.findVisibleScreen()
    }
}

extension AppDelegate {
    func launchUI(
        _ state: AppLaunchUIState
    ) {
        switch state {
        case .authorization:
            router.launchAuthorization()
        case .onboarding:
            router.launchOnboarding()
        case .main(let completion):
            router.launchMain(completion: completion)
        case .mainAfterAuthorization(let presentedViewController, let completion):
            router.launcMainAfterAuthorization(
                presented: presentedViewController,
                completion: completion
            )
        case .remoteNotification(let notification, let screen, let error):
            if let error = error {
                present(notification: notification) {
                    [unowned self] in
                    let uiRepresentation = error.uiRepresentation
                    bannerController.presentErrorBanner(
                        title: uiRepresentation.title,
                        message: uiRepresentation.description
                    )
                }
                return
            }

            guard let someScreen = screen else {
                present(notification: notification)
                return
            }
            
            present(notification: notification) {
                [unowned self] in
                self.router.launch(deeplink: someScreen)
            }
        case .deeplink(let screen):
            router.launch(deeplink: screen)
        case .walletConnectSessionRequest(let preferences):
            NotificationCenter.default.post(
                name: ALGPeraConnect.didReceiveSessionRequestNotification,
                object: nil,
                userInfo: [ ALGPeraConnect.sessionRequestPreferencesKey: preferences ]
            )
        case .bottomWarning(let configurator):
            router.launchWithBottomWarning(configurator: configurator)
        }
    }
}

extension AppDelegate {
    func receive(
        deeplinkWithSource src: DeeplinkSource
    ) {
        appLaunchController.receive(deeplinkWithSource: src)
    }

    func authStatus() -> AppAuthStatus {
        return appLaunchController.authStatus()
    }
}

/// <mark>
/// SharedDataControllerObserver
extension AppDelegate {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            let monitor = sharedDataController.blockchainUpdatesMonitor

            let optedInUpdates = monitor.filterOptedInAssetUpdatesForNotification()
            for update in optedInUpdates {
                bannerController.presentSuccessBanner(title: update.notificationMessage)
                monitor.stopMonitoringOptInUpdates(associatedWith: update)
            }

            let optedOutUpdates = monitor.filterOptedOutAssetUpdatesForNotification()
            for update in optedOutUpdates {
                bannerController.presentSuccessBanner(title: update.notificationMessage)
                monitor.stopMonitoringOptOutUpdates(associatedWith: update)
            }

            let sentPureCollectibleAssetUpdates = monitor.filterSentPureCollectibleAssetUpdatesForNotification()
            for update in sentPureCollectibleAssetUpdates {
                monitor.stopMonitoringSendPureCollectibleAssetUpdates(associatedWith: update)
            }
        }
    }
}

extension AppDelegate {
    private func setupAppTarget() {
        ALGAppTarget.setup()
    }
    
    private func setupAppLibs() {
        /// <mark>
        /// Analytics
        analytics.setup()
        
        /// <mark>
        /// SwiftDate
        SwiftDate.defaultRegion = Region(
            calendar: Calendar.autoupdatingCurrent,
            zone: TimeZone.autoupdatingCurrent,
            locale: Locales.autoUpdating
        )
    }

    private func runMigrations() {
        /// <todo> To run all migrations, `Migrator` class should be implemented
        /// All migrations should conform `Migration` protocol

        let passwordMigration = PasswordMigration(session: session)
        passwordMigration.migratePasswordToKeychain()

        let biometricAuthenticationMigration = BiometricAuthenticationMigration(session: session)
        biometricAuthenticationMigration.migratePasswordToKeychain()
    }
}

extension AppDelegate {
    private func makeWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
    
    private func makeNetworkBanner() {
        networkBannerView.layer.zPosition = 1
        
        window?.addSubview(networkBannerView)
        networkBannerView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
            
            $0.fitToHeight(0)
        }

        observe(notification: NodeSettingsViewController.didUpdateNetwork) {
            [unowned self] _ in
            self.setNeedsNetworkBannerUpdateIfNeeded()
        }
    }
    
    private func setNeedsNetworkBannerUpdateIfNeeded() {
        let statusBarManager = window?.windowScene?.statusBarManager
        let height = statusBarManager?.statusBarFrame.height ?? 0
        
        networkBannerView.snp.updateConstraints {
            $0.fitToHeight(height)
        }
        
        switch api.network {
        case .mainnet: networkBannerView.backgroundColor = .clear
        case .testnet: networkBannerView.backgroundColor = Colors.Testnet.background.uiColor
        }

        rootViewController.setNeedsStatusBarAppearanceUpdate()
    }
}

extension AppDelegate {
    private func setNeedsUserInterfaceStyleUpdateIfNeeded() {
        if session.userInterfaceStyle == .system {
            return
        }

        UserInterfaceStyleController.setNeedsUserInterfaceStyleUpdate(session.userInterfaceStyle)
    }
}

extension AppDelegate {
    private func showBlurOnWindow() {
        containerBlurView.effect = nil
    
        UIView.animate(withDuration: 3.0) {
            let view =  VisualEffectViewWithCustomIntensity(
                effect: UIBlurEffect(style: .light),
                intensity: 0.25
            )
            self.containerBlurView = view
        }

        containerBlurView.frame = UIScreen.main.bounds
        window?.addSubview(containerBlurView)
    }
    
    private func removeBlurOnWindow() {
        containerBlurView.removeFromSuperview()
    }
}

extension AppDelegate {
    private func authorizeNotifications(for deviceToken: Data) {
        let pushToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        pushNotificationController.authorizeDevice(with: pushToken)
    }

    func present(
        notification: AlgorandNotification,
        action handler: EmptyHandler? = nil
    ) {
        guard let alert = notification.alert else { return }

        bannerController.presentInAppNotification(
            alert,
            handler
        )
    }
}

extension AppDelegate {
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate {
    private func createPersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "algorand")
        container.loadPersistentStores { storeDescription, error in
            if var url = storeDescription.url {
                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true

                do {
                    try url.setResourceValues(resourceValues)
                } catch {
                }
            }

            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        return container
    }

    private func createAppConfiguration() -> AppConfiguration {
        let walletConnector = walletConnectCoordinator.walletConnectProtocolResolver.walletConnectV1Protocol
        return AppConfiguration(
            api: api,
            session: session,
            sharedDataController: sharedDataController,
            walletConnector: walletConnector,
            loadingController: loadingController,
            bannerController: bannerController,
            toastPresentationController: toastPresentationController,
            lastSeenNotificationController: lastSeenNotificationController,
            analytics: analytics,
            launchController: appLaunchController,
            peraConnect: peraConnect
        )
    }
    
    private func createAppLaunchController() -> AppLaunchController {
        return ALGAppLaunchController(
            session: session,
            api: api,
            sharedDataController: sharedDataController,
            authChecker: ALGAppAuthChecker(session: session),
            peraConnect: peraConnect,
            uiHandler: self
        )
    }

    private func createSession() -> Session {
        return Session()
    }

    private func createAPI() -> ALGAPI {
        return ALGAPI(session: session)
    }

    private func createSharedDataController() -> SharedDataController {
        let currency = CurrencyAPIProvider(session: session, api: api)
        let sharedDataController = SharedAPIDataController(
            target: ALGAppTarget.current,
            currency: currency,
            session: session,
            api: api
        )
        sharedDataController.add(self)
        return sharedDataController
    }

    private func createWalletConnectCoordinator() -> WalletConnectCoordinator {
        let resolver = ALGWalletConnectProtocolResolver(analytics: analytics)
        return ALGWalletConnectCoordinator(walletConnectProtocolResolver: resolver)
    }

    private func createLoadingController() -> LoadingController {
        return BlockingLoadingController(presentingView: window!)
    }

    private func createToastPresentationController() -> ToastPresentationController {
        return ToastPresentationController(presentingView: window!)
    }

    private func createBannerController() -> BannerController {
        return BannerController(presentingView: window!)
    }

    private func createAnalytics() -> ALGAnalytics {
        return ALGAnalyticsCoordinator(providers: [ FirebaseAnalyticsProvider() ])
    }

    private func createPeraConnect() -> PeraConnect {
        return ALGPeraConnect(walletConnectCoordinator: walletConnectCoordinator)
    }

    private func createRouter() -> Router {
        return Router(
            rootViewController: rootViewController,
            appConfiguration: appConfiguration
        )
    }

    private func createRootViewController() -> RootViewController {
        return RootViewController(
            target: ALGAppTarget.current,
            appConfiguration: appConfiguration,
            launchController: appLaunchController
        )
    }

    private func createPushNotificationController() -> PushNotificationController {
        return PushNotificationController(
            target: ALGAppTarget.current,
            session: session,
            api: api
        )
    }

    private func createLastSeenNotificationController() -> LastSeenNotificationController {
        return LastSeenNotificationController(api: api)
    }
}
