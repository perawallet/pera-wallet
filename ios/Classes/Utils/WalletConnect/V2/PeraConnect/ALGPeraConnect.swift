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

//   ALGPeraConnect.swift

import Foundation
import MacaroonUtils

final class ALGPeraConnect:
    PeraConnect,
    WeakPublisher {
    static let didReceiveSessionRequestNotification = Notification.Name(
        rawValue: "com.algorand.algorand.notification.peraConnect.didReceiveSessionRequest"
    )
    static let sessionRequestPreferencesKey = "peraConnect.preferences"

    var observations: [ObjectIdentifier: WeakObservation] = [:]

    var coordinatorEventHandler: ((WalletConnectCoordinatorEvent) -> Void)?
    
    private(set) var walletConnectCoordinator: WalletConnectCoordinator
    
    init(
        walletConnectCoordinator: WalletConnectCoordinator
    ) {
        self.walletConnectCoordinator = walletConnectCoordinator
        
        setWalletConnectCoordinatorEvents()
    }
}

extension ALGPeraConnect {
    func add(
        _ observer: PeraConnectObserver
    ) {
        let id = ObjectIdentifier(observer as AnyObject)
        observations[id] = WeakObservation(observer)
    }
}

extension ALGPeraConnect {
    private func publish(
        _ event: PeraConnectEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }

            self.notifyObservers {
                $0.peraConnect(
                    self,
                    didPublish: event
                )
            }
        }
    }
}

extension ALGPeraConnect {
    final class WeakObservation: WeakObservable {
        weak var observer: PeraConnectObserver?

        init(
            _ observer: PeraConnectObserver
        ) {
            self.observer = observer
        }
    }
}

extension ALGPeraConnect {
    private func setWalletConnectCoordinatorEvents() {
        walletConnectCoordinator.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .shouldStartV1(let session, let preferences, let completion):
                publish(
                    .shouldStartV1(
                        session: session,
                        preferences: preferences,
                        completion: completion
                    )
                )
            case .didConnectToV1(let session, let preferences):
                publish(
                    .didConnectToV1(
                        session: session,
                        preferences: preferences
                    )
                )
            case .didDisconnectFromV1(let session):
                publish(.didDisconnectFromV1(session))
            case .didDisconnectFromV1Fail(let session, let error):
                publish(
                    .didDisconnectFromV1Fail(
                        session: session,
                        error: error
                    )
                )
            case .didFailToConnectV1(let error, let preferences):
                publish(
                    .didFailToConnectV1(
                        error: error,
                        preferences: preferences
                    )
                )
            case .didExceedMaximumSessionFromV1:
                publish(.didExceedMaximumSessionFromV1)
            case .sessionsV2(let sessions):
                publish(.sessionsV2(sessions))
            case .proposeSessionV2(let proposal, let preferences):
                publish(
                    .proposeSessionV2(
                        proposal: proposal,
                        preferences: preferences
                    )
                )
            case .deleteSessionV2(let topic, let reason):
                publish(
                    .deleteSessionV2(
                        topic: topic,
                        reason: reason
                    )
                )
            case .settleSessionV2(let session, let preferences):
                publish(
                    .settleSessionV2(
                        session: session,
                        preferences: preferences
                    )
                )
            case .updateSessionV2(let topic, let namespaces):
                publish(
                    .updateSessionV2(
                        topic: topic,
                        namespaces: namespaces
                    )
                )
            case .didCreateV2SessionFail(let preferences):
                publish(.didCreateV2SessionFail(preferences))
            case .didConnectV2SessionFail(let preferences):
                publish(.didConnectV2SessionFail(preferences))
            case .didDisconnectFromV2(let session):
                publish(.didDisconnectFromV2(session))
            case .didDisconnectFromV2Fail(let session, let error):
                publish(
                    .didDisconnectFromV2Fail(
                        session: session,
                        error: error
                    )
                )
            case .extendSessionV2(let topic, let date):
                publish(
                    .extendSessionV2(
                        topic: topic,
                        date: date
                    )
                )
            case .pingV2(let ping):
                publish(.pingV2(ping))
            case .didPingV2SessionFail(let session, let error):
                publish(
                    .didPingV2SessionFail(
                        session: session,
                        error: error
                    )
                )
            case .transactionRequestV2(let request):
                publish(.transactionRequestV2(request))
            case .failure(let error):
                publish(.failure(error))
            }
        }
    }
}

extension ALGPeraConnect {
    func isValidSession(_ session: WalletConnectSessionText) -> Bool {
        walletConnectCoordinator.isValidSession(session: session)
    }
    
    func configureIfNeeded() {
        walletConnectCoordinator.configureIfNeeded()
    }
}

extension ALGPeraConnect {
    func connectToSession(with preferences: WalletConnectSessionCreationPreferences) {
        walletConnectCoordinator.connectToSession(with: preferences)
    }
    
    func reconnectToSession(_ params: WalletConnectSessionReconnectionParams) {
        walletConnectCoordinator.reconnectToSession(params)
    }
    
    func disconnectFromSession(_ params: any WalletConnectSessionDisconnectionParams) {
        walletConnectCoordinator.disconnectFromSession(params)
    }

    func disconnectFromAllSessions() {
        walletConnectCoordinator.disconnectFromAllSessions()
    }
    
    func updateSessionConnection(_ params: WalletConnectUpdateSessionConnectionParams) {
        walletConnectCoordinator.updateSessionConnection(params)
    }
    
    func extendSessionConnection(_ params: WalletConnectExtendSessionConnectionParams) {
        walletConnectCoordinator.extendSessionConnection(params)
    }

    func updateSessionsWithRemovingAccount(_ account: Account) {
        walletConnectCoordinator.updateSessionsWithRemovingAccount(account)
    }
}

extension ALGPeraConnect {
    func approveSessionConnection(_ params: WalletConnectApproveSessionConnectionParams) {
        walletConnectCoordinator.approveSessionConnection(params)
    }
    
    func rejectSessionConnection(_ params: WalletConnectRejectSessionConnectionParams) {
        walletConnectCoordinator.rejectSessionConnection(params)
    }
}

extension ALGPeraConnect {
    func approveTransactionRequest(_ params: WalletConnectApproveTransactionRequestParams) {
        walletConnectCoordinator.approveTransactionRequest(params)
    }
    
    func rejectTransactionRequest(_ params: WalletConnectRejectTransactionRequestParams) {
        walletConnectCoordinator.rejectTransactionRequest(params)
    }
}
