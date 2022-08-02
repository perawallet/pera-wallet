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
    AssetActionConfirmationViewControllerDelegate,
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
        return TransactionController(api: api, bannerController: bannerController)
    }()

    private lazy var assetActionConfirmationTransition = BottomSheetTransition(presentingViewController: self)

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
                openAssetAddition(
                    account: receiverAccount,
                    asset: asset
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
                screen = .algosDetail(draft: AlgoTransactionListing(accountHandle: accountHandle))
            case .asset(let asset):
                if let asset = asset as? StandardAsset {
                    screen = .assetDetail(draft: AssetTransactionListing(
                        accountHandle: accountHandle,
                        asset: asset
                    ))
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

    private func openAssetAddition(
        account: Account,
        asset: NotificationAsset
    ) {
        guard let assetId = asset.id else {
            return
        }

        let assetAlertDraft = AssetAlertDraft(
            account: account,
            assetId: assetId,
            asset: nil,
            transactionFee: Transaction.Constant.minimumFee,
            title: "asset-add-confirmation-title".localized,
            detail: "asset-add-warning".localized,
            actionTitle: "title-approve".localized,
            cancelTitle: "title-cancel".localized
        )

        assetActionConfirmationTransition.perform(
            .assetActionConfirmation(
                assetAlertDraft: assetAlertDraft,
                delegate: self
            ),
            by: .presentWithoutNavigationController
        )
    }
    
    private func openCollectible(asset: CollectibleAsset, with account: Account) {
        let controller = open(
            .collectibleDetail(
                asset: asset,
                account: account,
                thumbnailImage: nil
            ),
            by: .push
        ) as? CollectibleDetailViewController
        
        controller?.eventHandlers.didOptOutAssetFromAccount = { [weak controller] in
            controller?.popScreen()
        }
    }
    
    private func presentAssetNotFoundError() {
        bannerController?.presentErrorBanner(
            title: "notifications-asset-not-found-title".localized,
            message: "notifications-asset-not-found-description".localized
        )
    }

    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmAction asset: AssetDecoration
    ) {
        if let receiverAccount = dataController.getReceiverAccount(from: currentNotification) {
            var account = receiverAccount

            if !canSignTransaction(for: &account) {
                return
            }

            let assetTransactionDraft = AssetTransactionSendDraft(
                from: account,
                assetIndex: asset.id
            )
            transactionController.setTransactionDraft(assetTransactionDraft)
            transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)

            loadingController?.startLoadingWithMessage("title-loading".localized)

            if account.requiresLedgerConnection() {
                transactionController.initializeLedgerTransactionAccount()
                transactionController.startTimer()
            }
        }
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
        let ledgerApprovalTransition = BottomSheetTransition(presentingViewController: self)
        ledgerApprovalViewController = ledgerApprovalTransition.perform(
            .ledgerApproval(
                mode: .approve,
                deviceName: ledger
            ),
            by: .present
        )
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
