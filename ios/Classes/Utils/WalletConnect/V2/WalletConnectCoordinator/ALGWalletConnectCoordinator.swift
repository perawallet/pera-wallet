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

//   ALGWalletConnectCoordinator.swift

import Foundation

final class ALGWalletConnectCoordinator: WalletConnectCoordinator {
    var eventHandler: EventHandler?
    let walletConnectProtocolResolver: WalletConnectProtocolResolver
    
    var v2ProtocolEventHandler: ((WalletConnectV2Event) -> Void)?
    
    var walletConnectV1Protocol: WalletConnectV1Protocol {
        return walletConnectProtocolResolver.walletConnectV1Protocol
    }
    
    var walletConnectV2Protocol: WalletConnectV2Protocol {
        return walletConnectProtocolResolver.walletConnectV2Protocol
    }
    
    init(
        walletConnectProtocolResolver: WalletConnectProtocolResolver
    ) {
        self.walletConnectProtocolResolver = walletConnectProtocolResolver
        
        setWalletConnectV1ProtocolEvents()
        setWalletConnectV2ProtocolEvents()
    }
}

extension ALGWalletConnectCoordinator {
    private func setWalletConnectV1ProtocolEvents() {
        walletConnectV1Protocol.eventHandler = {
            [weak self] event in
            guard let self else { return }
            
            switch event {
            case .shouldStart(let session, let preferences, let completion):
                sendEvent(
                    .shouldStartV1(
                        session: session,
                        preferences: preferences,
                        completion: completion
                    )
                )
            case .didConnect(let session, let preferences):
                sendEvent(
                    .didConnectToV1(
                        session: session,
                        preferences: preferences
                    )
                )
            case .didDisconnect(let session):
                sendEvent(.didDisconnectFromV1(session))
            case .didFail(let error):
                switch error {
                case .failedToDisconnect(let session),
                     .failedToDisconnectInactiveSession(let session):
                    sendEvent(
                        .didDisconnectFromV1Fail(
                            session: session, 
                            error: error
                        )
                    )
                case .failedToCreateSession(_, let preferences),
                     .failedToConnect(_, let preferences):
                    sendEvent(
                        .didFailToConnectV1(
                            error: error,
                            preferences: preferences
                        )
                    )
                }
            case .didExceedMaximumSession:
                sendEvent(.didExceedMaximumSessionFromV1)
            }
        }
    }
    
    private func setWalletConnectV2ProtocolEvents() {
        walletConnectV2Protocol.eventHandler = {
            [weak self] event in
            guard let self else { return }
            
            switch event {
            case .sessions(let sessions):
                sendEvent(.sessionsV2(sessions))
            case .proposeSession(let proposal, let preferences):
                sendEvent(
                    .proposeSessionV2(
                        proposal: proposal,
                        preferences: preferences
                    )
                )
            case .didCreateSessionFail(let preferences):
                sendEvent(.didCreateV2SessionFail(preferences))
            case .didConnectSessionFail(let preferences):
                sendEvent(.didConnectV2SessionFail(preferences))
            case .didDisconnectSession(let session):
                sendEvent(.didDisconnectFromV2(session))
            case .didDisconnectSessionFail(let session, let error):
                sendEvent(
                    .didDisconnectFromV2Fail(
                        session: session,
                        error: error
                    )
                )
            case .deleteSession(let topic, let reason):
                sendEvent(
                    .deleteSessionV2(
                        topic: topic,
                        reason: reason
                    )
                )
            case .settleSession(let session, let preferences):
                sendEvent(
                    .settleSessionV2(
                        session: session,
                        preferences: preferences
                    )
                )
            case .updateSession(let topic, let namespaces):
                sendEvent(
                    .updateSessionV2(
                        topic: topic,
                        namespaces: namespaces
                    )
                )
            case .extendSession(let topic, let date):
                sendEvent(
                    .extendSessionV2(
                        topic: topic,
                        date: date
                    )
                )
            case .pingSession(let ping):
                sendEvent(.pingV2(ping))
            case .didPingSessionFail(let session, let error):
                sendEvent(.didPingV2SessionFail(session: session, error: error))
            case .transactionRequest(let request):
                sendEvent(.transactionRequestV2(request))
            case .failure(let error):
                sendEvent(.failure(error))
            }
        }
    }
}

extension ALGWalletConnectCoordinator {
    func setup() {
        walletConnectV2Protocol.setup()
    }

    func isValidSession(session: WalletConnectSessionText) -> Bool {
        return
            walletConnectV1Protocol.isValidSession(session) ||
            walletConnectV2Protocol.isValidSession(session)
    }
    
    func configureIfNeeded() {
        walletConnectV1Protocol.configureTransactionsIfNeeded()

        walletConnectV2Protocol.configureTransactionsIfNeeded()
    }
    
    func getSessions() -> [WCSessionDraft] {
        let wcV1Sessions = walletConnectV1Protocol.allWalletConnectSessions.map(WCSessionDraft.init)
        let wcV2Sessions = walletConnectV2Protocol.getSessions().map(WCSessionDraft.init)
        return wcV1Sessions + wcV2Sessions
    }
}

extension ALGWalletConnectCoordinator {
    func connectToSession(with preferences: WalletConnectSessionCreationPreferences) {
        guard let currentProtocol = currentProtocol(from: preferences.session) else { return }
        
        if let walletConnectV1Protocol = currentProtocol as? WalletConnectV1Protocol {
            walletConnectV1Protocol.connect(with: preferences)
            return
        }
        
        if let walletConnectV2Protocol = currentProtocol as? WalletConnectV2Protocol {
            walletConnectV2Protocol.connect(with: preferences)
            return
        }
    }
    
    func reconnectToSession(_ params: WalletConnectSessionReconnectionParams) {
        guard let session = params.session else { return }
        
        try? walletConnectV1Protocol.reconnect(to: session)
    }

    func disconnectFromSession(_ params: any WalletConnectSessionDisconnectionParams) {
        let session = params.session

        if let wcV1Session = session as? WCSession {
            walletConnectV1Protocol.disconnectFromSession(wcV1Session)
            return
        }

        if let wcV2Session = session as? WalletConnectV2Session {
            walletConnectV2Protocol.disconnectFromSession(wcV2Session)
            return
        }
    }

    func disconnectFromAllSessions() {
        walletConnectV1Protocol.disconnectFromAllSessions()
        walletConnectV1Protocol.resetAllSessions()

        walletConnectV2Protocol.disconnectFromAllSessions()
        walletConnectV2Protocol.resetAllSessions()
    }

    func updateSessionsWithRemovingAccount(_ account: Account) {
        walletConnectV1Protocol.updateSessionsWithRemovingAccount(account)

        walletConnectV2Protocol.updateSessionsWithRemovingAccount(account)
    }
    
    func updateSessionConnection(_ params: WalletConnectUpdateSessionConnectionParams) {
        let currentProtocol = currentProtocol(from: params)
        
        if let walletConnectV1Protocol = currentProtocol as? WalletConnectV1Protocol,
           let session = params.v1Session,
           let walletInfo = params.newWalletInfo {
            try? walletConnectV1Protocol.update(
                session: session,
                with: walletInfo
            )
            return
        }

        if let walletConnectV2Protocol = currentProtocol as? WalletConnectV2Protocol,
              let session = params.v2Session,
              let namespaces = params.namespaces {
            walletConnectV2Protocol.updateSession(
                session,
                namespaces: namespaces
            )
            return
        }
    }
    
    func extendSessionConnection(_ params: WalletConnectExtendSessionConnectionParams) {
        guard let session = params.session else { return }
        
        walletConnectV2Protocol.extendSession(session)
    }
}

extension ALGWalletConnectCoordinator {
    func approveSessionConnection(_ params: WalletConnectApproveSessionConnectionParams) {
        guard let proposalID = params.proposalId,
              let namespaces = params.namespaces else {
            return
        }
        
        walletConnectV2Protocol.approveSession(
            proposalID,
            namespaces: namespaces
        )
    }
    
    func rejectSessionConnection(_ params: WalletConnectRejectSessionConnectionParams) {
        guard let proposalID = params.proposalId,
              let reason = params.reason else {
            return
        }
        
        walletConnectV2Protocol.rejectSession(
            proposalID,
            reason: reason
        )
    }
}

extension ALGWalletConnectCoordinator {
    func approveTransactionRequest(_ params: WalletConnectApproveTransactionRequestParams) {
        let currentProtocol = currentProtocol(from: params)
        
        if let walletConnectV1Protocol = currentProtocol as? WalletConnectV1Protocol,
           let v1Request = params.v1Request,
           let signature = params.signature {
            walletConnectV1Protocol.signTransactionRequest(
                v1Request,
                with: signature
            )
            return
        }

        if let walletConnectV2Protocol = currentProtocol as? WalletConnectV2Protocol,
              let v2Request = params.v2Request,
              let response = params.response {
            walletConnectV2Protocol.approveTransactionRequest(
                v2Request,
                response: response
            )
            return
        }
    }
    
    func rejectTransactionRequest(_ params: WalletConnectRejectTransactionRequestParams) {
        let currentProtocol = currentProtocol(from: params)
        
        if let walletConnectV1Protocol = currentProtocol as? WalletConnectV1Protocol,
           let v1Request = params.v1Request,
           let error = params.error {
            walletConnectV1Protocol.rejectTransactionRequest(
                v1Request,
                with: error
            )
            return
        }

        if let walletConnectV2Protocol = currentProtocol as? WalletConnectV2Protocol,
           let request = params.v2Request,
           let error = params.error {
            walletConnectV2Protocol.rejectTransactionRequest(
                request,
                with: error
            )
            return
        }
    }
}

extension ALGWalletConnectCoordinator {
    func currentProtocol(from sessionText: WalletConnectSessionText) -> WalletConnectProtocol? {
        return walletConnectProtocolResolver.getWalletConnectProtocol(from: sessionText)
    }
    
    func currentProtocol(from params: WalletConnectParams) -> WalletConnectProtocol {
        return walletConnectProtocolResolver.getWalletConnectProtocol(from: params.currentProtocolID)
    }
    
    func currentProtocolID() -> WalletConnectProtocolID? {
        return walletConnectProtocolResolver.currentWalletConnectProtocolID
    }
    
    func currentProtocol(from protocolID: WalletConnectProtocolID) -> WalletConnectProtocol? {
        return walletConnectProtocolResolver.getWalletConnectProtocol(from: protocolID)
    }
    
    private func sendEvent(_ event: WalletConnectCoordinatorEvent) {
        eventHandler?(event)
    }
}
