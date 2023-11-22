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
import MagpieExceptions
import MacaroonUIKit

class TransactionsViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
    private lazy var theme = Theme()

    private lazy var filterOptionsTransition = BottomSheetTransition(presentingViewController: self)

    private(set) var accountHandle: AccountHandle
    /// <todo>
    /// This should work with `Asset` type.
    private(set) var asset: Asset?
    private(set) var filterOption = TransactionFilterViewController.FilterOption.allTime

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

    lazy var transactionsDataSource = TransactionsDataSource(listView)

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
    }

    override func prepareLayout() {
        addListView()
    }

    override func linkInteractors() {
        listView.delegate = self
    }

    /// <mark>
    /// UICollectionViewDelegateFlowLayout
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }

    /// <mark>
    /// UICollectionViewDelegate
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if dataController.shouldSendPaginatedRequest(at: indexPath.item) {
            dataController.loadNextTransactions()
        }

        guard let itemIdentifier = transactionsDataSource.itemIdentifier(for: indexPath) else { return }

        switch itemIdentifier {
        case .nextList:
            let loadingCell = cell as! LoadingCell
            loadingCell.startAnimating()
        case .filter:
            let filterCell = cell as! TransactionHistoryFilterCell
            filterCell.delegate = self
        case .empty(let emptyState):
            switch emptyState {
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

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = transactionsDataSource.itemIdentifier(for: indexPath) else { return }

        switch itemIdentifier {
        case .nextList:
            let loadingCell = cell as! LoadingCell
            loadingCell.stopAnimating()
        case .empty(let emptyState):
            switch emptyState {
            case .transactionHistoryLoading:
                let loadingCell = cell as? TransactionHistoryLoadingCell
                loadingCell?.stopAnimating()
            default:
                break
            }
        case .pendingTransaction:
            guard let pendingTransactionCell = cell as? PendingTransactionCell else {
                return
            }

            pendingTransactionCell.stopAnimating()
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = transactionsDataSource.itemIdentifier(for: indexPath) else { return }

        switch itemIdentifier {
        case .algoTransaction(let item):
            if let transaction = dataController[item.id] {
                openTransactionDetail(transaction)
            }
        case .assetTransaction(let item):
            if let transaction = dataController[item.id] {
                openTransactionDetail(transaction)
            }
        case .appCallTransaction(let item):
            if let transaction = dataController[item.id] {
                openTransactionDetail(transaction)
            }
        case .assetConfigTransaction(let item):
            if let transaction = dataController[item.id] {
                openTransactionDetail(transaction)
            }
        case .keyRegTransaction(let item):
            if let transaction = dataController[item.id] {
                openTransactionDetail(transaction)
            }
        default:
            break
        }
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
}

extension TransactionsViewController: TransactionHistoryFilterCellDelegate {
    func transactionHistoryFilterCellDidOpenFilterOptions(_ transactionHistoryFilterCell: TransactionHistoryFilterCell) {

        analytics.track(.recordAccountDetailScreen(type: .tapTransactionFilter))

        filterOptionsTransition.perform(
            .transactionFilter(filterOption: filterOption, delegate: self),
            by: .present
        )
    }

    func transactionHistoryFilterCellDidShareHistory(_ transactionHistoryFilterCell: TransactionHistoryFilterCell) {
        loadingController?.startLoadingWithMessage("title-loading".localized)

        analytics.track(.recordAccountDetailScreen(type: .tapTransactionDownload))

        let dateRange = dataController.filterOption.getDateRanges()

        var exportDraft = ExportTransactionsDraft(account: draft.accountHandle.value)
        exportDraft.asset = draft.asset
        exportDraft.startDate = dateRange.from
        exportDraft.endDate = dateRange.to

        api?.exportTransactions(draft: exportDraft) {
            [weak self] result in
            guard let self else { return }

            self.loadingController?.stopLoading()

            switch result {
            case .success(let file):
                /// <note>
                /// It shouldn't be possible but it is handled since it is a friction.
                if file.isFault { return }

                self.open(
                    .shareActivity(items: [file.url]),
                    by: .presentWithoutNavigationController
                )
            case .failure(_, let errorModel):
                let title = "title-error".localized
                let message = errorModel?.message() ?? "title-generic-api-error".localized
                self.bannerController?.presentErrorBanner(
                    title: title,
                    message: message
                )
            }
        }
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
            open(
                .appCallTransactionDetail(
                    account: accountHandle.value,
                    transaction: transaction,
                    transactionTypeFilter: draft.type,
                    assets: getAssetDetailForTransactionType(transaction)
                ),
                by: .present
            )

            return
        }

        if transaction.keyRegTransaction != nil {
            open(
                .keyRegTransactionDetail(
                    account: accountHandle.value,
                    transaction: transaction
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
    ) -> [Asset]? {
        switch draft.type {
        case .all:
            let assetID =
            transaction.assetTransfer?.assetId ??
            transaction.assetFreeze?.assetId

            if let assetID = assetID,
                let decoration = sharedDataController.assetDetailCollection[assetID] {
                let asset: Asset

                if decoration.isCollectible {
                    asset = CollectibleAsset(
                        asset: ALGAsset(id: assetID),
                        decoration: decoration
                    )
                } else {
                    asset = StandardAsset(
                        asset: ALGAsset(id: assetID),
                        decoration: decoration
                    )
                }

                return [asset]
            }

            if let applicationCall = transaction.applicationCall,
               let foreignAssets = applicationCall.foreignAssets {
                let assets: [Asset] = foreignAssets.compactMap { ID in
                    if let decoration = sharedDataController.assetDetailCollection[ID] {
                        let asset: Asset

                        if decoration.isCollectible {
                            asset = CollectibleAsset(
                                asset: ALGAsset(id: ID),
                                decoration: decoration
                            )
                        } else {
                            asset = StandardAsset(
                                asset: ALGAsset(id: ID),
                                decoration: decoration
                            )
                        }

                        return asset
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
