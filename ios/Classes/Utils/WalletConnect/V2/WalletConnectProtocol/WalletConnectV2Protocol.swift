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

//   WalletConnectV2Protocol.swift

import Combine
import Foundation
import WalletConnectNetworking
import WalletConnectPairing
import Web3Wallet
import UIKit

final class WalletConnectV2Protocol: WalletConnectProtocol {
    var eventHandler: ((WalletConnectV2Event) -> Void)?

    private(set) var sessionValidator: WalletConnectSessionValidator = WalletConnectV2SessionValidator()

    private lazy var sessionSource = WalletConnectV2SessionSource()

    private var signAPI: SignClient {
        return Sign.instance
    }

    private var pairAPI: PairingInteracting {
        return Pair.instance
    }

    private var preferencesForOngoingConnections: [String: WalletConnectSessionCreationPreferences] = [:]

    private var publishers = Set<AnyCancellable>()

    /// <note>
    /// Metadata that is directly copied from WalletConnect v1.
    private let appMetadata = AppMetadata(
        name: ALGAppTarget.current.walletConnectConfig.meta.name,
        description: ALGAppTarget.current.walletConnectConfig.meta.description,
        url: ALGAppTarget.current.walletConnectConfig.meta.url.absoluteString,
        icons: ALGAppTarget.current.walletConnectConfig.meta.icons.map { $0.absoluteString },
        redirect: AppMetadata.Redirect(
            native: "perawallet://",
            universal: nil
        )
    )

    private let analytics: ALGAnalytics
    
    init(analytics: ALGAnalytics) {
        self.analytics = analytics
    }
}

extension WalletConnectV2Protocol {
    func setup() {
        let projectID = Bundle.main.infoDictionary?["WC_V2_PROJECT_ID"] as? String
        guard let projectID else {
            preconditionFailure("WC_V2_PROJECT_ID must be set.")
        }

        Networking.configure(
            projectId: projectID,
            socketFactory: DefaultSocketFactory()
        )
        
        Pair.configure(metadata: appMetadata)

        listenEvents()
    }
}

extension WalletConnectV2Protocol {
    func getSessions() -> [WalletConnectV2Session] {
        return signAPI.getSessions()
    }

    func getConnectionDates() -> [WalletConnectTopic: Date] {
        let sessions = sessionSource.sessions?.values
        let connectionDates = sessions?.reduce(into: [WalletConnectTopic: Date]()) { result, session in
            result[session.topic] = session.connectionDate
        }
        return connectionDates ?? [:]
    }

    func getPairing(for topic: String) -> Pairing? {
        return try? pairAPI.getPairing(for: topic)
    }
}

extension WalletConnectV2Protocol {
    func connect(with preferences: WalletConnectSessionCreationPreferences) {
        guard let uri = WalletConnectURI(string: preferences.session) else {
            eventHandler?(.didCreateSessionFail(preferences))
            return
        }

        let topic = uri.topic

        Task {
            do {
                addOngoingWCConnectionRequest(preferences, for: topic)
               
                try await pairAPI.pair(uri: uri)
            } catch {
                clearOngoingWCConnectionRequest(for: topic)

                analytics.record(
                    .wcV2SessionConnectionFailedLog(
                        uri: uri,
                        error: error
                    )
                )

                self.eventHandler?(.didConnectSessionFail(preferences))

                print("[WC2] - Pairing connect error: \(error)")
            }
        }
    }

    func updateSessionsWithRemovingAccount(_ account: Account) {
        let sessions = getSessions()
        sessions.forEach { session in
            let sessionAccounts = session.accounts
            guard sessionAccounts.contains(where: { $0.address == account.address }) else {
                return
            }

            let hasOnlySingleAccount = sessionAccounts.allSatisfy { sessionAccount in
                return sessionAccount.address == account.address
            }
            if hasOnlySingleAccount {
                analytics.track(
                    .wcSessionDisconnected(
                        version: .v2,
                        dappName: session.peer.name,
                        dappURL: session.peer.url,
                        address: session.accounts.map(\.address).joined(separator: ",")
                    )
                )

                disconnectFromSession(session)
                return
            }

            var newSessionNamespaces = SessionNamespaces()
            session.requiredNamespaces.forEach {
                let caip2Namespace = $0.key
                let proposalNamespace = $0.value

                guard let chains = proposalNamespace.chains else { return }

                let accounts = Set(
                    chains.compactMap { chain in
                        let accounts: [WalletConnectV2Account] = session.accounts.compactMap { sessionAccount in
                            if account.address == sessionAccount.address {
                                return nil
                            }

                            return WalletConnectV2Account(
                                "\(chain.absoluteString):\(sessionAccount.address)"
                            )
                        }
                        return accounts
                    }
                ).flatMap { $0 }

                let sessionNamespace = WalletConnectV2SessionNamespace(
                    accounts: Set(accounts),
                    methods: proposalNamespace.methods,
                    events: proposalNamespace.events
                )

                newSessionNamespaces[caip2Namespace] = sessionNamespace
            }

            updateSession(
                session,
                namespaces: newSessionNamespaces
            )
        }
    }
}

extension WalletConnectV2Protocol {
    func isValidSession(_ uri: WalletConnectSessionText) -> Bool {
        return sessionValidator.isValidSession(uri)
    }
    
    func configureTransactionsIfNeeded() {
        let rootViewController = UIApplication.shared.rootViewController()
        rootViewController?.startObservingPeraConnectEvents()
    }
}

extension WalletConnectV2Protocol {
    func approveSession(
        _ proposalId: String,
        namespaces: SessionNamespaces
    ) {
        print("[WC2] - Approve Session: \(proposalId)")
        
        Task {
            do {
                try await signAPI.approve(
                    proposalId: proposalId,
                    namespaces: namespaces
                )
            } catch {
                self.eventHandler?(.failure(error))

                analytics.record(
                    .wcV2SessionConnectionApprovalFailedLog(
                        proposalID: proposalId,
                        error: error
                    )
                )

                rejectSession(
                    proposalId,
                    reason: .userRejected
                )

                print("[WC2] - Approve Session error: \(error)")
            }
        }
    }

    func rejectSession(
        _ proposalId: String,
        reason: WalletConnectV2SessionRejectionReason
    ) {
        print("[WC2] - Reject Session: \(proposalId)")
        
        Task {
            do {
                try await signAPI.reject(
                    proposalId: proposalId,
                    reason: reason
                )
            } catch {
                self.eventHandler?(.failure(error))

                analytics.record(
                    .wcV2SessionConnectionRejectionFailedLog(
                        proposalID: proposalId,
                        error: error
                    )
                )

                print("[WC2] - Reject Session error: \(error)")
            }
        }
    }
    
    func extendSession(_ session: WalletConnectV2Session) {
        print("[WC2] - Extend Session: \(session.topic)")
        
        Task {
            do {
                try await signAPI.extend(topic: session.topic)
            } catch {
                self.eventHandler?(.failure(error))

                print("[WC2] - Extend Session error: \(error)")
            }
        }
    }
    
    func updateSession(
        _ session: WalletConnectV2Session,
        namespaces: SessionNamespaces
    ) {
        print("[WC2] - Update Session: \(session.topic)")
        
        Task {
            do {
                try await signAPI.update(
                    topic: session.topic,
                    namespaces: namespaces
                )
            } catch {
                self.eventHandler?(.failure(error))
               
                analytics.record(
                    .wcV2SessionUpdateFailedLog(
                        session: session,
                        error: error
                    )
                )

                print("[WC2] - Update Session error: \(error)")
            }
        }
    }

    func disconnectFromSession(_ session: WalletConnectV2Session) {
        print("[WC2] - Disconnect Session: \(session.topic)")

        Task {
            do {
                try await signAPI.disconnect(topic: session.topic)
               
                self.eventHandler?(.didDisconnectSession(session))

                DispatchQueue.main.async {
                    [weak self] in
                    self?.sessionSource.removeWalletConnectSession(for: session.topic)
                }
            } catch {
                eventHandler?(
                    .didDisconnectSessionFail(
                        session: session,
                        error: error
                    )
                )

                analytics.record(
                    .wcV2SessionDisconnectionFailedLog(
                        session: session,
                        error: error
                    )
                )

                print("[WC2] - Disconnect Session error: \(error)")
            }
        }
    }

    func pingSession(_ session: WalletConnectV2Session) {
        print("[WC2] - Ping Session: \(session.topic)")

        Task {
            do {
                try await signAPI.ping(topic: session.topic)
            } catch {
                self.eventHandler?(
                    .didPingSessionFail(
                        session: session,
                        error: error
                    )
                )

                print("[WC2] - Ping Session error: \(error)")
            }
        }
    }

    func disconnectFromAllSessions() {
        let sessions = getSessions()
        sessions.forEach(disconnectFromSession)
    }

    func resetAllSessions() {
        sessionSource.resetAllSessions()

        Task {
            try? await signAPI.cleanup()
        }
    }
}

extension WalletConnectV2Protocol {
    func approveTransactionRequest(
        _ request: WalletConnectV2Request,
        response: WalletConnectV2CodableResult
    ) {
        print("[WC2] - Approve Request")
        
        Task {
            do {
                try await signAPI.respond(
                    topic: request.topic,
                    requestId: request.id,
                    response: .response(response)
                )
            } catch {
                self.eventHandler?(.failure(error))

                rejectTransactionRequest(
                    request,
                    with: .generic(error)
                )

                analytics.record(
                    .wcV2TransactionRequestApprovalFailedLog(
                        request: request,
                        error: error
                    )
                )

                print("[WC2] - Approve Request Error: \(error.localizedDescription)")
            }
        }
    }

    func rejectTransactionRequest(
        _ request: WalletConnectV2Request,
        with error: WCTransactionErrorResponse
    ) {
        print("[WC2] - Reject Request")

        Task {
            do {
                try await signAPI.respond(
                    topic: request.topic,
                    requestId: request.id,
                    response: .error(
                        .init(
                            code: error.rawValue,
                            message: error.message
                        )
                    )
                )
            } catch {
                analytics.record(
                    .wcV2TransactionRequestRejectionFailedLog(
                        request: request,
                        error: error
                    )
                )

                eventHandler?(.failure(error))

                print("[WC2] - Reject Request Error: \(error.localizedDescription)")
            }
        }
    }
}

extension WalletConnectV2Protocol {
    private func listenEvents() {
        publishers = []

        handleSessionEvents()
        handleSessionProposalEvents()
        handleSessionDeletionEvents()
        handleSessionSettleEvents()
        handleSessionUpdateEvents()
        handleSessionExtensionEvents()
        handlePingEvents()
        handleTransactionRequestEvents()
    }
    
    private func handleSessionEvents() {
        signAPI
            .sessionsPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] sessions in
                guard let self else { return }
                
                self.eventHandler?(.sessions(sessions))
            }.store(in: &publishers)
    }
    
    private func handleSessionProposalEvents() {
        signAPI
            .sessionProposalPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] sessionProposal, context in
                guard let self else { return }

                let preferences = preferencesForOngoingConnections[sessionProposal.pairingTopic]
                guard let preferences else { return }

                self.eventHandler?(
                    .proposeSession(
                        proposal: sessionProposal,
                        preferences: preferences
                    )
                )
            }.store(in: &publishers)
    }
    
    private func handleSessionDeletionEvents() {
        signAPI
            .sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] topic, reason in
                guard let self else { return }
                
                self.eventHandler?(
                    .deleteSession(
                        topic: topic,
                        reason: reason
                    )
                )

                self.sessionSource.removeWalletConnectSession(for: topic)
            }.store(in: &publishers)
    }
    
    private func handleSessionSettleEvents() {
        signAPI
            .sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] session in
                guard let self else { return }

                let topic = session.pairingTopic
                let preferences = preferencesForOngoingConnections[topic]
                guard let preferences else { return }

                self.eventHandler?(
                    .settleSession(
                        session: session,
                        preferences: preferences
                    )
                )

                clearOngoingWCConnectionRequest(for: topic)

                self.sessionSource.addWalletConnectSession(session)
            }.store(in: &publishers)
    }
    
    private func handleSessionUpdateEvents() {
        signAPI
            .sessionUpdatePublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] topic, namespaces in
                guard let self else { return }
                
                self.eventHandler?(
                    .updateSession(
                        topic: topic,
                        namespaces: namespaces
                    )
                )
            }.store(in: &publishers)
    }
    
    private func handleSessionExtensionEvents() {
        signAPI
            .sessionExtendPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] topic, date in
                guard let self else { return }
            
                self.eventHandler?(
                    .extendSession(
                        topic: topic,
                        date: date
                    )
                )
            }.store(in: &publishers)
    }
    
    private func handlePingEvents() {
        signAPI
            .pingResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] ping in
                guard let self else { return }
                
                self.eventHandler?(.pingSession(ping))
            }.store(in: &publishers)
    }
    
    private func handleTransactionRequestEvents() {
        signAPI
            .sessionRequestPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] request, context in
                guard let self else { return }
                
                self.eventHandler?(.transactionRequest(request))
            }.store(in: &publishers)
    }
}

extension WalletConnectV2Protocol {
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

enum WalletConnectV2Event {
    case sessions([WalletConnectV2Session])
    case proposeSession(
        proposal: WalletConnectV2SessionProposal,
        preferences: WalletConnectSessionCreationPreferences
    )
    case didCreateSessionFail(WalletConnectSessionCreationPreferences)
    case didConnectSessionFail(WalletConnectSessionCreationPreferences)
    case didDisconnectSession(WalletConnectV2Session)
    case didDisconnectSessionFail(
        session: WalletConnectV2Session,
        error: Error
    )
    case deleteSession(
        topic: WalletConnectTopic,
        reason: WalletConnectV2Reason
    )
    case settleSession(
        session: WalletConnectV2Session,
        preferences: WalletConnectSessionCreationPreferences
    )
    case updateSession(
        topic: WalletConnectTopic,
        namespaces: SessionNamespaces
    )
    case extendSession(
        topic: WalletConnectTopic,
        date: Date
    )
    case pingSession(WalletConnectTopic)
    case didPingSessionFail(
        session: WalletConnectV2Session,
        error: Error
    )
    case transactionRequest(WalletConnectV2Request)
    case failure(Error)
}

typealias SessionNamespaces = [String: SessionNamespace]
typealias WalletConnectV2SessionNamespace = SessionNamespace
typealias WalletConnectV2SessionProposal = WalletConnectSign.Session.Proposal
typealias WalletConnectV2SessionRejectionReason = RejectionReason
typealias WalletConnectV2Session = WalletConnectSign.Session
typealias WalletConnectV2Request = WalletConnectSign.Request
typealias WalletConnectV2CodableResult = AnyCodable
typealias WalletConnectV2Reason = Reason
typealias WalletConnectV2Account = WalletConnectUtils.Account
typealias WalletConnectV2URI = WalletConnectURI
