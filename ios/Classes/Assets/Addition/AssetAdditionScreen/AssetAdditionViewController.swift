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
//  AssetAdditionViewController.swift

import UIKit
import MacaroonUIKit
import MagpieHipo
import MagpieExceptions

final class AssetAdditionViewController:
    BaseViewController,
    SearchInputViewDelegate,
    UICollectionViewDelegateFlowLayout {
    private lazy var searchInputView = SearchInputView()
    private lazy var searchInputBackgroundView = EffectView()
    private lazy var listView = UICollectionView(
        frame: .zero,
        collectionViewLayout: AssetListViewLayout.build()
    )

    private lazy var dataSource = AssetListViewDataSource(
        collectionView: listView,
        dataController: dataController
    )
    private lazy var listLayout = AssetListViewLayout(
        dataSource: dataSource,
        dataController: dataController
    )

    private lazy var currencyFormatter = CurrencyFormatter()
    
    private lazy var transitionToOptInAsset = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToLedgerConnectionIssuesWarning = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToLedgerConnection = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToSignWithLedgerProcess = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )

    private lazy var theme = Theme()

    private var isViewLayoutLoaded = false

    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?

    private var optInTransactions: [AssetID: AssetOptInTransaction] = [:]

    private var transactionControllers: [TransactionController] {
        return Array(optInTransactions.values.map { $0.transactionController })
    }

    private let dataController: AssetListViewDataController
    
    init(
        dataController: AssetListViewDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        super.init(configuration: configuration)

        startObservingDataUpdates()
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
        bindNavigationItemTitle()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty { return }

        if !isViewLayoutLoaded {
            loadInitialData()
            isViewLayoutLoaded = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimatingLoadingIfNeededWhenViewDidAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        transactionControllers.forEach { controller in
            controller.stopBLEScan()
            controller.stopTimer()
        }

        stopAnimatingLoadingIfNeededWhenViewDidDisappear()
    }
}

/// <mark>
/// SearchInputViewDelegate
extension AssetAdditionViewController {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        loadRequestedData()
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}

/// <mark>
/// UICollectionViewDelegateFlowLayout
extension AssetAdditionViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: section
        )
    }

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
}

/// <mark>
/// UICollectionViewDelegate
extension AssetAdditionViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else { return }

        switch itemIdentifier {
        case .loading:
            startAnimatingListLoadingIfNeeded(cell)
        case .loadingFailed:
            startObservingLoadingFailedEvents(cell)
        case .asset(let item):
            configureAssetAccessory(
                cell,
                for: item
            )
            startObservingAssetEvents(
                cell,
                for: item
            )
        case .loadingMore:
            startAnimatingLoadingMoreCellIfNeeded(cell)
        case .loadingMoreFailed:
            startObservingLoadingMoreFailedEvents(cell)
        default: break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else { return }

        switch itemIdentifier {
        case .loading:
            stopAnimatingListLoadingIfNeeded(cell)
        case .loadingMore:
            stopAnimatingLoadingMoreCellIfNeeded(cell)
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else { return }

        switch itemIdentifier {
        case .asset(let item):
            selectAsset(
                item,
                at: indexPath
            )
        default:
            break
        }
    }
}

/// <mark>
/// UIScrollViewDelegate
extension AssetAdditionViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let scrollHeight = scrollView.bounds.height

        if contentHeight <= scrollHeight ||
           contentHeight - scrollView.contentOffset.y < 2 * scrollHeight {
            loadMoreData()
        }
    }
}

extension AssetAdditionViewController {
    private func addBarButtons() {
        let infoBarButton = ALGBarButtonItem(kind: .info) {
            [unowned self] in
            let screen = Screen.asaVerificationInfo {
                [weak self] event in
                guard let self = self else { return }

                switch event {
                case .cancel:
                    self.dismiss(animated: true)
                }
            }
            self.open(
                screen,
                by: .present
            )
        }

        rightBarButtonItems = [infoBarButton]
    }
    
    private func bindNavigationItemTitle() {
        title = "title-add-asset".localized
    }
}

extension AssetAdditionViewController {
    private func addUI() {
        addBackground()
        addSearchInput()
        addList()
    }

    private func addBackground() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    private func addSearchInput() {
        searchInputView.customize(theme.searchInputTheme)
        
        view.addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top == theme.searchInputTopPadding
            $0.leading.trailing == theme.searchInputHorizontalPadding
        }
        
        searchInputView.delegate = self
        
        searchInputBackgroundView.effect = theme.searchInputBackground
        searchInputBackgroundView.isUserInteractionEnabled = false

        view.insertSubview(
            searchInputBackgroundView,
            belowSubview: searchInputView
        )
        searchInputBackgroundView.snp.makeConstraints {
            $0.fitToHeight(theme.searchInputBackgroundHeight)
            $0.top == searchInputView.snp.bottom
            $0.leading.trailing == 0
        }
    }
    
    private func addList() {
        view.insertSubview(
            listView,
            belowSubview: searchInputBackgroundView
        )
        listView.snp.makeConstraints {
            $0.top == searchInputView.snp.bottom
            $0.leading.trailing.bottom == 0
        }
        
        listView.backgroundColor = theme.listBackgroundColor.uiColor
        listView.showsVerticalScrollIndicator = false
        listView.showsHorizontalScrollIndicator = false
        listView.alwaysBounceVertical = true
        listView.keyboardDismissMode = .onDrag
        listView.delegate = self
    }
}

extension AssetAdditionViewController {
    private func configureAccessoryOfVisibleCells() {
        listView.indexPathsForVisibleItems.forEach {
            indexPath in
            guard let cell = listView.cellForItem(at: indexPath) else { return }
            guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else { return }
            guard case let OptInAssetList.ItemIdentifier.asset(item) = itemIdentifier else { return }

            configureAssetAccessory(
                cell,
                for: item
            )
        }
    }

    private func configureAssetAccessory(
        _ cell: UICollectionViewCell,
        for item: OptInAssetList.AssetItem
    ) {
        guard let asset: AssetDecoration = dataController[item.assetID] else { return }

        let accessory = determineAccessory(asset)
        let assetCell = cell as? OptInAssetListItemCell
        assetCell?.accessory = accessory
    }

    private func determineAccessory(_ asset: AssetDecoration) -> OptInAssetListItemAccessory {
        let status = dataController.hasOptedIn(asset)

        let accessory: OptInAssetListItemAccessory
        switch status {
        case .pending: accessory = .loading
        case .optedIn: accessory = .check
        case .rejected: accessory = .add
        }

        return accessory
    }
}

extension AssetAdditionViewController {
    private func startAnimatingLoadingIfNeededWhenViewDidAppear() {
        for cell in listView.visibleCells {
            if let assetCell = cell as? OptInAssetListItemCell,
               assetCell.accessory == .loading {
                assetCell.accessory = .loading
                break
            }

            if let listLoadingCell = cell as? OptInAssetListLoadingCell {
                listLoadingCell.startAnimating()
                break
            }

            if let loadingMoreCell = cell as? OptInAssetNextListLoadingCell {
                loadingMoreCell.startAnimating()
                break
            }
        }
    }

    private func startAnimatingListLoadingIfNeeded(_ cell: UICollectionViewCell) {
        let loadingCell = cell as? OptInAssetListLoadingCell
        loadingCell?.startAnimating()
    }

    private func startAnimatingLoadingMoreCellIfNeeded(_ cell: UICollectionViewCell) {
        let loadingCell = cell as? OptInAssetNextListLoadingCell
        loadingCell?.startAnimating()
    }

    private func stopAnimatingLoadingIfNeededWhenViewDidDisappear() {
        for cell in listView.visibleCells {
            if let listLoadingCell = cell as? OptInAssetListLoadingCell {
                listLoadingCell.stopAnimating()
                break
            }

            if let loadingMoreCell = cell as? OptInAssetNextListLoadingCell {
                loadingMoreCell.stopAnimating()
                break
            }
        }
    }

    private func stopAnimatingListLoadingIfNeeded(_ cell: UICollectionViewCell) {
        let loadingCell = cell as? OptInAssetListLoadingCell
        loadingCell?.stopAnimating()
    }

    private func stopAnimatingLoadingMoreCellIfNeeded(_ cell: UICollectionViewCell?) {
        let loadingCell = cell as? OptInAssetNextListLoadingCell
        loadingCell?.stopAnimating()
    }
}

extension AssetAdditionViewController {
    private func startObservingLoadingFailedEvents(_ cell: UICollectionViewCell) {
        let failedCell = cell as? NoContentWithActionCell
        failedCell?.startObserving(event: .performPrimaryAction) {
            [unowned self] in
            self.loadRequestedData()
        }
    }

    private func startObservingAssetEvents(
        _ cell: UICollectionViewCell,
        for item: OptInAssetList.AssetItem
    ) {
        let assetCell = cell as? OptInAssetListItemCell
        assetCell?.startObserving(event: .add) {
            [unowned self, weak assetCell] in
            guard let asset: AssetDecoration = self.dataController[item.assetID] else { return }

            let account = self.dataController.account
            let draft = OptInAssetDraft(account: account, asset: asset)
            let screen = Screen.optInAsset(draft: draft) {
                [weak self] event in
                guard let self = self else { return }

                switch event {
                case .performApprove:
                    assetCell?.accessory = .loading
                    self.continueToOptInAsset(asset: asset)
                case .performClose:
                    self.cancelOptInAsset()
                }
            }
            self.transitionToOptInAsset.perform(
                screen,
                by: .present
            )
        }
    }

    private func continueToOptInAsset(asset: AssetDecoration) {
        dismiss(animated: true) {
            [weak self] in
            guard let self = self else { return }

            let account = self.dataController.account
            let transactionController = self.createNewTransactionController(for: asset)

            if !transactionController.canSignTransaction(for: account) {
                self.clearTransactionCache(transactionController)
                self.restoreCellState(for: transactionController)
                return
            }

            let monitor = self.sharedDataController.blockchainUpdatesMonitor
            let request = OptInBlockchainRequest(account: account, asset: asset)
            monitor.startMonitoringOptInUpdates(request)

            let assetTransactionDraft = AssetTransactionSendDraft(from: account, assetIndex: asset.id)
            transactionController.setTransactionDraft(assetTransactionDraft)
            transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)

            if account.requiresLedgerConnection() {
                self.openLedgerConnection(transactionController)

                transactionController.initializeLedgerTransactionAccount()
                transactionController.startTimer()
            }
        }
    }

    private func cancelOptInAsset() {
        dismiss(animated: true)
    }

    private func startObservingLoadingMoreFailedEvents(_ cell: UICollectionViewCell) {
        let failedCell = cell as? NoContentWithActionCell
        failedCell?.startObserving(event: .performPrimaryAction) {
            [unowned self] in
            self.loadMoreDataAgain()
        }
    }
}

extension AssetAdditionViewController {
    private func startObservingDataUpdates() {
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdateAccount:
                self.configureAccessoryOfVisibleCells()
            case .didReload(let snapshot):
                self.dataSource.reload(
                    snapshot,
                    animatingDifferences: self.isViewAppeared
                ) { [weak self] in
                    guard let self = self else { return }

                    self.listView.scrollToTop(animated: false)
                }
            case .didUpdate(let snapshot):
                self.dataSource.apply(
                    snapshot,
                    animatingDifferences: self.isViewAppeared
                )
            }
        }
    }

    private func loadInitialData() {
        dataController.load(query: nil)
    }

    private func loadRequestedData() {
        let keyword = searchInputView.text
        let query = keyword.unwrap(OptInAssetListQuery.init)
        dataController.load(query: query)
    }

    private func loadMoreData() {
        dataController.loadMore()
    }

    private func loadMoreDataAgain() {
        dataController.loadMoreAgain()
    }
}

extension AssetAdditionViewController {
    private func selectAsset(
        _ item: OptInAssetList.AssetItem,
        at indexPath: IndexPath
    ) {
        guard let asset: AssetDecoration = dataController[item.assetID] else { return }

        let cell = listView.cellForItem(at: indexPath)

        if asset.isCollectible {
            openCollectibleDetail(
                asset,
                from: cell
            )
        } else {
            openASADiscovery(
                asset,
                from: cell
            )
        }
    }

    private func openCollectibleDetail(
        _ asset: AssetDecoration,
        from cell: UICollectionViewCell? = nil
    ) {
        let account = dataController.account
        let collectibleAsset = CollectibleAsset(
            asset: ALGAsset(id: asset.id),
            decoration: asset
        )
        let screen = Screen.collectibleDetail(
            asset: collectibleAsset,
            account: account,
            quickAction: .optIn
        ) { event in
            switch event {
            case .didOptOutAssetFromAccount:
                break
            case .didOptOutFromAssetWithQuickAction:
                break
            case .didOptInToAsset:
                let assetCell = cell as? OptInAssetListItemCell
                assetCell?.accessory = .loading
            }
        }
        open(
            screen,
            by: .push
        )
    }

    private func openASADiscovery(
        _ asset: AssetDecoration,
        from cell: UICollectionViewCell? = nil
    ) {
        let account = dataController.account
        let screen = Screen.asaDiscovery(
            account: account,
            quickAction: .optIn,
            asset: asset
        ) { event in
            switch event {
            case .didOptInToAsset:
                let assetCell = cell as? OptInAssetListItemCell
                assetCell?.accessory = .loading
            case .didOptOutFromAsset:
                break
            }
        }
        open(
            screen,
            by: .push
        )
    }
}

extension AssetAdditionViewController {
    private func createNewTransactionController(
        for asset: AssetDecoration
    ) -> TransactionController {
        let transactionController = TransactionController(
            api: api!,
            sharedDataController: sharedDataController,
            bannerController: bannerController,
            analytics: analytics
        )
        optInTransactions[asset.id] = AssetOptInTransaction(
            asset: asset,
            transactionController: transactionController
        )
        transactionController.delegate = self
        return transactionController
    }

    private func clearTransactionCache(
        _ transactionController: TransactionController
    ) {
        if let assetID = getAssetID(from: transactionController) {
            optInTransactions[assetID] = nil
        }
    }

    private func getAssetID(
        from transactionController: TransactionController
    ) -> AssetID? {
        return transactionController.assetTransactionDraft?.assetIndex
    }

    private func findCell(
        from asset: AssetDecoration
    ) -> OptInAssetListItemCell?  {
        let item = OptInAssetList.AssetItem(assetID: asset.id)
        let itemIdentifier = OptInAssetList.ItemIdentifier.asset(item)
        let indexPath = dataSource.indexPath(for: itemIdentifier)
        return indexPath.unwrap {
            listView.cellForItem(at: $0)
        } as? OptInAssetListItemCell
    }

    private func restoreCellState(
        for transactionController: TransactionController
    ) {
        if let assetID = getAssetID(from: transactionController),
           let assetDetail = optInTransactions[assetID]?.asset,
           let cell = findCell(from: assetDetail) {
            cell.accessory = .add
        }
    }
}

extension AssetAdditionViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPTransactionError) {
        cancelMonitoringOptInUpdates(for: transactionController)
        restoreCellState(for: transactionController)
        clearTransactionCache(transactionController)

        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        case let .network(apiError):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: apiError.debugDescription
            )
        }
    }

    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPTransactionError) {
        cancelMonitoringOptInUpdates(for: transactionController)
        restoreCellState(for: transactionController)
        clearTransactionCache(transactionController)

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

    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        if let assetID = getAssetID(from: transactionController),
           let asset = optInTransactions[assetID]?.asset,
           asset.isCollectible  {
            NotificationCenter.default.post(
                name: CollectibleListLocalDataController.didAddCollectible,
                object: self
            )
        }

        clearTransactionCache(transactionController)
    }

    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let amountText = currencyFormatter.format(amount.toAlgos)

            bannerController?.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(
                    params: amountText.someString
                )
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
            ledgerConnectionScreen?.dismiss(animated: true) {
                self.ledgerConnectionScreen = nil

                self.openLedgerConnectionIssues()
            }
        default:
            break
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didRequestUserApprovalFrom ledger: String
    ) {
        ledgerConnectionScreen?.dismiss(animated: true) {
            self.ledgerConnectionScreen = nil

            self.openSignWithLedgerProcess(
                transactionController: transactionController,
                ledgerDeviceName: ledger
            )
        }
    }

    func transactionControllerDidResetLedgerOperation(_ transactionController: TransactionController) {
        ledgerConnectionScreen?.dismissScreen()
        ledgerConnectionScreen = nil

        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil

        cancelMonitoringOptInUpdates(for: transactionController)
        restoreCellState(for: transactionController)
    }

    func transactionControllerDidResetLedgerOperationOnSuccess(_ transactionController: TransactionController) {
        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil
    }

    private func cancelMonitoringOptInUpdates(for transactionController: TransactionController) {
        if let assetID = getAssetID(from: transactionController) {
            let monitor = sharedDataController.blockchainUpdatesMonitor
            let account = dataController.account
            monitor.cancelMonitoringOptInUpdates(
                forAssetID: assetID,
                for: account
            )
        }
    }
}

extension AssetAdditionViewController {
    private func openSignWithLedgerProcess(
        transactionController: TransactionController,
        ledgerDeviceName: String
    ) {
        let draft = SignWithLedgerProcessDraft(
            ledgerDeviceName: ledgerDeviceName,
            totalTransactionCount: 1
        )
        let eventHandler: SignWithLedgerProcessScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .performCancelApproval:
                transactionController.stopBLEScan()
                transactionController.stopTimer()

                self.signWithLedgerProcessScreen?.dismissScreen()
                self.signWithLedgerProcessScreen = nil

                self.cancelMonitoringOptInUpdates(for: transactionController)
                self.restoreCellState(for: transactionController)
                self.clearTransactionCache(transactionController)
            }
        }
        signWithLedgerProcessScreen = transitionToSignWithLedgerProcess.perform(
            .signWithLedgerProcess(
                draft: draft,
                eventHandler: eventHandler
            ),
            by: .present
        ) as? SignWithLedgerProcessScreen
    }
}

extension AssetAdditionViewController {
    private func openLedgerConnection(_ transactionController: TransactionController) {
        let eventHandler: LedgerConnectionScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancel:
                transactionController.stopBLEScan()
                transactionController.stopTimer()
                self.cancelMonitoringOptInUpdates(for: transactionController)
                self.restoreCellState(for: transactionController)
                self.clearTransactionCache(transactionController)

                self.ledgerConnectionScreen?.dismissScreen()
                self.ledgerConnectionScreen = nil

                self.loadingController?.stopLoading()
            }
        }

        ledgerConnectionScreen = transitionToLedgerConnection.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }
}

extension AssetAdditionViewController {
    private func openLedgerConnectionIssues() {
        transitionToLedgerConnectionIssuesWarning.perform(
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
    }
}

struct AssetOptInTransaction: Equatable {
    let asset: AssetDecoration
    let transactionController: TransactionController

    static func == (
        lhs: AssetOptInTransaction,
        rhs: AssetOptInTransaction
    ) -> Bool {
        return lhs.asset.id == rhs.asset.id
    }
}
