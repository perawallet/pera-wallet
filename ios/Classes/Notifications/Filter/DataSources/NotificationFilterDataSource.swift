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
//  NotificationFilterDataSource.swift

import UIKit
import MagpieCore
import MagpieExceptions

final class NotificationFilterDataSource: NSObject {
    weak var delegate: NotificationFilterDataSourceDelegate?

    var currentPushNotificationsSettings: UNNotificationSettings?

    private var accounts = [AccountHandle]()

    private let api: ALGAPI

    init(
        sharedDataController: SharedDataController,
        api: ALGAPI
    ) {
        self.api = api
        super.init()
        accounts = sharedDataController.sortedAccounts()
    }
}

extension NotificationFilterDataSource {
    func updateNotificationFilter(for account: AccountHandle, to value: Bool) {
        guard let deviceId = api.session.authenticatedUser?.getDeviceId(on: api.network) else {
            return
        }

        let draft = NotificationFilterDraft(deviceId: deviceId, accountAddress: account.value.address, receivesNotifications: value)
        api.updateNotificationFilter(draft) {
            [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .success(result):
                account.value.receivesNotification = result.receivesNotification
                self.delegate?.notificationFilterDataSource(self, didUpdateFilterValueFor: account)
            case let .failure(_, hipApiError):
                self.delegate?.notificationFilterDataSource(self, didFailToUpdateFilterValueFor: account, with: hipApiError)
            }
        }
    }
}

extension NotificationFilterDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }

        return accounts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if currentPushNotificationsSettings != nil {
                return dequeuePushNotificationsCell(in: collectionView, at: indexPath)
            } else {
                return dequeuePushNotificationsLoadingCell(in: collectionView, at: indexPath)
            }
        }

        return dequeueAccountNotificationCell(in: collectionView, at: indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind != UICollectionView.elementKindSectionHeader {
            fatalError("Unexpected element kind")
        }

        return dequeueHeaderView(in: collectionView, at: indexPath)
    }
}

extension NotificationFilterDataSource {
    private func dequeuePushNotificationsCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> TitledToggleCell {
        let cell = collectionView.dequeue(
            TitledToggleCell.self,
            at: indexPath
        )
        cell.delegate = self
        let isOn = currentPushNotificationsSettings?.authorizationStatus == .authorized
        cell.isOn = isOn
        return cell
    }

    private func dequeuePushNotificationsLoadingCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> TitledToggleLoadingCell {
        let cell = collectionView.dequeue(
            TitledToggleLoadingCell.self,
            at: indexPath
        )
        return cell
    }

    private func dequeueAccountNotificationCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> AccountNameSwitchCell {
        if let account = accounts[safe: indexPath.item] {
            let cell = collectionView.dequeue(AccountNameSwitchCell.self, at: indexPath)
            cell.bindData(AccountNameSwitchViewModel(account.value))
            cell.delegate = self
            return cell
        }
        fatalError("Unexpected cell type")
    }

    private func dequeueHeaderView(in collectionView: UICollectionView, at indexPath: IndexPath) -> ToggleTitleHeaderSupplementaryView {
        let headerView = collectionView.dequeueHeader(
            ToggleTitleHeaderSupplementaryView.self,
            at: indexPath
        )
        return headerView
    }
}

extension NotificationFilterDataSource {
    var isEmpty: Bool {
        return accounts.isEmpty
    }

    func account(at index: Int) -> AccountHandle? {
        return accounts[safe: index]
    }

    func index(of account: AccountHandle) -> Int? {
        return accounts.firstIndex { $0.value.address == account.value.address }
    }
}

extension NotificationFilterDataSource: TitledToggleCellDelegate {
    func titledToggleCell(_ titledToggleCell: TitledToggleCell, didChangeToggleValue value: Bool) {
        titledToggleCell.isOn = !value
        delegate?.notificationFilterDataSource(self, didChangePushNotificationsToggleValue: value)
    }
}

extension NotificationFilterDataSource: AccountNameSwitchCellDelegate {
    func accountNameSwitchCell(_ accountNameSwitchCell: AccountNameSwitchCell, didChangeToggleValue value: Bool) {
        delegate?.notificationFilterDataSource(self, didChangeAccountNotificationsToggleValue: value, from: accountNameSwitchCell)
    }
}

protocol NotificationFilterDataSourceDelegate: AnyObject {
    func notificationFilterDataSource(
        _ notificationFilterDataSource: NotificationFilterDataSource,
        didChangePushNotificationsToggleValue value: Bool
    )
    func notificationFilterDataSource(
        _ notificationFilterDataSource: NotificationFilterDataSource,
        didChangeAccountNotificationsToggleValue value: Bool,
        from cell: AccountNameSwitchCell
    )
    func notificationFilterDataSource(
        _ notificationFilterDataSource: NotificationFilterDataSource,
        didUpdateFilterValueFor account: AccountHandle
    )
    func notificationFilterDataSource(
        _ notificationFilterDataSource: NotificationFilterDataSource,
        didFailToUpdateFilterValueFor account: AccountHandle,
        with error: HIPAPIError?
    )
}
