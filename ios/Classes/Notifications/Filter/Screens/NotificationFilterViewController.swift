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
//  NotificationFilterViewController.swift

import UIKit
import MagpieCore
import MagpieHipo
import MagpieExceptions

final class NotificationFilterViewController: BaseViewController {
    private lazy var notificationFilterView = NotificationFilterView()

    private lazy var dataSource: NotificationFilterDataSource = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return NotificationFilterDataSource(sharedDataController: sharedDataController, api: api)
    }()

    private lazy var listLayout = NotificationFilterListLayout(dataSource: dataSource)

    override func configureAppearance() {
        super.configureAppearance()
        title = "notifications-title".localized
    }

    override func linkInteractors() {
        notificationFilterView.collectionView.dataSource = dataSource
        notificationFilterView.collectionView.delegate = listLayout
        dataSource.delegate = self
    }
    
    override func prepareLayout() {
        view.addSubview(notificationFilterView)
        notificationFilterView.snp.makeConstraints {
            $0.top.safeEqualToTop(of: self)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension NotificationFilterViewController: NotificationFilterDataSourceDelegate {
    func notificationFilterDataSource(
        _ notificationFilterDataSource: NotificationFilterDataSource,
        didChangePushNotificationsToggleValue value: Bool
    ) {
        presentNotificationAlert(isNotificationEnabled: value)
    }

    func notificationFilterDataSource(
        _ notificationFilterDataSource: NotificationFilterDataSource,
        didChangeAccountNotificationsToggleValue value: Bool,
        from cell: AccountNameSwitchCell
    ) {
        loadingController?.startLoadingWithMessage("title-loading".localized)
        updateNotificationFilter(of: cell, with: value)
    }

    func notificationFilterDataSource(
        _ notificationFilterDataSource: NotificationFilterDataSource,
        didUpdateFilterValueFor account: AccountHandle
    ) {
        loadingController?.stopLoading()
        updateAccount(account)
        analytics.track(
            .changeNotificationFilter(account: account.value)
        )
    }

    func notificationFilterDataSource(
        _ notificationFilterDataSource: NotificationFilterDataSource,
        didFailToUpdateFilterValueFor account: AccountHandle,
        with error: HIPAPIError?
    ) {
        loadingController?.stopLoading()
        bannerController?.presentErrorBanner(
            title: "title-error".localized,
            message: error?.fallbackMessage ?? "transaction-filter-error-title".localized
        )
        revertFilterSwitch(for: account)
    }
}

extension NotificationFilterViewController {
    private func presentNotificationAlert(isNotificationEnabled: Bool) {
        let alertMessage: String = isNotificationEnabled ?
        "settings-notification-disabled-go-settings-text".localized :
        "settings-notification-enabled-go-settings-text".localized

        let alertController = UIAlertController(
            title: "settings-notification-go-settings-title".localized,
            message: alertMessage,
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: "title-go-to-settings".localized, style: .default) { _ in
            UIApplication.shared.openAppSettings()
        }

        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel) { _ in
            self.updatePushNotificationStatus()
        }

        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    private func updatePushNotificationStatus() {
        if let cell = notificationFilterView.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? TitledToggleCell {
            cell.bindData(TitledToggleViewModel())
        }
    }

    private func updateNotificationFilter(of cell: AccountNameSwitchCell, with value: Bool) {
        guard let indexPath = notificationFilterView.collectionView.indexPath(for: cell),
              let account = dataSource.account(at: indexPath.item) else {
                  return
              }

        dataSource.updateNotificationFilter(for: account, to: value)
    }

    private func updateAccount(_ account: AccountHandle) {
        guard let localAccount = api?.session.accountInformation(from: account.value.address) else {
            return
        }

        localAccount.receivesNotification = account.value.receivesNotification
        api?.session.authenticatedUser?.updateAccount(localAccount)
    }

    private func revertFilterSwitch(for account: AccountHandle) {
        guard let index = dataSource.index(of: account),
              let cell = notificationFilterView.collectionView.cellForItem(
                at: IndexPath(item: index, section: 1)
              ) as? AccountNameSwitchCell else {
                  return
              }

        cell.bindData(AccountNameSwitchViewModel(account.value))
    }
}
