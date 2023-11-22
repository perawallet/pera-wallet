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

//   PeraConnect.swift

import Foundation

protocol PeraConnect: AnyObject {
    var walletConnectCoordinator: WalletConnectCoordinator { get }
    
    func isValidSession(_ session: WalletConnectSessionText) -> Bool
    
    func configureIfNeeded()
    
    func connectToSession(with preferences: WalletConnectSessionCreationPreferences)
    func reconnectToSession(_ params: WalletConnectSessionReconnectionParams)
    func disconnectFromSession(_ params: any WalletConnectSessionDisconnectionParams)
    func disconnectFromAllSessions()
    func updateSessionsWithRemovingAccount(_ account: Account)
    func approveSessionConnection(_ params: WalletConnectApproveSessionConnectionParams)
    func rejectSessionConnection(_ params: WalletConnectRejectSessionConnectionParams)
    func updateSessionConnection(_ params: WalletConnectUpdateSessionConnectionParams)
    func extendSessionConnection(_ params: WalletConnectExtendSessionConnectionParams)

    func approveTransactionRequest(_ params: WalletConnectApproveTransactionRequestParams)
    func rejectTransactionRequest(_ params: WalletConnectRejectTransactionRequestParams)

    func add(_ observer: PeraConnectObserver)
    func remove(_ observer: PeraConnectObserver)
}

protocol PeraConnectObserver: AnyObject {
    func peraConnect(
        _ peraConnect: PeraConnect,
        didPublish event: PeraConnectEvent
    )
}

enum PeraConnectEvent {    
    case shouldStartV1(
        session: WalletConnectSession,
        preferences: WalletConnectSessionCreationPreferences,
        completion: WalletConnectSessionConnectionCompletionHandler
    )
    case didConnectToV1(
        session: WCSession,
        preferences: WalletConnectSessionCreationPreferences
    )
    case didDisconnectFromV1(WCSession)
    case didDisconnectFromV1Fail(
        session: WCSession,
        error: WalletConnectV1Protocol.WCError
    )
    case didDisconnectFromV2(WalletConnectV2Session)
    case didDisconnectFromV2Fail(
        session: WalletConnectV2Session,
        error: Error
    )
    case didFailToConnectV1(
        error: WalletConnectV1Protocol.WCError,
        preferences: WalletConnectSessionCreationPreferences
    )
    case didExceedMaximumSessionFromV1
    case sessionsV2([WalletConnectV2Session])
    case proposeSessionV2(
        proposal: WalletConnectV2SessionProposal,
        preferences: WalletConnectSessionCreationPreferences
    )
    case deleteSessionV2(
        topic: WalletConnectTopic,
        reason: WalletConnectV2Reason
    )
    case settleSessionV2(
        session: WalletConnectV2Session,
        preferences: WalletConnectSessionCreationPreferences
    )
    case didCreateV2SessionFail(WalletConnectSessionCreationPreferences)
    case didConnectV2SessionFail(WalletConnectSessionCreationPreferences)
    case updateSessionV2(
        topic: WalletConnectTopic,
        namespaces: SessionNamespaces
    )
    case extendSessionV2(
        topic: WalletConnectTopic,
        date: Date
    )
    case pingV2(WalletConnectTopic)
    case didPingV2SessionFail(
        session: WalletConnectV2Session,
        error: Error
    )
    case transactionRequestV2(WalletConnectV2Request)
    case failure(Error)
}
