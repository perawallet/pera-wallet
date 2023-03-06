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
//   ALGAppLaunchController.swift

import Foundation
import MacaroonApplication
import MacaroonUtils
import UIKit

final class ALGAppLaunchController:
    AppLaunchController,
    SharedDataControllerObserver {
    unowned let uiHandler: AppLaunchUIHandler
    
    private var isFirstLaunch = true
    /// <note>
    /// It can be used to detect any interruption when the app is foreground during the first launch.
    /// The first launch is finished when the app enters background for the first time.
    private var isFirstLaunchInterrupted = false
    
    @Atomic(identifier: "appLaunchController.deeplinkSource")
    private var pendingDeeplinkSource: DeeplinkSource? = nil
    
    private let session: Session
    private let api: ALGAPI
    private let sharedDataController: SharedDataController
    private let authChecker: AppAuthChecker
    private let deeplinkParser: DeepLinkParser
    private let walletConnector: WalletConnector
    
    init(
        session: Session,
        api: ALGAPI,
        sharedDataController: SharedDataController,
        authChecker: AppAuthChecker,
        walletConnector: WalletConnector,
        uiHandler: AppLaunchUIHandler
    ) {
        self.session = session
        self.api = api
        self.sharedDataController = sharedDataController
        self.deeplinkParser = DeepLinkParser(sharedDataController: sharedDataController)
        self.authChecker = authChecker
        self.walletConnector = walletConnector
        self.uiHandler = uiHandler
        
        sharedDataController.add(self)
    }
    
    deinit {
        sharedDataController.remove(self)
    }
    
    func prepareForLaunch() {
        /// <todo>
        /// Authenticated user is decoded everytime its getter is called.
        let authenticatedUser = session.authenticatedUser
        setupPreferredNetwork(authenticatedUser)
    }
    
    func launch(
        deeplinkWithSource src: DeeplinkSource?
    ) {
        authChecker.launch()
        
        if authChecker.status == .requiresAuthentication {
            /// <note>
            /// App is deleted, but the keychain has the private keys.
            /// This should be the first operation since it cleans out the application data.
            session.reset(includingContacts: false)

            launchUIOnce(.onboarding)

            return
        }

        if let deeplinkSource = src {
            suspend(deeplinkWithSource: deeplinkSource)
        }
        
        if authChecker.status == .requiresAuthorization {
            launchUIOnce(.authorization)
            return
        }
        
        launchMain()
    }
    
    func launchOnboarding() {
        cancelPendingDeeplink()
        uiHandler.launchUI(.onboarding)
    }
    
    func launchMain(
        completion: (() -> Void)? = nil
    ) {
        authChecker.authorize()
        uiHandler.launchUI(.main(completion: completion))
        sharedDataController.startPolling()
    }
    
    func launchBuyAlgo(shouldStartPolling: Bool = false, draft: BuyAlgoDraft) {
        authChecker.authorize()
        uiHandler.launchUI(.main(completion: {
            self.receive(deeplinkWithSource: .buyAlgo(draft))
        }))
        
        if shouldStartPolling {
            sharedDataController.startPolling()
        }
    }
    
    func launchMainAfterAuthorization(
        presented viewController: UIViewController
    ) {
        authChecker.authorize()
        
        let completion: () -> Void = {
            [weak self] in
            guard let self = self else { return }
            
            /// <note>
            /// If the main is launched for the first time, let's wait for the accounts before
            /// doing anything with the pending deeplink.
            if self.isFirstLaunch {
                return
            }

            self.resumePendingDeeplink()
        }
        uiHandler.launchUI(
            .mainAfterAuthorization(presented: viewController, completion: completion)
        )
        
        sharedDataController.startPolling()
    }
    
    /// <warning>
    /// System alerts, like permissions, causes the application to become inactive. Therefore, when
    /// they are dismissed, the application becomes active and this method will be called. Think
    /// twice when the `inactiveSessionExpirationDuration` is reduced.
    func becomeActive() {
        if isFirstLaunch {
            if isFirstLaunchInterrupted {
                isFirstLaunchInterrupted = false
            } else {
                becomeActiveOnce()
            }

            return
        }
        
        authChecker.becomeActive()
        
        switch authChecker.status {
        case .requiresAuthentication:
            cancelPendingDeeplink()
        case .requiresAuthorization:
            uiHandler.launchUI(.authorization)
        case .ready:
            resumePendingDeeplink()
            sharedDataController.startPolling()
        }
    }
    
    func resignActive() {
        if isFirstLaunch {
            isFirstLaunchInterrupted = true
            return
        }

        sharedDataController.stopPolling()
        authChecker.resignActive()
    }
    
    func enterBackground() {
        if !isFirstLaunch {
            return
        }

        sharedDataController.stopPolling()
        authChecker.resignActive()
        
        isFirstLaunch = false
        isFirstLaunchInterrupted = false
    }

    func terminate() {}
    
    func receive(
        deeplinkWithSource src: DeeplinkSource
    ) {
        if UIApplication.shared.isActive {
            switch authChecker.status {
            case .ready: resumeOrSuspend(deeplinkWithSource: src)
            default: suspend(deeplinkWithSource: src)
            }
        } else {
            suspend(deeplinkWithSource: src)
        }
    }

    func authStatus() -> AppAuthStatus {
        return authChecker.status
    }
}

extension ALGAppLaunchController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didFinishRunning:
            walletConnector.configureTransactionsIfNeeded()
            resumePendingDeeplink()
        default: break
        }
    }
}

extension ALGAppLaunchController {
    private func launchUIOnce(
        _ state: AppLaunchUIState
    ) {
        /// <note>
        /// Delay for the root to finish its transition to window.
        asyncMain(
            self,
            afterDuration: 0.5
        ) { strongSelf in
            strongSelf.uiHandler.launchUI(state)
        }
    }

    private func becomeActiveOnce() {
        var appLaunchStore = ALGAppLaunchStore()
        appLaunchStore.appOpenCount += 1
    }
}

extension ALGAppLaunchController {
    private func setupPreferredNetwork(
        _ authenticatedUser: User?
    ) {
        if let preferredNetwork = authenticatedUser?.preferredAlgorandNetwork() {
            setup(network: preferredNetwork)
        } else {
            setupTargetNetwork()
        }
    }
    
    private func setupTargetNetwork() {
        let network: ALGAPI.Network = Environment.current.isTestNet ? .testnet : .mainnet
        setup(network: network)
    }
    
    private func setup(
        network: ALGAPI.Network
    ) {
        api.setupNetworkBase(network)
    }
}

extension ALGAppLaunchController {
    private typealias DeeplinkResult = Result<AppLaunchUIState, DeepLinkParser.Error>?
    
    private func resumeOrSuspend(
        deeplinkWithSource src: DeeplinkSource
    ) {
        let result: DeeplinkResult
        
        switch src {
        case .remoteNotification(let userInfo, let waitForUserConfirmation):
            result = determineUIStateIfPossible(
                forRemoteNotificationWithUserInfo: userInfo,
                waitForUserConfirmation: waitForUserConfirmation
            )
        case let .walletConnectSessionRequest(url, prefersConnectionApproval):
            result = determineUIStateIfPossible(
                forWalletConnectSessionRequest: url,
                prefersConnectionApproval: prefersConnectionApproval
            )
        case .walletConnectRequest(let draft):
            result = determineUIStateIfPossible(forWalletConnectRequest: draft)
        case .buyAlgo(let draft):
            result = determineUIStateIfPossible(forBuyAlgo: draft)
        case .qrText(let qrText):
            result = determineUIStateIfPossible(forQRText: qrText)
        }
        
        switch result {
        case .none:
            break
        case .success(let uiState):
            uiHandler.launchUI(uiState)
            completePendingDeeplink()
        case .failure:
            suspend(deeplinkWithSource: src)
        }
    }
    
    private func determineUIStateIfPossible(
        forRemoteNotificationWithUserInfo userInfo: DeeplinkSource.UserInfo,
        waitForUserConfirmation: Bool
    ) -> DeeplinkResult {
        guard let notification = DeeplinkSource.decode(userInfo) else {
            return nil
        }
        
        let parserResult = deeplinkParser.discover(notification: notification)

        switch parserResult {
        case .none:
            return .success(.remoteNotification(notification: notification))
        case .success(let screen):
            let action = deeplinkParser.resolveNotificationAction(for: notification)

            if action == .assetOptIn {
                return .success(.deeplink(screen))
            }

            return .success(
                waitForUserConfirmation
                ? .remoteNotification(
                    notification: notification,
                    screen: screen
                )
                : .deeplink(screen)
            )
        case .failure(let error):
            if shouldPresentNotificationForFailure(error) {
                let uiState: AppLaunchUIState = .remoteNotification(
                    notification: notification,
                    error: error
                )
                return .success(uiState)
            }

            return .failure(error)
        }
    }

    private func shouldPresentNotificationForFailure(_ error: DeepLinkParser.Error) -> Bool {
        switch error {
        case .tryingToOptInForWatchAccount,
             .tryingToActForAssetWithPendingOptInRequest,
             .tryingToActForAssetWithPendingOptOutRequest,
             .accountNotFound,
             .assetNotFound:
            return true
        default:
            return false
        }
    }

    private func determineUIStateIfPossible(
        forQRText qrText: QRText
    ) -> DeeplinkResult {
        let parserResult = deeplinkParser.discover(qrText: qrText)

        switch parserResult {
        case .none: return nil
        case .success(let screen): return .success(.deeplink(screen))
        case .failure(let error): return .failure(error)
        }
    }
    
    private func determineUIStateIfPossible(
        forWalletConnectSessionRequest request: URL,
        prefersConnectionApproval: Bool
    ) -> DeeplinkResult {
        let parserResult = deeplinkParser.discover(walletConnectSessionRequest: request)
        
        switch parserResult {
        case .none:
            return nil
        case .success(let session):
            let preferences = WalletConnectorPreferences(
                session: session,
                prefersConnectionApproval: prefersConnectionApproval
            )
            return .success(.walletConnectSessionRequest(preferences))
        case .failure(let error):
            return .failure(error)
        }
    }

    
    private func determineUIStateIfPossible(
        forWalletConnectRequest draft: WalletConnectRequestDraft
    ) -> DeeplinkResult {
        let parserResult = deeplinkParser.discover(walletConnectRequest: draft)
        
        switch parserResult {
        case .none: return nil
        case .success(let screen): return .success(.deeplink(screen))
        case .failure(let error): return .failure(error)
        }
    }
    
    private func determineUIStateIfPossible(forBuyAlgo draft: BuyAlgoDraft) -> DeeplinkResult {
        let parserResult = deeplinkParser.discoverBuyAlgo(draft: draft)
        
        switch parserResult {
        case .none: return nil
        case .success(let screen): return .success(.deeplink(screen))
        case .failure(let error): return .failure(error)
        }
    }
    
    private func suspend(
        deeplinkWithSource src: DeeplinkSource
    ) {
        $pendingDeeplinkSource.mutate { $0 = src }
    }
    
    private func resumePendingDeeplink() {
        if let pendingDeeplinkSource = pendingDeeplinkSource {
            resumeOrSuspend(deeplinkWithSource: pendingDeeplinkSource)
        }
    }
    
    private func completePendingDeeplink() {
        $pendingDeeplinkSource.mutate { $0 = nil }
    }
    
    private func cancelPendingDeeplink() {
        $pendingDeeplinkSource.mutate { $0 = nil }
    }
}

struct ALGAppLaunchStore: Storable {
    typealias Object = Any

    var appOpenCount: Int = 0 {
        didSet { saveAppOpenCount() }
    }

    var hasLaunchedOnce: Bool {
        return appOpenCount > 1
    }

    private let appOpenCountKey = "com.algorand.algorand.copy.address.count.key"
    private let isOnboardingKey = "com.algorand.store.app.isOnboarding"

    init() {
        refresh()
    }
}

extension ALGAppLaunchStore {
    mutating func refresh() {
        refreshAppOpenCount()
        refreshIsOnboarding()
    }

    mutating func refreshAppOpenCount() {
        appOpenCount = userDefaults.integer(forKey: appOpenCountKey)
    }

    mutating func refreshIsOnboarding() {
        userDefaults.removeObject(forKey: isOnboardingKey)
    }
}

extension ALGAppLaunchStore {
    func save() {
        saveAppOpenCount()
    }

    func saveAppOpenCount() {
        userDefaults.set(
            appOpenCount,
            forKey: appOpenCountKey
        )
    }
}
