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
    private let sharedDataController: SharedDataController
    private var contacts = [Contact]()
    private(set) var notifications = [NotificationMessage]()

    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.notificationsDataController")

    private var nextCursor: String?

    private var hasNext: Bool {
        return nextCursor != nil
    }

    init(
        sharedDataController: SharedDataController,
        api: ALGAPI
    ) {
        self.sharedDataController = sharedDataController
        self.api = api

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

                if isPaginated {
                    self.notifications.append(contentsOf: notifications.results.uniqued())
                } else {
                    self.notifications = notifications.results.uniqued()
                }

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
            senderAccount: getSenderAccountIfExists(for: notification),
            receiverAccount: getReceiverAccountIfExists(for: notification),
            contact: getContactIfExists(for: notification),
            latestReadTimestamp: latesTimestamp
        )
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
    private func fetchContacts() {
        Contact.fetchAll(entity: Contact.entityName) { response in
            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Contact] else {
                    return
                }

                self.contacts = results
            default:
                break
            }
        }
    }

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

extension NotificationsAPIDataController {
    private func getSenderAccountIfExists(for notification: NotificationMessage) -> Account? {
        let senderAddress = notification.detail?.senderAddress
        return senderAddress.unwrap { sharedDataController.accountCollection[$0]?.value }
    }

    private func getReceiverAccountIfExists(for notification: NotificationMessage) -> Account? {
        let receiverAddress = notification.detail?.receiverAddress
        return receiverAddress.unwrap { sharedDataController.accountCollection[$0]?.value }
    }

    private func getContactIfExists(for notification: NotificationMessage) -> Contact? {
        guard let details = notification.detail else {
            return nil
        }

        return contacts.first { contact -> Bool in
            if let contactAddress = contact.address {
                return contactAddress == details.senderAddress || contactAddress == details.receiverAddress
            }
            return false
        }
    }

    func getUserAccount(
        from notificationDetail: NotificationDetail
    ) -> (account: Account?, asset: TransactionMode?) {
        let account: Account?
        
        if notificationDetail.type.isSent() {
            account = getAccount(from: notificationDetail.senderAddress) ?? getAccount(from: notificationDetail.receiverAddress)
        } else {
            account = getAccount(from: notificationDetail.receiverAddress) ?? getAccount(from: notificationDetail.senderAddress)
        }

        guard let account = account  else {
            return (nil, nil)
        }

        let asset = notificationDetail.asset?.id.unwrap { account[$0] }
        
        if notificationDetail.asset?.id != nil && asset == nil {
            return (account: account, asset: nil)
        }
        
        if let asset = asset {
            return (account: account, asset: .asset(asset))
        }
        
        return (account: account, asset: .algo)
    }
    
    private func getAccount(from address: String?) -> Account? {
        guard let address = address else {
            return nil
        }

        return sharedDataController.accountCollection[address]?.value
    }
}
