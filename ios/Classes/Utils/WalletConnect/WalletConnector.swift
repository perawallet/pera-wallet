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
//   WalletConnector.swift

import Foundation
import UIKit
import WalletConnectSwift

class WalletConnector {
    static var didReceiveSessionRequestNotification: Notification.Name {
        return .init(
            rawValue: "com.algorand.algorand.notification.walletConnector.didReceiveSessionRequest"
        )
    }
    
    static var sessionRequestPreferencesKey: String {
        return "walletConnector.preferences"
    }

    private lazy var sessionSource = WalletConnectSessionSource()

    weak var delegate: WalletConnectorDelegate?

    private let api: ALGAPI
    private let pushToken: String?
    private let analytics: ALGAnalytics
    private let walletConnectBridge = WalletConnectBridge()

    private var ongoingConnections: [String: Bool] = [:]
    private var preferences: WalletConnectorPreferences?

    init(
        api: ALGAPI,
        pushToken: String?,
        analytics: ALGAnalytics
    ) {
        self.api = api
        self.pushToken = pushToken
        self.analytics = analytics

        walletConnectBridge.delegate = self
    }
}

extension WalletConnector {
    // Register the actions that WalletConnect is able to handle.
    func register(for handler: WalletConnectRequestHandler) {
        walletConnectBridge.register(handler)
    }

    /// <note>:
    /// `preferences` value repsents user preferences for specific wallet connection
    func connect(with preferences: WalletConnectorPreferences) {
        self.preferences = preferences

        let session = preferences.session

        guard let url = WalletConnectURL(session) else {
            delegate?.walletConnector(self, didFailWith: .failedToCreateSession(qr: session))
            return
        }

        let key = url.absoluteString

        if ongoingConnections[key] != nil {
            return
        }

        do {
            ongoingConnections[key] = true
            try walletConnectBridge.connect(to: url)
        } catch {
            ongoingConnections.removeValue(forKey: key)
            delegate?.walletConnector(self, didFailWith: .failedToConnect(url: url))
        }
    }
    
    func updateSessionsWithRemovingAccount(_ account: Account) {
        allWalletConnectSessions.forEach {
            guard let sessionAccounts = $0.walletMeta?.accounts,
                  sessionAccounts.contains(account.address) else {
                return
            }
                                    
            if sessionAccounts.count == 1 {
                disconnectFromSession($0)
                return
            }
            
                        
            guard let sessionWalletInfo = $0.sessionBridgeValue.walletInfo else {
                return
            }
                        
            let newAccountsForSession = sessionWalletInfo.accounts.filter { oldSessionAccount in
                oldSessionAccount != account.address
            }

            let newSessionWaletInfo = createNewSessionWalletInfo(
                from: sessionWalletInfo,
                newAccounts: newAccountsForSession
            )
            
            do {
                try walletConnectBridge.update(session: $0.sessionBridgeValue, with: newSessionWaletInfo)
                
                let newSession = createNewSession(
                    from: $0,
                    newSessionWalletInfo: newSessionWaletInfo
                )
                
                updateWalletConnectSession(newSession, with: $0.urlMeta)
            } catch {}
        }
    }
    
    func createNewSessionWalletInfo(
        from oldWalletInfo: WalletConnectSessionWalletInfo,
        newAccounts: [String]
    ) -> WalletConnectSessionWalletInfo {
        return WalletConnectSessionWalletInfo(
            approved: oldWalletInfo.approved,
            accounts: newAccounts,
            chainId: oldWalletInfo.chainId,
            peerId: oldWalletInfo.peerId,
            peerMeta: oldWalletInfo.peerMeta
        )
    }
    
    func createNewSession(
        from oldSession: WCSession,
        newSessionWalletInfo: WalletConnectSessionWalletInfo
    ) -> WCSession {
        return WCSession(
            urlMeta: oldSession.urlMeta,
            peerMeta: oldSession.peerMeta,
            walletMeta: WCWalletMeta(
                walletInfo: newSessionWalletInfo,
                dappInfo: oldSession.peerMeta.dappInfo
            ),
            date: oldSession.date
        )
    }

    func disconnectFromSession(_ session: WCSession) {
        do {
            try walletConnectBridge.disconnect(from: session.sessionBridgeValue)
            removeFromSessions(session)
        } catch WalletConnectSwift.WalletConnect.WalletConnectError.tryingToDisconnectInactiveSession {
            delegate?.walletConnector(self, didFailWith: .failedToDisconnectInactiveSession(session: session))
        } catch {
            delegate?.walletConnector(self, didFailWith: .failedToDisconnect(session: session))
        }
    }

    func disconnectFromAllSessions() {
        allWalletConnectSessions.forEach(disconnectFromSession)
    }

    func reconnectToSavedSessionsIfPossible() {
        for session in allWalletConnectSessions {
            do {
                try walletConnectBridge.reconnect(to: session.sessionBridgeValue)
            } catch {
                removeFromSessions(session)
            }
        }
    }

    func signTransactionRequest(_ request: WalletConnectRequest, with signature: [Foundation.Data?]) {
        walletConnectBridge.signTransactionRequest(request, with: signature)
    }

    func rejectTransactionRequest(_ request: WalletConnectRequest, with error: WCTransactionErrorResponse) {
        walletConnectBridge.rejectTransactionRequest(request, with: error)
    }
}

extension WalletConnector {
    private func addToSavedSessions(_ session: WCSession) {
        sessionSource.addWalletConnectSession(session)
    }

    private func removeFromSessions(_ session: WCSession) {
        sessionSource.removeWalletConnectSession(with: session.urlMeta)
    }

    var allWalletConnectSessions: [WCSession] {
        sessionSource.allWalletConnectSessions
    }

    func getWalletConnectSession(with url: WCURLMeta) -> WCSession? {
        return sessionSource.getWalletConnectSession(with: url)
    }
    
    func updateWalletConnectSession(_ session: WCSession, with url: WCURLMeta) {
        sessionSource.updateWalletConnectSession(session, with: url)
    }

    func resetAllSessions() {
        sessionSource.resetAllSessions()
    }

    func saveConnectedWCSession(_ session: WCSession) {
        if let sessionData = try? JSONEncoder().encode([session.urlMeta.topic: session]) {
            WCSessionHistory.create(
                entity: WCSessionHistory.entityName,
                with: [WCSessionHistory.DBKeys.sessionHistory.rawValue: sessionData]
            )
        }
    }
}

extension WalletConnector: WalletConnectBridgeDelegate {
    func walletConnectBridge(
        _ walletConnectBridge: WalletConnectBridge,
        shouldStart session: WalletConnectSession,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    ) {
        // Get user approval or rejection for the session
        delegate?.walletConnector(self, shouldStart: session, with: preferences, then: completion)
    }

    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didFailToConnect url: WalletConnectURL) {
        let key = url.absoluteString
        ongoingConnections.removeValue(forKey: key)
        delegate?.walletConnector(self, didFailWith: .failedToConnect(url: url))
    }

    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didConnectTo session: WalletConnectSession) {
        asyncMain(afterDuration: 0) { [weak self] in
            guard let self = self else {
                return
            }

            let connectedSession = session.toWCSession()
            let localSession = self.sessionSource.getWalletConnectSession(with: connectedSession.urlMeta)
            
            if localSession == nil {
                self.addToSavedSessions(connectedSession)
            }

            /// <todo>
            /// Disabled supporting WC push notificataions for now 06.01.2023
//            self.subscribeForNotificationsIfNeeded(localSession ?? connectedSession)
            
            let key = session.url.absoluteString
            self.ongoingConnections.removeValue(forKey: key)
            self.delegate?.walletConnector(self, didConnectTo: connectedSession)
        }
    }

    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didDisconnectFrom session: WalletConnectSession) {
        asyncMain(afterDuration: 0) { [weak self] in
            guard let self = self else {
                return
            }

            let wcSession = session.toWCSession()
            self.removeFromSessions(wcSession)
            self.delegate?.walletConnector(self, didDisconnectFrom: wcSession)
        }
    }

    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didUpdate session: WalletConnectSession) {
        delegate?.walletConnector(self, didUpdate: session.toWCSession())
    }
}

extension WalletConnector {
    private func subscribeForNotificationsIfNeeded(_ session: WCSession) {
        if session.isSubscribed {
            return
        }

        let user = api.session.authenticatedUser
        let deviceID = user?.getDeviceId(on: api.network)

        let draft = SubscribeToWalletConnectSessionDraft(
            deviceID: deviceID,
            wcSession: session,
            pushToken: pushToken
        )

        api.subscribeToWalletConnectSession(draft) {
            [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success:
                session.isSubscribed = true
                self.addToSavedSessions(session)
            default:
                break
            // The session is already saved before subscription call.
            // The failure means there is no change. So, it is not needed to handle.
            }
        }
    }
}

extension WalletConnector {
    enum Error {
        case failedToConnect(url: WalletConnectURL)
        case failedToCreateSession(qr: String)
        case failedToDisconnectInactiveSession(session: WCSession)
        case failedToDisconnect(session: WCSession)
    }
}

protocol WalletConnectorDelegate: AnyObject {
    func walletConnector(
        _ walletConnector: WalletConnector,
        shouldStart session: WalletConnectSession,
        with preferences: WalletConnectorPreferences?,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    )
    func walletConnector(_ walletConnector: WalletConnector, didConnectTo session: WCSession)
    func walletConnector(_ walletConnector: WalletConnector, didDisconnectFrom session: WCSession)
    func walletConnector(_ walletConnector: WalletConnector, didFailWith error: WalletConnector.Error)
    func walletConnector(_ walletConnector: WalletConnector, didUpdate session: WCSession)
}

extension WalletConnectorDelegate {
    func walletConnector(
        _ walletConnector: WalletConnector,
        shouldStart session: WalletConnectSession,
        with preferences: WalletConnectorPreferences?,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    ) {

    }

    func walletConnector(_ walletConnector: WalletConnector, didConnectTo session: WCSession) {

    }

    func walletConnector(_ walletConnector: WalletConnector, didDisconnectFrom session: WCSession) {

    }

    func walletConnector(_ walletConnector: WalletConnector, didFailWith error: WalletConnector.Error) {

    }

    func walletConnector(_ walletConnector: WalletConnector, didUpdate session: WCSession) {

    }
}

enum WalletConnectMethod: String {
    case transactionSign = "algo_signTxn"
}
