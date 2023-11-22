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
//   WalletConnectV1Protocol.swift

import Foundation
import MacaroonUtils
import UIKit
import WalletConnectSwift

final class WalletConnectV1Protocol:
    WalletConnectProtocol,
    ServerDelegate {
    var eventHandler: ((WalletConnectV1Event) -> Void)?

    private(set) var sessionValidator:  WalletConnectSessionValidator = WalletConnectV1SessionValidator()

    private lazy var walletConnectServer = WalletConnectServer(delegate: self)
    private lazy var sessionSource = WalletConnectSessionSource()

    private var preferencesForOngoingConnections: [String: WalletConnectSessionCreationPreferences] = [:]
    private var isRegisteredToTheRequests = false

    private let analytics: ALGAnalytics

    init(analytics: ALGAnalytics) {
        self.analytics = analytics
    }
}

extension WalletConnectV1Protocol {
    func isValidSession(_ uri: WalletConnectSessionText) -> Bool {
        return sessionValidator.isValidSession(uri)
    }
    
    func configureTransactionsIfNeeded() {
        if isRegisteredToTheRequests { return }

        isRegisteredToTheRequests = true
        
        clearExpiredSessionsIfNeeded()
        registerToWCRequests()
        reconnectToSavedSessionsIfPossible()
    }
    
    /// <note>
    /// Register the actions that WalletConnect is able to handle.
    private func registerToWCRequests() {
        let wcRequestHandler = WalletConnectRequestHandler(analytics: analytics)
        wcRequestHandler.delegate = UIApplication.shared.rootViewController()
        register(wcRequestHandler)
    }
}

extension WalletConnectV1Protocol {
    /// <note>
    /// `preferences` value represents user preferences for specific wallet connection
    func connect(with preferences: WalletConnectSessionCreationPreferences) {
        let session = preferences.session
        guard let url = WalletConnectURL(session) else {
            eventHandler?(
                .didFail(
                    .failedToCreateSession(
                        qr: session,
                        preferences: preferences
                    )
                )
            )
            return
        }

        let key = url.absoluteString

        if hasOngoingWCConnectionRequest(for: key) {
            return
        }

        do {
            addOngoingWCConnectionRequest(preferences, for: key)

            try connect(to: url)
        } catch {
            clearOngoingWCConnectionRequest(for: key)

            eventHandler?(
                .didFail(
                    .failedToConnect(
                        url: url,
                        preferences: preferences
                    )
                )
            )
        }
    }
    
    func updateSessionsWithRemovingAccount(_ account: Account) {
        allWalletConnectSessions.forEach {
            guard let sessionAccounts = $0.walletMeta?.accounts,
                  sessionAccounts.contains(account.address) else {
                return
            }
                                    
            if sessionAccounts.count == 1 {
                analytics.track(
                    .wcSessionDisconnected(
                        version: .v1,
                        dappName: $0.peerMeta.name,
                        dappURL: $0.peerMeta.url.absoluteString,
                        address: $0.walletMeta?.accounts?.first
                    )
                )

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
                try update(session: $0.sessionBridgeValue, with: newSessionWaletInfo)
                
                let newSession = createNewSession(
                    from: $0,
                    newSessionWalletInfo: newSessionWaletInfo
                )
                
                updateWalletConnectSession(newSession, with: $0.urlMeta)
            } catch {}
        }
    }
    
    private func createNewSessionWalletInfo(
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
    
    private func createNewSession(
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
            try disconnect(from: session.sessionBridgeValue)
           
            removeFromSessions(session)
        } catch WalletConnectSwift.WalletConnect.WalletConnectError.tryingToDisconnectInactiveSession {
            eventHandler?(
                .didFail(
                    .failedToDisconnectInactiveSession(
                        session: session
                    )
                )
            )

            removeFromSessions(session)
        } catch {
            eventHandler?(
                .didFail(
                    .failedToDisconnect(
                        session: session
                    )
                )
            )
        }
    }
    
    private func disconnectFromSessionSilently(_ session: WCSession) {
        try? disconnect(from: session.sessionBridgeValue)
       
        removeFromSessions(session)
    }

    func disconnectFromAllSessions() {
        allWalletConnectSessions.forEach(disconnectFromSession)
    }

    private func reconnectToSavedSessionsIfPossible() {
        for session in allWalletConnectSessions {
            do {
                try reconnect(to: session.sessionBridgeValue)
            } catch {
                removeFromSessions(session)
            }
        }
    }
}

extension WalletConnectV1Protocol {
    private func addToSavedSessions(_ session: WCSession) {
        sessionSource.addWalletConnectSession(session)
    }

    private func removeFromSessions(_ session: WCSession) {
        sessionSource.removeWalletConnectSession(with: session.urlMeta)
    }

    var allWalletConnectSessions: [WCSession] {
        sessionSource.allWalletConnectSessions
    }

    func getWalletConnectSession(for topic: WalletConnectTopic) -> WCSession? {
        return sessionSource.getWalletConnectSession(for: topic)
    }
    
    private func updateWalletConnectSession(_ session: WCSession, with url: WCURLMeta) {
        sessionSource.updateWalletConnectSession(session, with: url)
    }

    func resetAllSessions() {
        sessionSource.resetAllSessions()
    }
}

extension WalletConnectV1Protocol {
    func server(
        _ server: WalletConnectServer,
        shouldStart session: WalletConnectSession,
        completion: @escaping (WalletConnectSession.WalletInfo) -> Void
    ) {
        let key = session.url.absoluteString
        let preferences = preferencesForOngoingConnections[key]
        guard let preferences else { return }
       
        /// <note>
        /// Get user approval or rejection for the session
        eventHandler?(
            .shouldStart(
                session: session,
                preferences: preferences,
                completion: completion
            )
        )
    }

    func server(
        _ server: WalletConnectServer,
        didConnect session: WalletConnectSession
    ) {
        asyncMain(afterDuration: 0) { [weak self] in
            guard let self else { return }

            let connectedSession = session.toWCSession()
          
            let localSession = self.sessionSource.getWalletConnectSession(for: connectedSession.urlMeta.topic)
            if localSession == nil {
                self.addToSavedSessions(connectedSession)
            }
            
            let key = session.url.absoluteString

            let preferences = preferencesForOngoingConnections[key]
            guard let preferences else { return }

            self.eventHandler?(
                .didConnect(
                    session: connectedSession,
                    preferences: preferences
                )
            )

            clearOngoingWCConnectionRequest(for: key)
        }
    }

    func server(
        _ server: WalletConnectServer,
        didDisconnect session: WalletConnectSession
    ) {
        asyncMain(afterDuration: 0) { [weak self] in
            guard let self else { return  }

            let wcSession = session.toWCSession()
           
            self.removeFromSessions(wcSession)

            self.eventHandler?(.didDisconnect(wcSession))
        }
    }

    func server(
        _ server: WalletConnectServer,
        didFailToConnect url: WalletConnectURL
    ) {
        let key = url.absoluteString
        let preferences = preferencesForOngoingConnections[key]
        guard let preferences else { return }

        clearOngoingWCConnectionRequest(for: key)

        eventHandler?(
            .didFail(
                .failedToConnect(
                    url: url,
                    preferences: preferences
                )
            )
        )
    }

    func server(
        _ server: WalletConnectServer,
        didUpdate session: WalletConnectSession
    ) { }
    
    func server(
        _ server: Server,
        didFailWith error: Error?,
        for url: WCURL
    ) {
        analytics.record(
            .wcTransactionRequestSDKError(error: error, url: url)
        )
        analytics.track(
            .wcTransactionRequestSDKError(error: error, url: url)
        )
    }
}

extension WalletConnectV1Protocol {
    /// <note>
    /// The oldest sessions on the device should be disconnected and removed when the maximum session limit is exceeded.
    func clearExpiredSessionsIfNeeded() {
        let sessionLimit = WalletConnectSessionSource.sessionLimit
        
        guard let sessions = sessionSource.sessions.unwrap(where: { $0.count > sessionLimit }) else { return }
        
        let orderedSessions = sessions.values.sorted { $0.date > $1.date }
        let oldSessions = orderedSessions[sessionLimit...]
        
        oldSessions.forEach { session in
            disconnectFromSessionSilently(session)
        }
        
        eventHandler?(.didExceedMaximumSession)
    }
}

extension WalletConnectV1Protocol {
    private func hasOngoingWCConnectionRequest(for key: String) -> Bool {
        return preferencesForOngoingConnections[key] != nil
    }

    private func addOngoingWCConnectionRequest(
        _ preferences: WalletConnectSessionCreationPreferences,
        for key: String
    ) {
        preferencesForOngoingConnections[key] = preferences
    }

    private func clearOngoingWCConnectionRequest(for key: String) {
        preferencesForOngoingConnections[key] = nil
    }
}

extension WalletConnectV1Protocol {
    func isConnected(by url: WCURL) -> Bool {
        return walletConnectServer.isConnected(by: url)
    }

    func register(_ handler: WalletConnectRequestHandler) {
        walletConnectServer.register(handler: handler)
    }

    func connect(to url: WCURL) throws {
        try walletConnectServer.connect(to: url)
    }

    func reconnect(to session: WalletConnectSession) throws {
        try walletConnectServer.reconnect(to: session)
    }

    func disconnect(from session: WalletConnectSession) throws {
        try walletConnectServer.disconnect(from: session)
    }
    
    func update(session: WalletConnectSession, with newWalletInfo: WalletConnectSessionWalletInfo) throws {
        try walletConnectServer.updateSession(session, with: newWalletInfo)
    }
    
    func signTransactionRequest(_ request: WalletConnectRequest, with signature: [Data?]) {
        if let signature = WalletConnectResponse.signature(signature, for: request) {
            walletConnectServer.send(signature)
        }
    }

    func rejectTransactionRequest(_ request: WalletConnectRequest, with error: WCTransactionErrorResponse) {
        if let rejection = WalletConnectResponse.rejection(request, with: error) {
            walletConnectServer.send(rejection)
        }
    }
}

enum WalletConnectV1Event {
    case shouldStart(
        session: WalletConnectSession,
        preferences: WalletConnectSessionCreationPreferences,
        completion: WalletConnectSessionConnectionCompletionHandler
    )
    case didConnect(
        session: WCSession,
        preferences: WalletConnectSessionCreationPreferences
    )
    case didDisconnect(WCSession)
    case didFail(WalletConnectV1Protocol.WCError)
    case didExceedMaximumSession
}

extension WalletConnectV1Protocol {
    enum WCError {
        case failedToConnect(url: WalletConnectURL, preferences: WalletConnectSessionCreationPreferences)
        case failedToCreateSession(qr: String, preferences: WalletConnectSessionCreationPreferences)
        case failedToDisconnectInactiveSession(session: WCSession)
        case failedToDisconnect(session: WCSession)
    }
}

typealias WalletConnectSession = WalletConnectSwift.Session
typealias WalletConnectURL = WCURL
typealias WalletConnectServer = WalletConnectSwift.Server
typealias WalletConnectRequest = WalletConnectSwift.Request
typealias WalletConnectResponse = WalletConnectSwift.Response
typealias WalletConnectSessionWalletInfo = WalletConnectSwift.Session.WalletInfo
typealias WalletConnectSessionConnectionCompletionHandler = (WalletConnectSessionWalletInfo) -> Void
typealias WalletConnectTopic = String
