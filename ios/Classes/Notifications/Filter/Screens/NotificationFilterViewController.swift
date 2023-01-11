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
import MacaroonUtils

final class NotificationFilterViewController:
    BaseViewController,
    NotificationObserver {
    var notificationObservations: [NSObjectProtocol] = []

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = NotificationFilterListLayout.build()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.contentInset.top = 20
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(AccountNameSwitchCell.self)
        collectionView.register(TitledToggleCell.self)
        collectionView.register(TitledToggleLoadingCell.self)
        collectionView.register(header: ToggleTitleHeaderSupplementaryView.self)
        return collectionView
    }()

    private lazy var listDataSource = NotificationFilterDataSource(
        sharedDataController: sharedDataController,
        api: api!
    )
    private lazy var listLayout = NotificationFilterListLayout(dataSource: listDataSource)
    
    private let theme = NotificationFilterViewControllerTheme()

    deinit {
        stopObservingNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        getPushNotificationSettings {
            [weak self] settings in
            guard let self = self else {
                return
            }

            self.updatePushNotificationsToggle(settings)
        }
    }

    override func configureAppearance() {
        super.configureAppearance()
        
        title = "notifications-title".localized
    }

    override func linkInteractors() {
        super.linkInteractors()

        listView.dataSource = listDataSource
        listView.delegate = listLayout
        listDataSource.delegate = self

        observeWhenApplicationWillEnterForeground {
            [weak self] _ in
            guard let self = self else {
                return
            }

            if self.presentedViewController is UIAlertController {
                return
            }

            self.updatePushNotificationsToggleIfNeeded()
        }
    }
    
    override func prepareLayout() {
        super.prepareLayout()

        addUI()
    }
    
    private func addUI() {
        addBackground()
        addList()
    }
}

extension NotificationFilterViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }
    
    private func addList() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension NotificationFilterViewController: NotificationFilterDataSourceDelegate {
    func notificationFilterDataSource(
        _ notificationFilterDataSource: NotificationFilterDataSource,
        didChangePushNotificationsToggleValue value: Bool
    ) {
        presentAlertForPushNotificationsToggleChange(value)
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
    private func presentAlertForPushNotificationsToggleChange(_ isOn: Bool) {
        let alertTitle: String
        let alertMessage: String

        if isOn {
            alertTitle = "settings-notification-disabled-go-settings-title".localized
            alertMessage = "settings-notification-disabled-go-settings-text".localized
        } else {
            alertTitle = "settings-notification-enabled-go-settings-title".localized
            alertMessage = "settings-notification-enabled-go-settings-text".localized
        }

        let alertController = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: .alert
        )

        let openAppSettingsAction = UIAlertAction(
            title: "title-launch-ios-settings".localized,
            style: .default
        ) { _ in
            UIApplication.shared.openAppSettings()
        }
        alertController.addAction(openAppSettingsAction)

        let cancelAction = UIAlertAction(
            title: "title-cancel".localized,
            style: .cancel
        )
        alertController.addAction(cancelAction)

        present(
            alertController,
            animated: true
        )
    }

    private func updatePushNotificationsToggleIfNeeded() {
        updatePushNotificationsToggle(nil)

        getPushNotificationSettings {
            [weak self] settings in
            guard let self = self else {
                return
            }

            self.updatePushNotificationsToggle(settings)
        }
    }

    private func updatePushNotificationsToggle(_ settings: UNNotificationSettings?) {
        listDataSource.currentPushNotificationsSettings = settings

        asyncMain {
            self.listView.reloadItems(at: [ IndexPath(item: 0, section: 0) ])
        }
    }

    private func getPushNotificationSettings(_ completionHandler: @escaping (UNNotificationSettings) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: completionHandler)
    }
}

extension NotificationFilterViewController {
    private func updateNotificationFilter(of cell: AccountNameSwitchCell, with value: Bool) {
        guard let indexPath = listView.indexPath(for: cell),
              let account = listDataSource.account(at: indexPath.item) else {
                  return
              }

        listDataSource.updateNotificationFilter(for: account, to: value)
    }

    private func updateAccount(_ account: AccountHandle) {
        guard let localAccount = api?.session.accountInformation(from: account.value.address) else {
            return
        }

        localAccount.receivesNotification = account.value.receivesNotification
        api?.session.authenticatedUser?.updateAccount(localAccount)
    }

    private func revertFilterSwitch(for account: AccountHandle) {
        guard let index = listDataSource.index(of: account),
              let cell = listView.cellForItem(
                at: IndexPath(item: index, section: 1)
              ) as? AccountNameSwitchCell else {
                  return
              }

        cell.bindData(AccountNameSwitchViewModel(account.value))
    }
}
