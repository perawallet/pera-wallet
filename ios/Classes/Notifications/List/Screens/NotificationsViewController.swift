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

final class NotificationsViewController:
    BaseViewController,
    TransactionSignChecking,
    TransactionControllerDelegate {
    private var isInitialFetchCompleted = false
    private lazy var isConnectedToInternet = api?.networkMonitor?.isConnected ?? true

    private lazy var notificationsView = NotificationsView()

    private lazy var dataSource = NotificationsDataSource(notificationsView.notificationsCollectionView)
    private lazy var dataController = NotificationsAPIDataController(
        sharedDataController: sharedDataController,
        api: api!,
        currencyFormatter: currencyFormatter
    )
    private lazy var listLayout = NotificationsListLayout(listDataSource: dataSource)

    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(
            api: api,
            bannerController: bannerController,
            analytics: analytics
        )
    }()

    private lazy var transitionToOptInAsset = BottomSheetTransition(presentingViewController: self)

    private lazy var currencyFormatter = CurrencyFormatter()
    
    private var ledgerApprovalViewController: LedgerApprovalViewController?

    private var currentNotification: NotificationDetail?
    
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
            self.currentNotification = notificationDetail
        }

        dataController.load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isInitialFetchCompleted {
            reloadNotifications()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        transactionController.stopBLEScan()
        transactionController.stopTimer()
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
        transactionController.delegate = self

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

    private func openAssetDetail(from notificationDetail: NotificationDetail) {
        if notificationDetail.type == .assetSupportRequest {
            guard let receiverAccount = dataController.getReceiverAccount(from: notificationDetail),
                  let asset = notificationDetail.asset,
                  let assetId = asset.id
            else {
                return
            }

            if receiverAccount.isWatchAccount() {
                return
            }

            if dataController.canOptIn(
                to: assetId,
                for: receiverAccount
            ) {
                openOptInAsset(
                    asset: asset,
                    account: receiverAccount
                )
                return
            }

            displaySimpleAlertWith(title: "asset-you-already-own-message".localized)
            return
        }

        let accountDetails = dataController.getUserAccount(from: notificationDetail)

        if let account = accountDetails.account {
            guard let accountHandle = sharedDataController.accountCollection[account.address] else {
                return
            }

            let screen: Screen

            guard let assetMode = accountDetails.asset else {
                presentAssetNotFoundError()
                return
            }

            switch assetMode {
            case .algo:
                let account = accountHandle.value
                screen = .asaDetail(
                    account: account,
                    asset: account.algo
                ) { [weak self] event in
                    guard let self = self else { return }

                    switch event {
                    case .didRemoveAccount:
                        self.dataController.reload()
                        self.navigationController?.popToViewController(
                            self,
                            animated: true
                        )
                    case .didRenameAccount:
                        self.dataController.reload()
                    }
                }
            case .asset(let asset):
                if let asset = asset as? StandardAsset {
                    screen = .asaDetail(
                        account: accountHandle.value,
                        asset: asset
                    ) { [weak self] event in
                        guard let self = self else { return }

                        switch event {
                        case .didRemoveAccount:
                            self.dataController.reload()
                            self.navigationController?.popToViewController(
                                self,
                                animated: true
                            )
                        case .didRenameAccount:
                            self.dataController.reload()
                        }
                    }
                } else if let collectibleAsset = asset as? CollectibleAsset {
                    openCollectible(
                        asset: collectibleAsset,
                        with: accountHandle.value
                    )
                    return
                } else {
                    presentAssetNotFoundError()
                    return
                }
            }

            open(screen, by: .push)
        }
    }

    private func openOptInAsset(
        asset: NotificationAsset,
        account: Account
    ) {
        guard let assetID = asset.id else {
            return
        }

        if let asset = sharedDataController.assetDetailCollection[assetID] {
            openOptInAsset(
                asset: asset,
                account: account
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
                    self.openOptInAsset(
                        asset: asset,
                        account: account
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

    private func openOptInAsset(
        asset: AssetDecoration,
        account: Account
    ) {
        let draft = OptInAssetDraft(
            account: account,
            asset: asset
        )
        let screen = Screen.optInAsset(draft: draft) {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .performApprove:
                self.continueToOptInAsset(
                    asset: asset,
                    account: account
                )
            case .performClose:
                self.cancelOptInAsset()
            }
        }
        transitionToOptInAsset.perform(
            screen,
            by: .present
        )
    }
    
    private func openCollectible(
        asset: CollectibleAsset,
        with account: Account
    ) {
        let screen = Screen.collectibleDetail(
            asset: asset,
            account: account,
            thumbnailImage: nil,
            quickAction: nil
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
    
    private func presentAssetNotFoundError() {
        bannerController?.presentErrorBanner(
            title: "notifications-asset-not-found-title".localized,
            message: "notifications-asset-not-found-description".localized
        )
    }

    private func continueToOptInAsset(
        asset: AssetDecoration,
        account: Account
    ) {
        dismiss(animated: true) {
            [weak self] in
            guard let self = self else { return }

            var account = account

            if !self.canSignTransaction(for: &account) { return }

            let assetTransactionDraft = AssetTransactionSendDraft(
                from: account,
                assetIndex: asset.id
            )
            self.transactionController.setTransactionDraft(assetTransactionDraft)
            self.transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)

            self.loadingController?.startLoadingWithMessage("title-loading".localized)

            if account.requiresLedgerConnection() {
                self.transactionController.initializeLedgerTransactionAccount()
                self.transactionController.startTimer()
            }
        }
    }

    private func cancelOptInAsset() {
        dismiss(animated: true)
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        loadingController?.stopLoading()

        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            break
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedTransaction error: HIPTransactionError
    ) {
        loadingController?.stopLoading()

        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: apiError.debugDescription
            )
        default:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.localizedDescription
            )
        }
    }

    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            let amountText = currencyFormatter.format(amount.toAlgos)

            bannerController?.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(params: amountText.someString)
            )
        case .invalidAddress:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "send-algos-receiver-address-validation".localized
            )
        case let .sdkError(error):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.debugDescription
            )
        case .ledgerConnection:
            let bottomTransition = BottomSheetTransition(presentingViewController: self)

            bottomTransition.perform(
                .bottomWarning(
                    configurator: BottomWarningViewConfigurator(
                        image: "icon-info-green".uiImage,
                        title: "ledger-pairing-issue-error-title".localized,
                        description: .plain("ble-error-fail-ble-connection-repairing".localized),
                        secondaryActionButtonTitle: "title-ok".localized
                    )
                ),
                by: .presentWithoutNavigationController
            )
        default:
            break
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        loadingController?.stopLoading()

        guard let address = currentNotification?.receiverAddress,
              let assetId = currentNotification?.asset?.id else {
            return
        }

        dataController.addOptedInAsset(address, assetId)
    }

    func transactionController(
        _ transactionController: TransactionController,
        didRequestUserApprovalFrom ledger: String
    ) {
        let ledgerApprovalTransition = BottomSheetTransition(
            presentingViewController: self,
            interactable: false
        )
        ledgerApprovalViewController = ledgerApprovalTransition.perform(
            .ledgerApproval(
                mode: .approve,
                deviceName: ledger
            ),
            by: .present
        )

        ledgerApprovalViewController?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .didCancel:
                self.ledgerApprovalViewController?.dismissScreen()
                self.loadingController?.stopLoading()
            }
        }
    }

    func transactionControllerDidResetLedgerOperation(_ transactionController: TransactionController) {
        ledgerApprovalViewController?.dismissScreen()
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
