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

final class WCSessionListLocalDataController:
    WCSessionListDataController,
    PeraConnectObserver {
    typealias EventHandler = (WCSessionListDataControllerEvent) -> Void
    var eventHandler: EventHandler?

    private lazy var snapshotQueue = makeSnapshotQueue()

    private var lastSnapshot: Snapshot? = nil

    private var cachedSessionListItems: [WalletConnectTopic: WCSessionListItem] = [:]
    private var disconnectedSessions: Set<WCSessionDraft> = []

    private var sessions: [WCSessionDraft] = []
    private var wcV2SessionConnectionDates: [WalletConnectTopic: Date] = [:]

    var shouldShowDisconnectAllAction: Bool {
        let sessions = peraConnect.walletConnectCoordinator.getSessions()
        return sessions.count > 1
    }

    private let sharedDataController: SharedDataController
    private let analytics: ALGAnalytics
    private let peraConnect: PeraConnect

    init(
        sharedDataController: SharedDataController,
        analytics: ALGAnalytics,
        peraConnect: PeraConnect
    ) {
        self.sharedDataController = sharedDataController
        self.analytics = analytics
        self.peraConnect = peraConnect

        peraConnect.add(self)
    }

    subscript(sessionForTopic: WalletConnectTopic) -> WCSessionListItem? {
        return cachedSessionListItems[sessionForTopic]
    }
}

extension WCSessionListLocalDataController {
    func load() {
        reset()

        sessions = peraConnect.walletConnectCoordinator.getSessions()
        wcV2SessionConnectionDates = peraConnect.walletConnectCoordinator.walletConnectProtocolResolver.walletConnectV2Protocol.getConnectionDates()

        if sessions.isEmpty {
            deliverNoContentSnapshot()
        } else {
            deliverContentSnapshot()
        }
    }

    private func reset() {
        cachedSessionListItems = [:]

        disconnectedSessions = []
        stopLoadingIfNeeded()
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
            guard let self else { return nil }

            var snapshot = Snapshot()
            snapshot.appendSections([ .sessions ])
            self.addSessionItems(&snapshot)
            return snapshot
        }
    }

    private func addSessionItems(_ snapshot: inout Snapshot) {
        let sortedSessions = getSortedSessions()
        let items: [WCSessionListItem] = sortedSessions.map {
            let item = makeSessionItem($0)

            let topic =
                $0.wcV1Session?.urlMeta.topic ??
                $0.wcV2Session?.topic
            if let topic {
                cachedSessionListItems[topic] = item
            }

            return item
        }
        snapshot.appendItems(
            items,
            toSection: .sessions
        )
    }

    private func getSortedSessions() -> [WCSessionDraft] {
        func getConnectionDate(session: WCSessionDraft) -> Date? {
            if let wcV1SessionDate = session.wcV1Session?.date {
                return wcV1SessionDate
            } else if let wcV2SessionTopic = session.wcV2Session?.topic {
                return wcV2SessionConnectionDates[wcV2SessionTopic]
            }

            return nil
        }

        let sortedSessionsByDescendingConnectionDate = sessions.sorted { firstSession, secondSession in
            guard let firstConnectionDate = getConnectionDate(session: firstSession),
                  let secondConnectionDate = getConnectionDate(session: secondSession) else {
                return false
            }

            return firstConnectionDate > secondConnectionDate
        }
        return sortedSessionsByDescendingConnectionDate
    }

    private func makeSessionItem(_ draft: WCSessionDraft) -> WCSessionListItem {
        let viewModel = WCSessionItemViewModel(draft)
        let item: WCSessionListItem = .session(
            WCSessionListItemContainer(
                session: draft,
                viewModel: viewModel
            )
        )
        return item
    }
}

extension WCSessionListLocalDataController {
    private func addSessionItem(
        _ snapshot: Snapshot,
        draft: WCSessionDraft
    ) {
        deliverSnapshot {
            [weak self] in
            guard let self else { return nil }

            let topic =
                draft.wcV1Session?.urlMeta.topic ??
                draft.wcV2Session?.topic
            guard let topic else { return nil }

            if cachedSessionListItems[topic] != nil {
                return nil
            }

            var snapshot = snapshot

            if snapshot.sectionIdentifiers.contains(.empty) {
                snapshot.deleteSections([ .empty ])
            }

            let viewModel = WCSessionItemViewModel(draft)
            let item: WCSessionListItem = .session(
                WCSessionListItemContainer(
                    session: draft,
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

            self.cachedSessionListItems[topic] = item

            return snapshot
        }
    }

    private func removeSessionItem(
        _ snapshot: Snapshot,
        draft: WCSessionDraft
    ) {
        deliverSnapshot {
            [weak self] in
            guard let self else { return nil }

            self.disconnectedSessions.remove(draft)

            self.stopLoadingIfNeeded()

            let topic =
                draft.wcV1Session?.urlMeta.topic ??
                draft.wcV2Session?.topic
            guard let topic else { return nil }

            let itemToDelete = self.cachedSessionListItems[topic]

            guard let itemToDelete else { return nil }

            self.cachedSessionListItems.removeValue(forKey: topic)

            if self.cachedSessionListItems.isEmpty {
                self.deliverNoContentSnapshot()
                return nil
            }

            var snapshot = snapshot

            snapshot.deleteItems([ itemToDelete ])

            return snapshot
        }
    }
}

extension WCSessionListLocalDataController {
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
    func disconnectAllSessions(_ snapshot: Snapshot) {
        publish(.didStartDisconnectingFromSessions)

        let allSessions = peraConnect.walletConnectCoordinator.getSessions()

        disconnectedSessions = Set(allSessions)

        peraConnect.disconnectFromAllSessions()
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
    func peraConnect(
        _ peraConnect: PeraConnect,
        didPublish event: PeraConnectEvent
    ) {
        switch event {
        case .didConnectToV1(let session, _):
            guard let lastSnapshot else { return }

            let draft = WCSessionDraft(wcV1Session: session)
            addSessionItem(
                lastSnapshot,
                draft: draft
            )
        case .settleSessionV2(let session, _):
            guard let lastSnapshot else { return }

            let draft = WCSessionDraft(wcV2Session: session)
            addSessionItem(
                lastSnapshot,
                draft: draft
            )
        case .didDisconnectFromV1(let session):
            guard let lastSnapshot else { return }

            analytics.track(
                .wcSessionDisconnected(
                    version: .v1,
                    dappName: session.peerMeta.name,
                    dappURL: session.peerMeta.url.absoluteString,
                    address: session.walletMeta?.accounts?.first
                )
            )

            let draft = WCSessionDraft(wcV1Session: session)
            removeSessionItem(
                lastSnapshot,
                draft: draft
            )
        case .didDisconnectFromV1Fail(let session, let error):
            guard let lastSnapshot else { return }

            switch error {
            case .failedToDisconnectInactiveSession:
                analytics.track(
                    .wcSessionDisconnected(
                        version: .v1,
                        dappName: session.peerMeta.name,
                        dappURL: session.peerMeta.url.absoluteString,
                        address: session.walletMeta?.accounts?.first
                    )
                )

                let draft = WCSessionDraft(wcV1Session: session)
                removeSessionItem(
                    lastSnapshot,
                    draft: draft
                )
            case .failedToDisconnect:
                let draft = WCSessionDraft(wcV1Session: session)
                disconnectedSessions.remove(draft)

                stopLoadingIfNeeded()

                publish(.didFailDisconnectingFromSession)
            default: break
            }
        case .didDisconnectFromV2(let session):
            guard let lastSnapshot else { return }

            analytics.track(
                .wcSessionDisconnected(
                    version: .v2,
                    dappName: session.peer.name,
                    dappURL: session.peer.url,
                    address: session.accounts.map(\.address).joined(separator: ",")
                )
            )

            let draft = WCSessionDraft(wcV2Session: session)
            removeSessionItem(
                lastSnapshot,
                draft: draft
            )
        case .didDisconnectFromV2Fail(let session, _):
            let draft = WCSessionDraft(wcV2Session: session)
            disconnectedSessions.remove(draft)

            stopLoadingIfNeeded()

            publish(.didFailDisconnectingFromSession)
        case .deleteSessionV2(let topic, _):
            guard let lastSnapshot else { return }

            let listItem = cachedSessionListItems[topic]
            guard let wcV2Session = listItem?.session?.wcV2Session else {
                return
            }

            analytics.track(
                .wcSessionDisconnected(
                    version: .v2,
                    dappName: wcV2Session.peer.name,
                    dappURL: wcV2Session.peer.url,
                    address: wcV2Session.accounts.map(\.address).joined(separator: ",")
                )
            )

            let draft = WCSessionDraft(wcV2Session: wcV2Session)
            removeSessionItem(
                lastSnapshot,
                draft: draft
            )
        case .didExceedMaximumSessionFromV1:
            load()
        default:
            break
        }
    }
}

extension WCSessionListLocalDataController {
    private func makeSnapshotQueue() -> DispatchQueue {
        let queue = DispatchQueue(
            label: "pera.queue.wcSessions.updates",
            qos: .userInitiated
        )
        return queue
    }
}

extension WCSessionListLocalDataController {
    private func publish(_ event: WCSessionListDataControllerEvent) {
        asyncMain {
            [weak self] in
            guard let self else { return }

            self.eventHandler?(event)

            if let snapshot = event.snapshot {
                self.lastSnapshot = snapshot
            }
        }
    }
}
