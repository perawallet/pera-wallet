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
import SwiftDate
import UIKit

final class ALGAppLaunchController:
    AppLaunchController,
    SharedDataControllerObserver {
    var isFirstLaunch: Bool {
        return lastActiveDate == nil
    }
    
    unowned let uiHandler: AppLaunchUIHandler

    private var lastActiveDate: Date?
    
    @Atomic(identifier: "appLaunchController.deeplinkSource")
    private var pendingDeeplinkSource: DeeplinkSource? = nil
    
    private let session: Session
    private let api: ALGAPI
    private let sharedDataController: SharedDataController
    private let deeplinkParser: DeepLinkParser
    
    init(
        session: Session,
        api: ALGAPI,
        sharedDataController: SharedDataController,
        uiHandler: AppLaunchUIHandler
    ) {
        self.session = session
        self.api = api
        self.sharedDataController = sharedDataController
        self.deeplinkParser = DeepLinkParser(sharedDataController: sharedDataController)
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
        setupAccountsPreordering(authenticatedUser)
    }
    
    func launch(
        deeplinkWithSource src: DeeplinkSource?
    ) {
        var appLaunchStore = ALGAppLaunchStore()
        
        if !session.hasAuthentication() {
            /// <note>
            /// App is deleted, but the keychain has the private keys.
            /// This should be the first operation since it cleans out the application data.
            session.reset(includingContacts: false)

            appLaunchStore.isOnboarding = true

            firstLaunchUI(.onboarding)

            return
        }
        
        appLaunchStore.isOnboarding = false
        
        if let deeplinkSource = src {
            suspend(deeplinkWithSource: deeplinkSource)
        }
        
        if !session.hasPassword() {
            launchMain()
            return
        }
        
        firstLaunchUI(.authorization)
    }
    
    func launchOnboarding() {
        cancelPendingDeeplink()
        uiHandler.launchUI(.onboarding)
    }
    
    func launchMain() {
        uiHandler.launchUI(.main)
        sharedDataController.startPolling()
    }
    
    func launchMainAfterAuthorization(
        presented viewController: UIViewController
    ) {
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
        defer {
            lastActiveDate = nil
        }
        
        if isFirstLaunch {
            return
        }
        
        if !session.hasAuthentication() {
            cancelPendingDeeplink()
            return
        }

        if !session.hasPassword() {
            resumePendingDeeplink()
            sharedDataController.startPolling()

            return
        }
        
        if !hasSessionExpired() {
            resumePendingDeeplink()
            sharedDataController.startPolling()

            return
        }
        
        uiHandler.launchUI(.authorization)
    }
    
    func resignActive() {
        sharedDataController.stopPolling()
        lastActiveDate = Date()
    }
    
    func receive(
        deeplinkWithSource src: DeeplinkSource
    ) {
        if UIApplication.shared.isActive {
            resumeOrSuspend(deeplinkWithSource: src)
        } else {
            suspend(deeplinkWithSource: src)
        }
    }
}

extension ALGAppLaunchController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didFinishRunning: resumePendingDeeplink()
        default: break
        }
    }
}

extension ALGAppLaunchController {
    private func firstLaunchUI(
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
    /// <todo>
    /// Another way? It will be called everytime the application is launched.
    private func setupAccountsPreordering(
        _ authenticatedUser: User?
    ) {        
        authenticatedUser?.accounts
            .enumerated()
            .forEach { index, account in
                if !account.isOrderred {
                    let initialOffset = account.type == .watch ? 100000 : 0
                    account.preferredOrder = initialOffset + index
                }
            }
        authenticatedUser?.syncronize()
        session.authenticatedUser = authenticatedUser
    }
}

extension ALGAppLaunchController {
    private func hasSessionExpired() -> Bool {
        guard let lastActiveDate = lastActiveDate else {
            return false
        }
        
        let expireDate = lastActiveDate + inactiveSessionExpirationDuration
        return Date.now().isAfterDate(
            expireDate,
            granularity: .second
        )
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
        case .url(let url):
            result = determineUIStateIfPossible(forURL: url)
        case .walletConnectSessionRequest(let url):
            result = determineUIStateIfPossible(forWalletConnectSessionRequest: url)
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
            return .success(.remoteNotification(notification))
        case .success(let screen):
            if notification.detail?.type == .assetSupportRequest {
                return .success(.deeplink(screen))
            }

            return .success(
                waitForUserConfirmation
                    ? .remoteNotification(notification, screen)
                    : .deeplink(screen)
            )
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func determineUIStateIfPossible(
        forURL url: URL
    ) -> DeeplinkResult {
        let parserResult = deeplinkParser.discover(url: url)
        
        switch parserResult {
        case .none: return nil
        case .success(let screen): return .success(.deeplink(screen))
        case .failure(let error): return .failure(error)
        }
    }
    
    private func determineUIStateIfPossible(
        forWalletConnectSessionRequest request: URL
    ) -> DeeplinkResult {
        let parserResult = deeplinkParser.discover(walletConnectSessionRequest: request)
        
        switch parserResult {
        case .none: return nil
        case .success(let key): return .success(.walletConnectSessionRequest(key))
        case .failure(let error): return .failure(error)
        }
    }
    
    private func suspend(
        deeplinkWithSource src: DeeplinkSource
    ) {
        $pendingDeeplinkSource.modify { $0 = src }
    }
    
    private func resumePendingDeeplink() {
        if let pendingDeeplinkSource = pendingDeeplinkSource {
            resumeOrSuspend(deeplinkWithSource: pendingDeeplinkSource)
        }
    }
    
    private func completePendingDeeplink() {
        $pendingDeeplinkSource.modify { $0 = nil }
    }
    
    private func cancelPendingDeeplink() {
        $pendingDeeplinkSource.modify { $0 = nil }
    }
}

struct ALGAppLaunchStore: Storable {
    typealias Object = Any
    
    var isOnboarding: Bool {
        get { userDefaults.bool(forKey: isOnboardingKey) }
        set {
            userDefaults.set(newValue, forKey: isOnboardingKey)
            userDefaults.synchronize()
        }
    }

    private let isOnboardingKey = "com.algorand.store.app.isOnboarding"
}
