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
//  AppDelegate.swift

import UIKit
import CoreData
import Firebase
import SwiftDate
import UserNotifications
import FirebaseCrashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private lazy var session = Session()
    private lazy var api = AlgorandAPI(session: session, base: "")
    private lazy var appConfiguration = AppConfiguration(api: api, session: session)
    private lazy var pushNotificationController = PushNotificationController(api: api)
    
    private(set) lazy var firebaseAnalytics = FirebaseAnalytics()
    
    private var rootViewController: RootViewController?
    
    private(set) lazy var accountManager: AccountManager = AccountManager(api: api)
    
    private var timer: PollingOperation?
    private var shouldInvalidateAccountFetch = false
    
    private var shouldInvalidateUserSession: Bool = false
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setupFirebase()
        SwiftDate.setupDateRegion()
        setupWindow()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        authorizeNotifications(for: deviceToken)
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        displayInAppPushNotification(from: userInfo)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        updateForegroundActions()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        decideToInvalidateSessionInBackground()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return shouldHandleDeepLinkRouting(from: url)
    }

    lazy var persistentContainer: NSPersistentContainer = {
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
    }()
}

extension AppDelegate {
    private func setupFirebase() {
        firebaseAnalytics.initialize()
    }

    private func setupWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)

        rootViewController = RootViewController(appConfiguration: appConfiguration)

        guard let rootViewController = rootViewController else {
            return
        }

        window.backgroundColor = .clear
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        self.window = window
    }
}

extension AppDelegate {
    private func updateForegroundActions() {
        timer?.invalidate()
        updateUserInterfaceStyleIfNeeded()
        NotificationCenter.default.post(name: .ApplicationWillEnterForeground, object: self, userInfo: nil)
        validateUserSessionIfNeeded()
    }

    private func validateUserSessionIfNeeded() {
        guard appConfiguration.session.isValid,
            !appConfiguration.session.accounts.isEmpty else {
            return
        }

        if shouldInvalidateUserSession {
            shouldInvalidateUserSession = false
            if appConfiguration.session.hasPassword() {
                appConfiguration.session.isValid = false
                openPasswordEntryScreen()
            }
            return
        } else {
            validateAccountManagerFetchPolling()
        }
    }

    private func openPasswordEntryScreen() {
        guard let rootViewController = rootViewController,
              let topViewController = rootViewController.tabBarViewController.topMostController,
              appConfiguration.session.hasPassword() else {
            return
        }

        rootViewController.route(
            to: .choosePassword(mode: .login, flow: nil, route: nil),
            from: topViewController,
            by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
        )
    }

    private func decideToInvalidateSessionInBackground() {
        timer = PollingOperation(interval: Constants.sessionInvalidateTime) { [weak self] in
            self?.shouldInvalidateUserSession = true
        }

        timer?.start()

        invalidateAccountManagerFetchPolling()
    }
}

extension AppDelegate {
    private func authorizeNotifications(for deviceToken: Data) {
        let pushToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        pushNotificationController.authorizeDevice(with: pushToken)
    }

    private func displayInAppPushNotification(from userInfo: [AnyHashable: Any]) {
        guard let algorandNotification = parseAlgorandNotification(from: userInfo),
              let accountId = getNotificationAccountId(from: algorandNotification) else {
            return
        }

        handleNotificationActions(for: accountId, with: algorandNotification.details)
    }

    private func parseAlgorandNotification(from userInfo: [AnyHashable: Any]) -> AlgorandNotification? {
        guard let userInfo = userInfo as? [String: Any],
            let userInfoDictionary = userInfo["aps"] as? [String: Any],
            let remoteNotificationData = try? JSONSerialization.data(withJSONObject: userInfoDictionary, options: .prettyPrinted),
            let algorandNotification = try? JSONDecoder().decode(AlgorandNotification.self, from: remoteNotificationData) else {
                return nil
        }

        return algorandNotification
    }

    private func getNotificationAccountId(from algorandNotification: AlgorandNotification) -> String? {
        guard let accountId = algorandNotification.getAccountId() else {
            if let message = algorandNotification.alert {
                NotificationBanner.showInformation(message)
            }
            return nil
        }

        return accountId
    }

    private func handleNotificationActions(for accountId: String, with notificationDetail: NotificationDetail?) {
        if UIApplication.shared.applicationState == .active,
           let notificationDetail = notificationDetail {

            NotificationCenter.default.post(name: .NotificationDidReceived, object: self, userInfo: nil)

            if let notificationtype = notificationDetail.notificationType {
                if notificationtype == .assetSupportRequest {
                    rootViewController?.openAsset(from: notificationDetail, for: accountId)
                    return
                }
            }

            pushNotificationController.show(with: notificationDetail) {
                self.rootViewController?.openAsset(from: notificationDetail, for: accountId)
            }
        } else {
            if let notificationDetail = notificationDetail {
                rootViewController?.openAsset(from: notificationDetail, for: accountId)
            }
        }
    }

    private func shouldHandleDeepLinkRouting(from url: URL) -> Bool {
        let parser = DeepLinkParser(url: url)

        guard let screen = parser.expectedScreen,
            let rootViewController = rootViewController else {
                return false
        }

        return rootViewController.handleDeepLinkRouting(for: screen)
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
    func validateAccountManagerFetchPolling() {
        shouldInvalidateAccountFetch = false
        fetchAccounts()
    }

    func invalidateAccountManagerFetchPolling() {
        shouldInvalidateAccountFetch = true
    }

    private func fetchAccounts(round: Int64? = nil) {
        guard !shouldInvalidateAccountFetch else {
            return
        }

        if session.authenticatedUser != nil {
            accountManager.waitForNextRoundAndFetchAccounts(round: round) { nextRound in
                self.fetchAccounts(round: nextRound)
            }
        }
    }
}

extension AppDelegate {
    private func updateUserInterfaceStyleIfNeeded() {
        /// <note> Will update the appearance style if it's set to system since it might be changed from device settings.
        /// Since user interface style is overriden, traitCollectionDidChange is not triggered
        /// when the user interface is changed from the device settings while app is open.
        /// Needs a minor delay to receive correct system interface value from traitCollection to override the current one.
        if appConfiguration.session.userInterfaceStyle == .system {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.rootViewController?.changeUserInterfaceStyle(to: .system)
            }
        }
    }
}

extension AppDelegate {
    private enum Constants {
        static let sessionInvalidateTime: Double = 60.0
    }
}
