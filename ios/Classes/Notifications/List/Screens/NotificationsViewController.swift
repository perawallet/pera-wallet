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
//  NotificationsViewController.swift

import UIKit
import MagpieCore

final class NotificationsViewController: BaseViewController {
    private var isInitialFetchCompleted = false
    private lazy var isConnectedToInternet = api?.networkMonitor?.isConnected ?? true

    private lazy var notificationsView = NotificationsView()

    private lazy var dataSource = NotificationsDataSource(notificationsView.notificationsCollectionView)
    private lazy var dataController = NotificationsAPIDataController(
        sharedDataController: sharedDataController,
        api: api!
    )
    private lazy var listLayout = NotificationsListLayout(listDataSource: dataSource)

    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let snapshot):
                self.dataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
                self.notificationsView.endRefreshing()
            }
        }

        listLayout.handlers.willDisplay = { [weak self] cell, indexPath in
            guard let self = self else {
                return
            }

            if let loadingCell = cell as? NotificationLoadingCell {
                loadingCell.startAnimating()
                return
            }

            self.dataController.loadNextPageIfNeeded(for: indexPath)
        }

        listLayout.handlers.didSelectNotificationAt = { [weak self] indexPath in
            guard let self = self else {
                return
            }

            guard
                let notification = self.dataController.notifications[safe: indexPath.item],
                let notificationDetail = notification.detail
            else {
                return
            }

            self.openAssetDetail(from: notificationDetail)
        }

        dataController.load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isInitialFetchCompleted {
            reloadNotifications()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        notificationsView
            .notificationsCollectionView
            .visibleCells
            .forEach {
                let loadingCell = $0 as? NotificationLoadingCell
                loadingCell?.startAnimating()
            }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        notificationsView
            .notificationsCollectionView
            .visibleCells
            .forEach {
                let loadingCell = $0 as? NotificationLoadingCell
                loadingCell?.stopAnimating()
            }
    }
    
    override func setListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveNotification(notification:)),
            name: .NotificationDidReceived,
            object: nil
        )
    }
    
    override func linkInteractors() {
        notificationsView.delegate = self
        notificationsView.setDataSource(dataSource)
        notificationsView.setListDelegate(listLayout)
    }
    
    override func prepareLayout() {
        view.addSubview(notificationsView)
        notificationsView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.safeEqualToTop(of: self)
        }
    }
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        title = "notifications-title".localized
        addBarButtons()
    }
}

extension NotificationsViewController {
    private func addBarButtons() {
        let filterBarButtonItem = ALGBarButtonItem(kind: .filter) {
            [unowned self] in
            self.openNotificationFilters()
        }

        rightBarButtonItems = [filterBarButtonItem]
    }

    private func openNotificationFilters() {
        open(.notificationFilter(flow: .notifications), by: .present)
    }
}

extension NotificationsViewController {
    @objc
    private func didReceiveNotification(notification: Notification) {
        if isInitialFetchCompleted && isViewAppeared {
            reloadNotifications()
        }
    }

    private func openAssetDetail(from notificationDetail: NotificationDetail) {
        let accountDetails = dataController.getUserAccount(from: notificationDetail)
        if let account = accountDetails.account {
            guard let accountHandle = sharedDataController.accountCollection[account.address] else {
                return
            }

            let screen: Screen
            if let compoundAsset = accountDetails.compoundAsset {
                screen = .assetDetail(draft: AssetTransactionListing(accountHandle: accountHandle, compoundAsset: compoundAsset))
            } else {
                screen = .algosDetail(draft: AlgoTransactionListing(accountHandle: accountHandle))
            }

            open(screen, by: .push)
        }
    }
}

extension NotificationsViewController: NotificationsViewDelegate {
    func notificationsViewDidRefreshList(_ notificationsView: NotificationsView) {
        reloadNotifications()
    }
    
    func notificationsViewDidTryAgain(_ notificationsView: NotificationsView) {
        reloadNotifications()
    }
    
    private func reloadNotifications() {
        dataController.reload()
    }
}
