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

//   NotificationsAPIDataController.swift

import Foundation
import MacaroonUtils

final class NotificationsAPIDataController:
    NotificationsDataController {
    var eventHandler: ((NotificationsDataControllerEvent) -> Void)?

    private var lastSnapshot: Snapshot?

    private let api: ALGAPI
    private let lastSeenNotificationController: LastSeenNotificationController?

    private(set) var notifications = [NotificationMessage]()

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.notifications.updates",
        qos: .userInitiated
    )

    private var nextCursor: String?

    private var hasNext: Bool {
        return nextCursor != nil
    }

    init(
        api: ALGAPI,
        lastSeenNotificationController: LastSeenNotificationController?
    ) {
        self.api = api
        self.lastSeenNotificationController = lastSeenNotificationController

        startObserving()
    }
}

extension NotificationsAPIDataController {
    func reload() {
        self.notifications.removeAll()
        self.nextCursor = nil

        self.load()
    }

    func load(isPaginated: Bool = false) {
        if !isPaginated {
            deliverLoadingSnapshot()
        }

        load(with: nil)
    }

    func loadNextPageIfNeeded(for indexPath: IndexPath) {
        guard indexPath.item == notifications.count - 3, hasNext else {
            return
        }

        load(with: nil, isPaginated: true)
    }

    private func load(with query: String?, isPaginated: Bool = false) {
        guard let deviceId = api.session.authenticatedUser?.getDeviceId(on: api.network) else {
            ///TODO: Should Deliver error snapshot
            deliverNoContentSnapshot()
            return
        }

        api.getNotifications(deviceId, with: CursorQuery(cursor: nextCursor)) { response in
            switch response {
            case let .success(notifications):
                if !isPaginated {
                    self.notifications.removeAll()
                    self.nextCursor = nil
                }

                self.nextCursor = notifications.nextCursor

                let newNotifications = notifications.results.filterDuplicates()
                if isPaginated {
                    self.notifications.append(contentsOf: newNotifications)
                } else {
                    self.notifications = newNotifications
                }

                self.setLastSeenNotification(self.notifications.first)
                self.deliverContentSnapshot()
            case .failure:
                ///TODO: Should Deliver error snapshot
                self.deliverNoContentSnapshot()
            }
        }
    }

    private func formViewModel(
        from notification: NotificationMessage,
        latesTimestamp: TimeInterval?
    ) -> NotificationsViewModel {
        return NotificationsViewModel(
            notification: notification,
            latestReadTimestamp: latesTimestamp
        )
    }

    private func setLastSeenNotification(_ notification: NotificationMessage?) {
        guard let notification = notification else {
            return
        }

        lastSeenNotificationController?.setLastSeenNotification(notification)
    }
}

extension NotificationsAPIDataController {
    private func deliverLoadingSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems([.loading("1"), .loading("2")], toSection: .empty)
            return snapshot
        }
    }

    private func deliverContentSnapshot() {
        guard !self.notifications.isEmpty else {
            deliverNoContentSnapshot()
            return
        }

        let latesTimestamp = api.session.notificationLatestFetchTimestamp

        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = Snapshot()
            var notificationItems: [NotificationListViewItem] = []

            self.notifications.forEach { notification in
                let notificationItem: NotificationListViewItem =
                    .notification(self.formViewModel(from: notification, latesTimestamp: latesTimestamp))
                notificationItems.append(notificationItem)
            }

            snapshot.appendSections([.notifications])
            snapshot.appendItems(
                notificationItems,
                toSection: .notifications
            )

            self.api.session.notificationLatestFetchTimestamp = Date().timeIntervalSince1970

            return snapshot
        }
    }

    private func deliverNoContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.noContent],
                toSection: .empty
            )
            return snapshot
        }
    }

    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else { return }

            let newSnapshot = snapshot()

            self.lastSnapshot = newSnapshot
            self.publish(.didUpdate(newSnapshot))
        }
    }
}

extension NotificationsAPIDataController {
    private func publish(
        _ event: NotificationsDataControllerEvent
    ) {
        asyncMain { [weak self] in
            guard let self = self else {
                return
            }

            self.eventHandler?(event)
        }
    }
}

extension NotificationsAPIDataController {
    private func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didDeviceIDSet(notification:)),
            name: .DeviceIDDidSet,
            object: nil
        )
    }

    @objc
    private func didDeviceIDSet(notification: Notification) {
        if lastSnapshot == nil {
            load()
        }
    }
}
