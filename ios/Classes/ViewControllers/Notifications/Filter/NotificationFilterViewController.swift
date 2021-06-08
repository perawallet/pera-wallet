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
//  NotificationFilterViewController.swift

import UIKit
import Magpie
import SVProgressHUD

class NotificationFilterViewController: BaseViewController {

    private lazy var accountsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Colors.Background.primary
        collectionView.contentInset = .zero
        collectionView.register(AccountNameSwitchCell.self, forCellWithReuseIdentifier: AccountNameSwitchCell.reusableIdentifier)
        collectionView.register(TitledToggleCell.self, forCellWithReuseIdentifier: TitledToggleCell.reusableIdentifier)
        collectionView.register(
            ToggleTitleHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ToggleTitleHeaderView.reusableIdentifier
        )
        return collectionView
    }()

    private lazy var dataSource: NotificationFilterDataSource = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return NotificationFilterDataSource(api: api)
    }()

    private lazy var listLayout = NotificationFilterListLayout(dataSource: dataSource)

    private let flow: Flow

    init(flow: Flow, configuration: ViewControllerConfiguration) {
        self.flow = flow
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        if flow != .notifications {
            return
        }

        setLeftBarButtons()
        setRightBarButtons()
    }

    override func configureAppearance() {
        super.configureAppearance()
        title = "notifications-title".localized
    }

    override func linkInteractors() {
        accountsCollectionView.dataSource = dataSource
        accountsCollectionView.delegate = listLayout
        dataSource.delegate = self
    }
    
    override func prepareLayout() {
        setupAccountsCollectionViewLayout()
    }
}

extension NotificationFilterViewController {
    private func setLeftBarButtons() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }

        leftBarButtonItems = [closeBarButtonItem]
    }

    private func setRightBarButtons() {
        let doneBarButtonItem = ALGBarButtonItem(kind: .done) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }

        rightBarButtonItems = [doneBarButtonItem]
    }
}

extension NotificationFilterViewController {
    private func setupAccountsCollectionViewLayout() {
        view.addSubview(accountsCollectionView)

        accountsCollectionView.snp.makeConstraints { make in
            make.top.safeEqualToTop(of: self)
            make.leading.trailing.bottom.equalToSuperview()
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
        SVProgressHUD.show(withStatus: "title-loading".localized)
        updateNotificationFilter(of: cell, with: value)
    }

    func notificationFilterDataSource(
        _ notificationFilterDataSource: NotificationFilterDataSource,
        didUpdateFilterValueFor account: Account
    ) {
        SVProgressHUD.showSuccess(withStatus: "title-done".localized)
        SVProgressHUD.dismiss()
        updateAccount(account)
        log(NotificationFilterChangeEvent(isReceivingNotifications: account.receivesNotification, address: account.address))
    }

    func notificationFilterDataSource(
        _ notificationFilterDataSource: NotificationFilterDataSource,
        didFailToUpdateFilterValueFor account: Account,
        with error: HIPAPIError?
    ) {
        SVProgressHUD.showError(withStatus: nil)
        SVProgressHUD.dismiss()
        NotificationBanner.showError("title-error".localized, message: error?.fallbackMessage ?? "transaction-filter-error-title".localized)
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
        if let cell = self.accountsCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? TitledToggleCell {
            cell.bind(TitledToggleViewModel())
        }
    }

    private func updateNotificationFilter(of cell: AccountNameSwitchCell, with value: Bool) {
        guard let indexPath = accountsCollectionView.indexPath(for: cell),
              let account = dataSource.account(at: indexPath.item) else {
            return
        }

        dataSource.updateNotificationFilter(for: account, to: value)
    }

    private func updateAccount(_ account: Account) {
        guard let localAccount = api?.session.accountInformation(from: account.address) else {
            return
        }

        localAccount.receivesNotification = account.receivesNotification
        api?.session.authenticatedUser?.updateAccount(localAccount)
        api?.session.updateAccount(account)
    }

    private func revertFilterSwitch(for account: Account) {
        guard let index = dataSource.index(of: account),
              let cell = accountsCollectionView.cellForItem(at: IndexPath(item: index, section: 1)) as? AccountNameSwitchCell else {
            return
        }
        
        cell.bind(AccountNameSwitchViewModel(account: account, isLastIndex: dataSource.isAtLastIndex(index)))
    }
}

extension NotificationFilterViewController {
    enum Flow {
        case notifications
        case settings
    }
}
