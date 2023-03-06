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

//   WCSessionListLocalDataController.swift

import Foundation
import MacaroonUtils

final class WCSessionListLocalDataController: WCSessionListDataController {
    typealias EventHandler = (WCSessionListDataControllerEvent) -> Void

    var eventHandler: EventHandler?
    
    private let sharedDataController: SharedDataController

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.wcsessions.updates",
        qos: .userInitiated
    )

    private var lastSnapshot: Snapshot? = nil
    private var disconnectedSessions: Set<WCSession> = []

    private var cachedSessionListItems: [WCSession: WCSessionListItem] = [:]

    private lazy var sessions = [WCSession]()

    var shouldShowDisconnectAllAction: Bool {
        return walletConnector.allWalletConnectSessions.count > 1
    }

    private let analytics: ALGAnalytics
    private let walletConnector: WalletConnector

    init(
        _ sharedDataController: SharedDataController,
        analytics: ALGAnalytics,
        walletConnector: WalletConnector
    ) {
        self.sharedDataController = sharedDataController
        self.analytics = analytics
        self.walletConnector = walletConnector
    }
}

extension WCSessionListLocalDataController {
    func load() {
        setWCSessions()
        
        if sessions.isEmpty {
            deliverNoContentSnapshot()
        } else {
            deliverContentSnapshot()
        }
    }
    
    private func setWCSessions() {
        sessions = walletConnector
            .allWalletConnectSessions
            .sorted(by: \.date)
    }
}

extension WCSessionListLocalDataController {
    private func deliverNoContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([ .empty ])
            snapshot.appendItems(
                [ .empty ],
                toSection: .empty
            )
            return snapshot
        }
    }

    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return nil
            }

            var snapshot = Snapshot()

            snapshot.appendSections([ .sessions ])

            self.addSessionItems(&snapshot)

            return snapshot
        }
    }

    private func addSessionItems(_ snapshot: inout Snapshot) {
        let assetItems: [WCSessionListItem] = sessions.map {
            let item = makeSessionItem($0)

            if let session = item.session {
                cachedSessionListItems[session] = item
            }

            return item
        }

        snapshot.appendItems(
            assetItems,
            toSection: .sessions
        )
    }

    private func makeSessionItem(_ session: WCSession) -> WCSessionListItem {
        let viewModel = WCSessionItemViewModel(
            peermeta: session.peerMeta,
            sessionDate: session.date,
            accountList: getSessionAccountsFromLocal(session)
        )

        let item: WCSessionListItem = .session(
            WCSessionListItemContainer(
                session: session,
                viewModel: viewModel
            )
        )
        return item
    }
    
    func getSessionAccountsFromLocal(_ session: WCSession) -> [Account] {
        var localSessionAccounts: [Account] = []
        
        session.walletMeta?.accounts?.forEach {
            sessionAccountAddress in
            
            if let account = sharedDataController.accountCollection.account(for: sessionAccountAddress) {
                localSessionAccounts.append(account)
            }
        }
        
        return localSessionAccounts
    }

    private func removeSessionItem(
        _ snapshot: Snapshot,
        session: WCSession
    ) {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return nil
            }

            self.disconnectedSessions.remove(session)

            self.stopLoadingIfNeeded()

            let itemToDelete = self.cachedSessionListItems[session]

            guard let itemToDelete = itemToDelete else {
                return nil
            }

            self.cachedSessionListItems.removeValue(forKey: session)

            if self.cachedSessionListItems.isEmpty {
                self.deliverNoContentSnapshot()
                return nil
            }

            var snapshot = snapshot

            snapshot.deleteItems([ itemToDelete ])

            return snapshot
        }
    }

    func addSessionItem(
        _ snapshot: Snapshot,
        session: WCSession
    ) {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = snapshot

            if snapshot.sectionIdentifiers.contains(.empty) {
                snapshot.deleteSections([ .empty ])
            }
            
            let viewModel = WCSessionItemViewModel(
                peermeta: session.peerMeta,
                sessionDate: session.date,
                accountList: self.getSessionAccountsFromLocal(session)
            )

            let item: WCSessionListItem = .session(
                WCSessionListItemContainer(
                    session: session,
                    viewModel: viewModel
                )
            )

            if !snapshot.sectionIdentifiers.contains(.sessions) {
                snapshot.appendSections([ .sessions ] )
            }
            
            snapshot.insertItem(
                item,
                to: .sessions,
                at: 0
            )

            if let session = item.session {
                self.cachedSessionListItems[session] = item
            }

            return snapshot
        }
    }

    private func deliverSnapshot(_ snapshot: @escaping () -> Snapshot?) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else {
                return
            }

            guard let snapshot = snapshot() else {
                return
            }

            self.publish(.didUpdate(snapshot))
        }
    }
}

extension WCSessionListLocalDataController {
    func walletConnector(
        _ walletConnector: WalletConnector,
        didFailWith error: WalletConnector.WCError
    ) {
        switch error {
        case .failedToDisconnectInactiveSession(let session):
            guard let lastSnapshot = lastSnapshot else {
                return
            }

            removeSessionItem(
                lastSnapshot,
                session: session
            )
        case .failedToDisconnect(let session):
            disconnectedSessions.remove(session)

            stopLoadingIfNeeded()

            publish(.didFailDisconnectingFromSession)
        default: break
        }
    }

    func walletConnector(
        _ walletConnector: WalletConnector,
        didDisconnectFrom session: WCSession
    ) {
        analytics.track(
            .wcSessionDisconnected(
                dappName: session.peerMeta.name,
                dappURL: session.peerMeta.url.absoluteString,
                address: session.walletMeta?.accounts?.first
            )
        )

        guard let lastSnapshot = lastSnapshot else {
            return
        }

        removeSessionItem(
            lastSnapshot,
            session: session
        )
    }
}

extension WCSessionListLocalDataController {
    func disconnectAllSessions(_ snapshot: Snapshot) {
        publish(.didStartDisconnectingFromSessions)

        lastSnapshot = snapshot
        
        let allSessions = walletConnector.allWalletConnectSessions
        
        disconnectedSessions = Set(allSessions)
        
        walletConnector.disconnectFromAllSessions()
    }

    func disconnectSession(
        _ snapshot: Snapshot,
        session: WCSession
    ) {
        publish(.didStartDisconnectingFromSession)

        lastSnapshot = snapshot

        disconnectedSessions.insert(session)

        walletConnector.disconnectFromSession(session)
    }
}

extension WCSessionListLocalDataController {
    private func stopLoadingIfNeeded() {
        if disconnectedSessions.isEmpty {
            publish(.didDisconnectFromSessions)
        }
    }
}

extension WCSessionListLocalDataController {
    private func publish(_ event: WCSessionListDataControllerEvent) {
        asyncMain {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(event)
        }
    }
}
