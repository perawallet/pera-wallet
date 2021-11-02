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
//  TransactionsViewController.swift

import UIKit
import Magpie
import SVProgressHUD

class TransactionsViewController: BaseViewController {
    
    let layout = Layout<LayoutConstants>()
    
    private var pendingTransactionPolling: PollingOperation?
    private var account: Account
    private var assetDetail: AssetDetail?
    private var isConnectedToInternet = true {
        didSet {
            if isConnectedToInternet {
                transactionListView.setInternetConnectionErrorState()
            } else {
                transactionListView.setNormalState()
            }
            transactionListView.reloadData()
        }
    }
    
    weak var delegate: TransactionsViewControllerDelegate?
    
    private let transactionsTooltipStorage = TransactionsTooltipStorage()
    private var filterOption = TransactionFilterViewController.FilterOption.allTime
    
    private lazy var filterOptionsPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: layout.current.filterOptionsModalHeight))
    )
    
    private var transactionHistoryDataSource: TransactionHistoryDataSource
    
    private lazy var transactionListView = TransactionListView()
    
    init(account: Account, configuration: ViewControllerConfiguration, assetDetail: AssetDetail? = nil) {
        self.account = account
        self.assetDetail = assetDetail
        transactionHistoryDataSource = TransactionHistoryDataSource(api: configuration.api, account: account, assetDetail: assetDetail)
        super.init(configuration: configuration)
    }
    
    deinit {
        pendingTransactionPolling?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionHistoryDataSource.setupContacts()
        fetchTransactions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        api?.addListener(self)
        startPendingTransactionPolling()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.presentFilterTooltipIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        api?.removeListener(self)
        pendingTransactionPolling?.invalidate()
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.secondary
    }
    
    override func setListeners() {
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
        
        transactionHistoryDataSource.openFilterOptionsHandler = { [weak self] _ -> Void in
            guard let filterOption = self?.filterOption else {
                return
            }
            let controller = self?.open(
                .transactionFilter(filterOption: filterOption),
                by: .customPresent(
                    presentationStyle: .custom,
                    transitionStyle: nil,
                    transitioningDelegate: self?.filterOptionsPresenter
                )
            ) as? TransactionFilterViewController
            
            controller?.delegate = self
        }
        
        transactionHistoryDataSource.shareHistoryHandler = { [weak self] _ -> Void in
            self?.fetchAllTransactionsForCSV()
        }
    }
    
    override func linkInteractors() {
        transactionListView.delegate = self
        transactionListView.setDelegate(self)
        transactionListView.setDataSource(transactionHistoryDataSource)
    }
    
    override func prepareLayout() {
        setupTransactionListViewLayout()
    }
}

extension TransactionsViewController: TransactionListViewDelegate {
    func transactionListViewDidRefreshList(_ transactionListView: TransactionListView) {
        reloadData()
    }
    
    func transactionListViewDidTryAgain(_ transactionListView: TransactionListView) {
        reloadData()
    }
    
    private func reloadData() {
        transactionHistoryDataSource.clear()
        transactionListView.reloadData()
        fetchTransactions()
    }
}

extension TransactionsViewController {
    private func startPendingTransactionPolling() {
        pendingTransactionPolling = PollingOperation(interval: 0.8) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.transactionHistoryDataSource.fetchPendingTransactions(for: strongSelf.account) { pendingTransactions, error in
                if error != nil {
                    return
                }
                
                guard let pendingTransactions = pendingTransactions, !pendingTransactions.isEmpty else {
                    return
                }
                
                strongSelf.transactionListView.setNormalState()
                strongSelf.transactionListView.reloadData()
            }
        }
        
        pendingTransactionPolling?.start()
    }
    
    private func fetchTransactions(witRefresh refresh: Bool = true, isPaginated: Bool = false) {
        transactionListView.setLoadingState()
        
        transactionHistoryDataSource.loadData(
            for: account,
            withRefresh: refresh,
            between: getTransactionFilterDates(),
            isPaginated: isPaginated
        ) { transactions, error in
            self.transactionListView.endRefreshing()
            
            if !self.isConnectedToInternet {
                self.transactionListView.setInternetConnectionErrorState()
                self.transactionListView.reloadData()
                return
            }
            
            if let error = error {
                if !error.isCancelled {
                    self.transactionListView.setOtherErrorState()
                }
                self.transactionListView.reloadData()
                return
            }
            
            guard let transactions = transactions else {
                self.transactionListView.setNormalState()
                return
            }
            
            if transactions.isEmpty {
                self.transactionListView.setEmptyState()
                return
            }
            
            self.transactionListView.setNormalState()
            self.transactionListView.reloadData()
        }
    }
    
    private func getTransactionFilterDates() -> (from: Date?, to: Date?) {
        switch filterOption {
        case .allTime:
            return (nil, nil)
        case .today:
            return (Date().dateAt(.startOfDay), Date().dateAt(.endOfDay))
        case .yesterday:
            let yesterday = Date().dateAt(.yesterday)
            let endOfYesterday = yesterday.dateAt(.endOfDay)
            return (yesterday, endOfYesterday)
        case .lastWeek:
            let prevOfLastWeek = Date().dateAt(.prevWeek)
            let endOfLastWeek = prevOfLastWeek.dateAt(.endOfWeek)
            return (prevOfLastWeek, endOfLastWeek)
        case .lastMonth:
            let prevOfLastMonth = Date().dateAt(.prevMonth)
            let endOfLastMonth = prevOfLastMonth.dateAt(.endOfMonth)
            return (prevOfLastMonth, endOfLastMonth)
        case let .customRange(from, to):
            return (from, to)
        }
    }
}

extension TransactionsViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.transactionsViewController(self, didScroll: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.transactionsViewController(self, didStopScrolling: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.transactionsViewController(self, didStopScrolling: scrollView)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if transactionHistoryDataSource.shouldSendPaginatedRequest(at: indexPath.item) {
            fetchTransactions(witRefresh: false, isPaginated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let transaction = transactionHistoryDataSource.transaction(at: indexPath) else {
            return
        }
        
        openTransactionDetail(transaction)
    }
    
    private func openTransactionDetail(_ transaction: Transaction) {
        if transaction.sender == account.address {
            open(
                .transactionDetail(
                    account: account,
                    transaction: transaction,
                    transactionType: .sent,
                    assetDetail: assetDetail
                ),
                by: .present
            )
        } else {
            open(
                .transactionDetail(
                    account: account,
                    transaction: transaction,
                    transactionType: .received,
                    assetDetail: assetDetail
                ),
                by: .present
            )
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return layout.current.transactionCellSize
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return layout.current.headerSize
    }
}

extension TransactionsViewController {
    private func setupTransactionListViewLayout() {
        view.addSubview(transactionListView)
        
        transactionListView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension TransactionsViewController {
    @objc
    private func didContactAdded(notification: Notification) {
        transactionHistoryDataSource.setupContacts()
        transactionListView.reloadData()
    }
    
    @objc
    private func didContactEdited(notification: Notification) {
        transactionHistoryDataSource.setupContacts()
        transactionListView.reloadData()
    }
}

extension TransactionsViewController {
    func updateList() {
        transactionHistoryDataSource.clear()
        transactionListView.reloadData()
        transactionListView.setLoadingState()
        fetchTransactions()
    }
    
    func updateSelectedAsset(_ assetDetail: AssetDetail?) {
        self.assetDetail = assetDetail
        transactionHistoryDataSource.updateAssetDetail(assetDetail)
        updateList()
    }
    
    var isTransactionListEmpty: Bool {
        return transactionHistoryDataSource.isEmpty
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
            pendingTransactionPolling?.start()
        case let .customRange(_, to):
            if let isToDateLaterThanNow = to?.isAfterDate(Date(), granularity: .day),
                isToDateLaterThanNow {
                pendingTransactionPolling?.invalidate()
            } else {
                pendingTransactionPolling?.start()
            }
        default:
            pendingTransactionPolling?.invalidate()
        }
        
        self.filterOption = filterOption
        if let headerView = transactionListView.headerView() {
            headerView.bind(TransactionHistoryHeaderViewModel(filterOption: filterOption))
        }
        updateList()
    }
}

extension TransactionsViewController: TooltipPresenter {
    func presentFilterTooltipIfNeeded() {
        if transactionsTooltipStorage.isFilterOptionTooltipDisplayed() || !isViewAppeared {
            return
        }
        
        guard let headerView = transactionListView.headerView() else {
            return
        }
        
        presentTooltip(with: "transaction-filter-tooltip".localized, using: configuration, at: headerView.contextView.filterButton)
        transactionsTooltipStorage.setFilterOptionTooltipDisplayed()
    }
    
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }
}

extension TransactionsViewController: CSVExportable {
    private func fetchAllTransactionsForCSV() {
        SVProgressHUD.show(withStatus: "csv-download-title".localized)
        
        transactionHistoryDataSource.fetchAllTransactions(
            for: account,
            between: getTransactionFilterDates(),
            nextToken: nil
        ) { transactions, error in
            if error != nil {
                SVProgressHUD.showError(withStatus: "csv-download-error".localized)
                SVProgressHUD.dismiss()
                return
            }
            
            guard let transactions = transactions else {
                SVProgressHUD.showError(withStatus: "csv-download-error".localized)
                SVProgressHUD.dismiss()
                return
            }
            
            self.shareCSVFile(for: transactions)
        }
    }
    
    private func shareCSVFile(for transactions: [Transaction]) {
        let keys: [String] = [
            "transaction-detail-amount".localized,
            "transaction-detail-reward".localized,
            "transaction-detail-close-amount".localized,
            "transaction-download-close-to".localized,
            "transaction-download-to".localized,
            "transaction-download-from".localized,
            "transaction-detail-fee".localized,
            "transaction-detail-round".localized,
            "transaction-detail-date".localized,
            "title-id".localized,
            "transaction-detail-note".localized
        ]
        let config = CSVConfig(fileName: formCSVFileName(), keys: NSOrderedSet(array: keys))
        
        if let fileUrl = exportCSV(from: createCSVData(from: transactions), with: config) {
            SVProgressHUD.showSuccess(withStatus: "title-done".localized)
            SVProgressHUD.dismiss()
            
            let activityViewController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
            activityViewController.completionWithItemsHandler = { _, _, _, _ in
                try? FileManager.default.removeItem(at: fileUrl)
            }
            present(activityViewController, animated: true)
        } else {
            SVProgressHUD.showError(withStatus: "csv-download-error".localized)
            SVProgressHUD.dismiss()
        }
    }
    
    private func formCSVFileName() -> String {
        var assetId = "algos"
        if let assetDetailId = assetDetail?.id {
            assetId = "\(assetDetailId)"
        }
        var fileName = "\(account.name ?? "")_\(assetId)"
        let dates = getTransactionFilterDates()
        if let fromDate = dates.from,
            let toDate = dates.to {
            if filterOption == .today {
                fileName += "-" + fromDate.toFormat("MM-dd-yyyy")
            } else {
                fileName += "-" + fromDate.toFormat("MM-dd-yyyy") + "_" + toDate.toFormat("MM-dd-yyyy")
            }
        }
        return "\(fileName).csv"
    }
    
    private func createCSVData(from transactions: [Transaction]) -> [[String: Any]] {
        var csvData = [[String: Any]]()
        for transaction in transactions {
            let transactionData: [String: Any] = [
                "transaction-detail-amount".localized: getFormattedAmount(transaction.getAmount()),
                "transaction-detail-reward".localized: transaction.getRewards(for: account.address)?.toAlgos ?? " ",
                "transaction-detail-close-amount".localized: getFormattedAmount(transaction.getCloseAmount()),
                "transaction-download-close-to".localized: transaction.getCloseAddress() ?? " ",
                "transaction-download-to".localized: transaction.getReceiver() ?? " ",
                "transaction-download-from".localized: transaction.sender ?? " ",
                "transaction-detail-fee".localized: transaction.fee?.toAlgos.toAlgosStringForLabel ?? " ",
                "transaction-detail-round".localized: transaction.lastRound ?? " ",
                "transaction-detail-date".localized: transaction.date?.toFormat("MMMM dd, yyyy - HH:mm") ?? " ",
                "title-id".localized: transaction.id ?? " ",
                "transaction-detail-note".localized: transaction.noteRepresentation() ?? " "
            ]
            csvData.append(transactionData)
        }
        return csvData
    }
    
    private func getFormattedAmount(_ amount: UInt64?) -> String {
        if let assetDetail = assetDetail {
            return amount?.toFractionStringForLabel(fraction: assetDetail.fractionDecimals) ?? " "
        } else {
            return amount?.toAlgos.toAlgosStringForLabel ?? " "
        }
    }
}

extension TransactionsViewController: APIListener {
    func api(
        _ api: API,
        networkMonitor: NetworkMonitor,
        didConnectVia connection: NetworkConnection,
        from oldConnection: NetworkConnection
    ) {
        if UIApplication.shared.isActive {
            isConnectedToInternet = networkMonitor.isConnected
        }
    }
    
    func api(_ api: API, networkMonitor: NetworkMonitor, didDisconnectFrom oldConnection: NetworkConnection) {
        if UIApplication.shared.isActive {
            isConnectedToInternet = networkMonitor.isConnected
        }
    }
}

extension TransactionsViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let transactionCellSize = CGSize(width: UIScreen.main.bounds.width, height: 72.0)
        let editAccountModalHeight: CGFloat = 158.0
        let headerSize = CGSize(width: UIScreen.main.bounds.width, height: 68.0)
        let filterOptionsModalHeight: CGFloat = 506.0
    }
}

protocol TransactionsViewControllerDelegate: AnyObject {
    func transactionsViewController(_ transactionsViewController: TransactionsViewController, didScroll scrollView: UIScrollView)
    func transactionsViewController(_ transactionsViewController: TransactionsViewController, didStopScrolling scrollView: UIScrollView)
}

private struct TransactionsTooltipStorage: Storable {
    typealias Object = Any
    
    private let filterOptionTooltipKey = "com.algorand.algorand.transaction.list.filter.option.tooltip"
    
    func setFilterOptionTooltipDisplayed() {
        save(true, for: filterOptionTooltipKey, to: .defaults)
    }
    
    func isFilterOptionTooltipDisplayed() -> Bool {
        return bool(with: filterOptionTooltipKey, to: .defaults)
    }
}
