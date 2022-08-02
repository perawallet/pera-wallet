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
//  TransactionsViewController.swift

import UIKit
import MagpieCore
import MacaroonUIKit

class TransactionsViewController: BaseViewController {
    private lazy var theme = Theme()
    private lazy var bottomSheetTransition = BottomSheetTransition(presentingViewController: self)
    private lazy var buyAlgoResultTransition = BottomSheetTransition(presentingViewController: self)

    private lazy var filterOptionsTransition = BottomSheetTransition(presentingViewController: self)

    private(set) var accountHandle: AccountHandle
    private(set) var asset: StandardAsset?
    private(set) var filterOption = TransactionFilterViewController.FilterOption.allTime

    lazy var csvTransactions = [Transaction]()

    private lazy var listLayout = TransactionsListLayout(
        draft: draft,
        transactionsDataSource: transactionsDataSource
    )

    private(set) lazy var dataController = TransactionsAPIDataController(
        api!,
        draft,
        filterOption,
        sharedDataController
    )

    private lazy var transactionsDataSource = TransactionsDataSource(listView)

    private(set) lazy var listView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        return collectionView
    }()

    private(set) var draft: TransactionListing

    private let copyToClipboardController: CopyToClipboardController?

    init(
        draft: TransactionListing,
        copyToClipboardController: CopyToClipboardController?,
        configuration: ViewControllerConfiguration
    ) {
        self.draft = draft
        self.accountHandle = draft.accountHandle
        self.asset = draft.asset
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }
    
    deinit {
        dataController.stopPendingTransactionPolling()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdateSnapshot(let snapshot):
                if let accountHandle = self.sharedDataController.accountCollection[self.accountHandle.value.address] {
                    self.accountHandle = accountHandle
                }

                self.transactionsDataSource.apply(
                    snapshot,
                    animatingDifferences: self.isViewAppeared
                )
            }
        }

        dataController.load()

        dataController.loadContacts()
        dataController.loadTransactions()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        listView.visibleCells.forEach { cell in
            switch cell {
            case is LoadingCell:
                let loadingCell = cell as! LoadingCell
                loadingCell.startAnimating()
            case is AlgoTransactionHistoryLoadingCell:
                let loadingCell = cell as! AlgoTransactionHistoryLoadingCell
                var theme = AlgoTransactionHistoryLoadingViewCommonTheme()
                theme.buyAlgoVisible = !accountHandle.value.isWatchAccount()
                loadingCell.contextView.customize(
                    theme
                )
                loadingCell.startAnimating()
            case is AssetTransactionHistoryLoadingCell:
                let loadingCell = cell as! AssetTransactionHistoryLoadingCell
                loadingCell.startAnimating()
            case is TransactionHistoryLoadingCell:
                let loadingCell = cell as! TransactionHistoryLoadingCell
                loadingCell.startAnimating()
            default:
                break
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        listView.visibleCells.forEach { cell in
            switch cell {
            case is LoadingCell:
                let loadingCell = cell as! LoadingCell
                loadingCell.stopAnimating()
            case is AlgoTransactionHistoryLoadingCell:
                let loadingCell = cell as! AlgoTransactionHistoryLoadingCell
                loadingCell.stopAnimating()
            case is AssetTransactionHistoryLoadingCell:
                let loadingCell = cell as! AssetTransactionHistoryLoadingCell
                loadingCell.stopAnimating()
            case is TransactionHistoryLoadingCell:
                let loadingCell = cell as! TransactionHistoryLoadingCell
                loadingCell.stopAnimating()
            default:
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataController.startPendingTransactionPolling()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataController.stopPendingTransactionPolling()
    }
    
    override func setListeners() {
        setNotificationObservers()
        setListLayoutListeners()
    }

    override func prepareLayout() {
        addListView()
    }

    override func linkInteractors() {
        listView.delegate = listLayout
    }
}

extension TransactionsViewController {
    private func addListView() {
        listView.contentInset = UIEdgeInsets(theme.contentInset)
        
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension TransactionsViewController {
    private func setNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactAdded(notification:)),
            name: .ContactAddition,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactEdited(notification:)),
            name: .ContactEdit,
            object: nil
        )
    }

    private func setListLayoutListeners() {
        listLayout.handlers.didSelect = { [weak self] indexPath in
            guard let self = self,
                  let itemIdentifier = self.transactionsDataSource.itemIdentifier(for: indexPath) else {
                return
            }

            switch itemIdentifier {
            case .algoTransaction(let item):
                if let transaction = self.dataController[item.id] {
                    self.openTransactionDetail(transaction)
                }
            case .assetTransaction(let item):
                if let transaction = self.dataController[item.id] {
                    self.openTransactionDetail(transaction)
                }
            case .appCallTransaction(let item):
                if let transaction = self.dataController[item.id] {
                    self.openTransactionDetail(transaction)
                }
            case .assetConfigTransaction(let item):
                if let transaction = self.dataController[item.id] {
                    self.openTransactionDetail(transaction)
                }
            default:
                break
            }
        }

        listLayout.handlers.willDisplay = { [weak self] cell, indexPath in
            guard let self = self else {
                return
            }

            if self.dataController.shouldSendPaginatedRequest(at: indexPath.item) {
                self.dataController.loadNextTransactions()
            }

            guard let itemIdentifier = self.transactionsDataSource.itemIdentifier(for: indexPath) else {
                return
            }

            switch itemIdentifier {
            case .nextList:
                let loadingCell = cell as! LoadingCell
                loadingCell.startAnimating()
            case .algosInfo:
                let infoCell = cell as! AlgosDetailInfoViewCell
                infoCell.delegate = self
            case .assetInfo:
                let infoCell = cell as! AssetDetailInfoViewCell
                infoCell.delegate = self
            case .filter:
                let filterCell = cell as! TransactionHistoryFilterCell
                filterCell.delegate = self
            case .empty(let emptyState):
                switch emptyState {
                case .algoTransactionHistoryLoading:
                    let loadingCell = cell as! AlgoTransactionHistoryLoadingCell
                    var theme = AlgoTransactionHistoryLoadingViewCommonTheme()
                    theme.buyAlgoVisible = !self.accountHandle.value.isWatchAccount()
                    loadingCell.contextView.customize(
                        theme
                    )
                    loadingCell.startAnimating()
                case .assetTransactionHistoryLoading:
                    let loadingCell = cell as! AssetTransactionHistoryLoadingCell
                    loadingCell.startAnimating()
                case .transactionHistoryLoading:
                    let loadingCell = cell as! TransactionHistoryLoadingCell
                    loadingCell.startAnimating()
                default:
                    break
                }
            case .pendingTransaction:
                let pendingCell = cell as! PendingTransactionCell
                pendingCell.startAnimating()
            default:
                break
            }
        }
    }
}

extension TransactionsViewController: AlgosDetailInfoViewCellDelegate {
    func algosDetailInfoViewCellDidTapInfoButton(_ algosDetailInfoViewCell: AlgosDetailInfoViewCell) {
        bottomSheetTransition.perform(
            .rewardDetail(
                account: accountHandle.value
            ),
            by: .presentWithoutNavigationController
        )
    }

    func algosDetailInfoViewCellDidTapBuyButton(_ algosDetailInfoViewCell: AlgosDetailInfoViewCell) {
        openBuyAlgo()
    }

    private func openBuyAlgo() {
        let draft = BuyAlgoDraft()
        draft.address = accountHandle.value.address
        
        launchBuyAlgo(draft: draft)
    }
}

extension TransactionsViewController: AssetDetailInfoViewCellDelegate {
    func contextMenuInteractionForAssetID(
        _ assetDetailInfoViewCell: AssetDetailInfoViewCell
    ) -> UIContextMenuConfiguration? {
        guard let asset = draft.asset else {
            return nil
        }

        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyAssetID) {
                [unowned self] _ in
                self.copyToClipboardController?.copyID(asset)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }
}

extension TransactionsViewController: TransactionHistoryFilterCellDelegate {
    func transactionHistoryFilterCellDidOpenFilterOptions(_ transactionHistoryFilterCell: TransactionHistoryFilterCell) {
        filterOptionsTransition.perform(
            .transactionFilter(filterOption: filterOption, delegate: self),
            by: .present
        )
    }

    func transactionHistoryFilterCellDidShareHistory(_ transactionHistoryFilterCell: TransactionHistoryFilterCell) {
        fetchAllTransactionsForCSV()
    }
}

extension TransactionsViewController {
    private func reloadData() {
        dataController.clear()
        dataController.loadTransactions()
    }
}

extension TransactionsViewController {
    private func openTransactionDetail(_ transaction: Transaction) {
        if transaction.applicationCall != nil {
            let eventHandler: AppCallTransactionDetailViewController.EventHandler = {
                [weak self] event in
                guard let self = self else {
                    return

                }

                switch event {
                case .performClose:
                    self.dismiss(animated: true)
                }
            }

            open(
                .appCallTransactionDetail(
                    account: accountHandle.value,
                    transaction: transaction,
                    transactionTypeFilter: draft.type,
                    assets: getAssetDetailForTransactionType(transaction),
                    eventHandler: eventHandler
                ),
                by: .present
            )

            return
        }
        
        open(
            .transactionDetail(
                account: accountHandle.value,
                transaction: transaction,
                assetDetail: getAssetDetailForTransactionType(transaction)?.first
            ),
            by: .present
        )
    }

    private func getAssetDetailForTransactionType(
        _ transaction: Transaction
    ) -> [StandardAsset]? {
        switch draft.type {
        case .all:
            let assetID =
            transaction.assetTransfer?.assetId ??
            transaction.assetFreeze?.assetId

            if let assetID = assetID,
                let decoration = sharedDataController.assetDetailCollection[assetID] {
                let standardAsset = StandardAsset(
                    asset: ALGAsset(id: assetID),
                    decoration: decoration
                )
                return [standardAsset]
            }

            if let applicationCall = transaction.applicationCall,
               let foreignAssets = applicationCall.foreignAssets {
                let assets: [StandardAsset] = foreignAssets.compactMap { ID in
                    if let decoration = sharedDataController.assetDetailCollection[ID] {
                        let standardAsset = StandardAsset(
                            asset: ALGAsset(id: ID),
                            decoration: decoration
                        )
                        return standardAsset
                    }
                    
                    return nil
                }
                
                return assets
            }

            return nil
        case .asset:
            guard let asset = draft.asset else {
                return nil
            }

            return [asset]
        case .algos:
            return nil
        }
    }
}

extension TransactionsViewController {
    @objc
    private func didContactAdded(notification: Notification) {
        dataController.loadContacts()
    }
    
    @objc
    private func didContactEdited(notification: Notification) {
        dataController.loadContacts()
    }
}

extension TransactionsViewController: TransactionFilterViewControllerDelegate {
    func transactionFilterViewController(
        _ transactionFilterViewController: TransactionFilterViewController,
        didSelect filterOption: TransactionFilterViewController.FilterOption
    ) {
        if self.filterOption == filterOption && !self.filterOption.isCustomRange() {
            return
        }
        
        switch filterOption {
        case .allTime:
            dataController.startPendingTransactionPolling()
        case let .customRange(_, to):
            if let isToDateLaterThanNow = to?.isAfterDate(Date(), granularity: .day),
               isToDateLaterThanNow {
                dataController.stopPendingTransactionPolling()
            } else {
                dataController.startPendingTransactionPolling()
            }
        default:
            dataController.startPendingTransactionPolling()
        }

        self.filterOption = filterOption
        dataController.updateFilterOption(filterOption)
        reloadData()
    }
}
