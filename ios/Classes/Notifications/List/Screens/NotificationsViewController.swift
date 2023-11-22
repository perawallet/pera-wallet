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

    private lazy var notificationsView = NotificationsView()

    private lazy var dataSource = NotificationsDataSource(notificationsView.notificationsCollectionView)
    private lazy var dataController = NotificationsAPIDataController(
        api: api!,
        lastSeenNotificationController: lastSeenNotificationController
    )
    private lazy var listLayout = NotificationsListLayout(listDataSource: dataSource)

    private lazy var currencyFormatter = CurrencyFormatter()

    private lazy var deeplinkParser = DeepLinkParser(
        api: api!,
        sharedDataController: sharedDataController,
        peraConnect: peraConnect
    )

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

            guard let notification = self.dataController.notifications[safe: indexPath.item] else {
                return
            }

            let parserResult = self.deeplinkParser.discover(notification: notification)

            switch parserResult {
            case .success(let screen):
                switch screen {
                case let .asaDiscoveryWithOptInAction(account, assetID):
                    self.openASADiscoveryWithOptInAction(
                        account: account,
                        assetID: assetID
                    )
                case let .asaDiscoveryWithOptOutAction(account, asset):
                    self.openASADiscoveryWithOptOutAction(
                        account: account,
                        asset: asset
                    )
                case let .asaDetail(account, asset):
                    self.openASADetail(
                        account: account,
                        asset: asset
                    )
                case let .collectibleDetail(account, asset):
                    self.openCollectibleDetail(
                        account: account,
                        asset: asset
                    )
                case let .externalInAppBrowser(destination):
                    self.openExternalLink(destination: destination)
                default:
                    break
                }
            case .failure(let error):
                switch error {
                case .tryingToOptInForWatchAccount:
                    self.presentTryingToActForWatchAccountError()
                case .tryingToOptInForNoAuthInLocalAccount:
                    self.presentTryingToActForNoAuthInLocalAccountError()
                case .tryingToActForAssetWithPendingOptInRequest(let accountName):
                    self.presentTryingToActForAssetWithPendingOptInRequestError(accountName: accountName)
                case .tryingToActForAssetWithPendingOptOutRequest(let accountName):
                    self.presentTryingToActForAssetWithPendingOptOutRequestError(accountName: accountName)
                case .accountNotFound:
                    self.presentAccountNotFoundError()
                case .assetNotFound:
                    self.presentAssetNotFoundError()
                default:
                    break
                }
            case .none:
                break
            }
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
        open(.notificationFilter, by: .present)
    }
}

extension NotificationsViewController {
    @objc
    private func didReceiveNotification(notification: Notification) {
        if isInitialFetchCompleted && isViewAppeared {
            reloadNotifications()
        }
    }
}

extension NotificationsViewController {
    private func openASADiscoveryWithOptInAction(
        account: Account,
        assetID: AssetID
    ) {
        if let asset = sharedDataController.assetDetailCollection[assetID] {
            openASADiscoveryWithOptInAction(
                account: account,
                asset: asset
            )
            return
        }

        loadingController?.startLoadingWithMessage("title-loading".localized)

        api?.fetchAssetDetails(
            AssetFetchQuery(ids: [assetID]),
            queue: .main,
            ignoreResponseOnCancelled: false
        ) { [weak self] response in
            guard let self = self else {
                return
            }

            self.loadingController?.stopLoading()

            switch response {
            case let .success(assetResponse):
                if assetResponse.results.isEmpty {
                    self.bannerController?.presentErrorBanner(
                        title: "title-error".localized,
                        message: "asset-confirmation-not-found".localized
                    )
                    return
                }

                if let asset = assetResponse.results.first {
                    self.openASADiscoveryWithOptInAction(
                        account: account,
                        asset: asset
                    )
                }
            case .failure:
                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "asset-confirmation-not-fetched".localized
                )
            }
        }
    }

    private func openASADiscoveryWithOptInAction(
        account: Account,
        asset: AssetDecoration
    ) {
        let screen = Screen.asaDiscovery(
            account: account,
            quickAction: .optIn,
            asset: asset
        )

        open(
            screen,
            by: .present
        )
    }
}

extension NotificationsViewController {
    private func openASADiscoveryWithOptOutAction(
        account: Account,
        asset: AssetDecoration
    ) {
        let screen = Screen.asaDiscovery(
            account: account,
            quickAction: .optOut,
            asset: asset
        )

        open(
            screen,
            by: .present
        )
    }
}

extension NotificationsViewController {
    private func openASADetail(
        account: Account,
        asset: Asset
    ) {
        let screen = Screen.asaDetail(
            account: account,
            asset: asset
        )
        open(
            screen,
            by: .push
        )
    }
    
    private func openCollectibleDetail(
        account: Account,
        asset: CollectibleAsset
    ) {
        let screen = Screen.collectibleDetail(
            asset: asset,
            account: account
        ) { [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didOptOutAssetFromAccount: self.popScreen()
            case .didOptOutFromAssetWithQuickAction: break
            case .didOptInToAsset: break
            }
        }

        open(
            screen,
            by: .push
        )
    }

    private func openExternalLink(
        destination: DiscoverExternalDestination
    ) {
        open(.externalInAppBrowser(destination: destination), by: .push)
    }
}

extension NotificationsViewController {
    private func presentTryingToActForWatchAccountError() {
        bannerController?.presentErrorBanner(
            title: "notifications-trying-to-opt-in-for-watch-account-title".localized,
            message: "notifications-trying-to-opt-in-for-watch-account-description".localized
        )
    }

    private func presentTryingToActForNoAuthInLocalAccountError() {
        bannerController?.presentErrorBanner(
            title: "notifications-trying-to-opt-in-for-watch-account-title".localized,
            message: "action-not-available-for-account-type".localized
        )
    }

    private func presentTryingToActForAssetWithPendingOptInRequestError(accountName: String) {
        bannerController?.presentErrorBanner(
            title: "title-error".localized,
            message: "ongoing-opt-in-request-description".localized(params: accountName)
        )
    }

    private func presentTryingToActForAssetWithPendingOptOutRequestError(accountName: String) {
        bannerController?.presentErrorBanner(
            title: "title-error".localized,
            message: "ongoing-opt-out-request-description".localized(params: accountName)
        )
    }

    private func presentAccountNotFoundError() {
        bannerController?.presentErrorBanner(
            title: "notifications-account-not-found-title".localized,
            message: "notifications-account-not-found-description".localized
        )
    }

    private func presentAssetNotFoundError() {
        bannerController?.presentErrorBanner(
            title: "notifications-asset-not-found-title".localized,
            message: "notifications-asset-not-found-description".localized
        )
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
