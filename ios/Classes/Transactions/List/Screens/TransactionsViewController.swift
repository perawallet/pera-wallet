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
    private(set) var compoundAsset: CompoundAsset?
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

    private var rewardDetailViewController: RewardDetailViewController?

    private lazy var transactionsDataSource = TransactionsDataSource(listView)

    private(set) lazy var listView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        return collectionView
    }()

    private lazy var transactionActionButton = FloatingActionItemButton(hasTitleLabel: false)
    private(set) var draft: TransactionListing

    init(draft: TransactionListing, configuration: ViewControllerConfiguration) {
        self.draft = draft
        self.accountHandle = draft.accountHandle
        self.compoundAsset = draft.compoundAsset
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
            case .didUpdateReward(let reward):
                self.rewardDetailViewController?.bindData(
                    RewardDetailViewModel(
                        account: self.accountHandle.value,
                        calculatedRewards: reward
                    )
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
        transactionActionButton.addTarget(self, action: #selector(didTapTransactionActionButton), for: .touchUpInside)
    }

    override func prepareLayout() {
        addListView()

        if !accountHandle.value.isWatchAccount() {
            addTransactionActionButton(theme)
        }
    }

    override func linkInteractors() {
        listView.delegate = listLayout
    }
}

extension TransactionsViewController {
    private func addListView() {
        let isWatchAccount = accountHandle.value.isWatchAccount()
        listView.contentInset = isWatchAccount ? .zero : UIEdgeInsets(theme.contentInset)
        
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addTransactionActionButton(_ theme: Theme) {
        transactionActionButton.image = "fab-swap".uiImage
        
        view.addSubview(transactionActionButton)
        transactionActionButton.snp.makeConstraints {
            $0.setPaddings(theme.transactionActionButtonPaddings)
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
            case .transaction(let item):
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
                case .loading:
                    let loadingCell = cell as! LoadingCell
                    loadingCell.startAnimating()
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
            case .pending:
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
        let rewardDetailViewController = bottomSheetTransition.perform(
            .rewardDetail(
                account: accountHandle.value,
                calculatedRewards: dataController.reward
            ),
            by: .presentWithoutNavigationController,
            completion: {
                [weak self] in
                self?.rewardDetailViewController = nil
            }
        ) as? RewardDetailViewController

        self.rewardDetailViewController = rewardDetailViewController
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
    func assetDetailInfoViewCellDidTapAssetID(_ assetDetailInfoViewCell: AssetDetailInfoViewCell) {
        guard let assetID = draft.compoundAsset?.id else {
            return
        }

        bannerController?.presentInfoBanner("asset-id-copied-title".localized)
        UIPasteboard.general.string = "\(assetID)"
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
    @objc
    private func didTapTransactionActionButton() {
        let viewController = open(
            .transactionFloatingActionButton,
            by: .customPresentWithoutNavigationController(
                presentationStyle: .overCurrentContext,
                transitionStyle: nil,
                transitioningDelegate: nil
            ),
            animated: false
        ) as? TransactionFloatingActionButtonViewController

        viewController?.delegate = self
    }
}

extension TransactionsViewController: TransactionFloatingActionButtonViewControllerDelegate {
    func transactionFloatingActionButtonViewControllerDidSend(_ viewController: TransactionFloatingActionButtonViewController) {
        log(SendAssetDetailEvent(address: accountHandle.value.address))

        switch draft.type {
        case .all:
            let controller = open(.assetSelection(account: accountHandle.value), by: .present) as? SelectAssetViewController
            let closeBarButtonItem = ALGBarButtonItem(kind: .close) {
                controller?.closeScreen(by: .dismiss, animated: true)
            }
            controller?.leftBarButtonItems = [closeBarButtonItem]
        case .asset:
            if let compoundAsset = compoundAsset {
                let draft = SendTransactionDraft(from: accountHandle.value, transactionMode: .assetDetail(compoundAsset.detail))
                let controller = open(.sendTransaction(draft: draft), by: .present) as? SendTransactionScreen
                let closeBarButtonItem = ALGBarButtonItem(kind: .close) {
                    controller?.closeScreen(by: .dismiss, animated: true)
                }
                controller?.leftBarButtonItems = [closeBarButtonItem]
            }
        case .algos:
            let draft = SendTransactionDraft(from: accountHandle.value, transactionMode: .algo)
            let controller = open(.sendTransaction(draft: draft), by: .present) as? SendTransactionScreen
            let closeBarButtonItem = ALGBarButtonItem(kind: .close) {
                controller?.closeScreen(by: .dismiss, animated: true)
            }
            controller?.leftBarButtonItems = [closeBarButtonItem]
        }
    }

    func transactionFloatingActionButtonViewControllerDidReceive(_ viewController: TransactionFloatingActionButtonViewController) {
        log(ReceiveAssetDetailEvent(address: accountHandle.value.address))
        let draft = QRCreationDraft(address: accountHandle.value.address, mode: .address, title: accountHandle.value.name)
        open(.qrGenerator(title: accountHandle.value.name ?? accountHandle.value.address.shortAddressDisplay(), draft: draft, isTrackable: true), by: .present)
    }

    func transactionFloatingActionButtonViewControllerDidBuy(
        _ viewController: TransactionFloatingActionButtonViewController
    ) {
        openBuyAlgo()
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
        if transaction.sender == accountHandle.value.address {
            open(
                .transactionDetail(
                    account: accountHandle.value,
                    transaction: transaction,
                    transactionType: .sent,
                    assetDetail: getAssetDetailForTransactionType(transaction)
                ),
                by: .present
            )

            return
        }

        open(
            .transactionDetail(
                account: accountHandle.value,
                transaction: transaction,
                transactionType: .received,
                assetDetail: getAssetDetailForTransactionType(transaction)
            ),
            by: .present
        )
    }

    private func getAssetDetailForTransactionType(_ transaction: Transaction) -> AssetInformation? {
        switch draft.type {
        case .all:
            if let assetID = transaction.assetTransfer?.assetId {
                return sharedDataController.assetDetailCollection[assetID]
            }

            return nil
        case .asset:
            return compoundAsset?.detail
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
