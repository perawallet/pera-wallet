// Copyright 2019 Algorand, Inc.

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
import Magpie

class NotificationFilterDataSource: NSObject {

    weak var delegate: NotificationFilterDataSourceDelegate?

    private let api: AlgorandAPI

    private var accounts = [Account]()

    init(api: AlgorandAPI) {
        self.api = api
        super.init()
        accounts = api.session.accounts
    }
}

extension NotificationFilterDataSource {
    func updateNotificationFilter(for account: Account, to value: Bool) {
        guard let deviceId = api.session.authenticatedUser?.deviceId else {
            return
        }

        let draft = NotificationFilterDraft(deviceId: deviceId, accountAddress: account.address, receivesNotifications: value)
        api.updateNotificationFilter(with: draft) { response in
            switch response {
            case let .success(result):
                account.receivesNotification = result.receivesNotification
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
            return dequeuePushNotificationCell(in: collectionView, at: indexPath)
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
    private func dequeuePushNotificationCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> TitledToggleCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TitledToggleCell.reusableIdentifier,
            for: indexPath
        ) as? TitledToggleCell else {
            fatalError("Unexpected cell type")
        }

        cell.bind(TitledToggleViewModel())
        cell.delegate = self
        return cell
    }

    private func dequeueAccountNotificationCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> AccountNameSwitchCell {
        if let account = accounts[safe: indexPath.item],
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AccountNameSwitchCell.reusableIdentifier,
                for: indexPath
            ) as? AccountNameSwitchCell {

            cell.bind(AccountNameSwitchViewModel(account: account, isLastIndex: isAtLastIndex(indexPath.item)))
            cell.delegate = self
            return cell
        }

        fatalError("Unexpected cell type")
    }

    private func dequeueHeaderView(in collectionView: UICollectionView, at indexPath: IndexPath) -> ToggleTitleHeaderView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ToggleTitleHeaderView.reusableIdentifier,
            for: indexPath
        ) as? ToggleTitleHeaderView else {
            fatalError("Unexpected header type")
        }

        return headerView
    }
}

extension NotificationFilterDataSource {
    var isEmpty: Bool {
        return accounts.isEmpty
    }

    func account(at index: Int) -> Account? {
        return accounts[safe: index]
    }

    func index(of account: Account) -> Int? {
        return accounts.firstIndex(of: account)
    }

    func isAtLastIndex(_ index: Int) -> Bool {
        return index == accounts.count - 1
    }
}

extension NotificationFilterDataSource: TitledToggleCellDelegate {
    func titledToggleCell(_ titledToggleCell: TitledToggleCell, didChangeToggleValue value: Bool) {
        delegate?.notificationFilterDataSource(self, didChangePushNotificationsToggleValue: value)
    }
}

extension NotificationFilterDataSource: AccountNameSwitchCellDelegate {
    func accountNameSwitchCell(_ accountNameSwitchCell: AccountNameSwitchCell, didChangeToggleValue value: Bool) {
        delegate?.notificationFilterDataSource(self, didChangeAccountNotificationsToggleValue: value, from: accountNameSwitchCell)
    }
}

protocol NotificationFilterDataSourceDelegate: class {
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
        didUpdateFilterValueFor account: Account
    )
    func notificationFilterDataSource(
        _ notificationFilterDataSource: NotificationFilterDataSource,
        didFailToUpdateFilterValueFor account: Account,
        with error: HIPAPIError?
    )
}
