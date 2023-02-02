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
import MagpieHipo
import MagpieExceptions

final class AssetAdditionViewController:
    BaseViewController,
    TestNetTitleDisplayable,
    TransactionSignChecking,
    UICollectionViewDelegateFlowLayout {
    private lazy var theme = Theme()

    private lazy var transitionToOptInAsset = BottomSheetTransition(presentingViewController: self)

    private var ledgerApprovalViewController: LedgerApprovalViewController?

    private var optInTransactions: [AssetID: AssetOptInTransaction] = [:]

    private var transactionControllers: [TransactionController] {
        return Array(optInTransactions.values.map { $0.transactionController })
    }

    private lazy var dataSource = AssetListViewDataSource(assetListView.collectionView)
    private lazy var listLayout = AssetListViewLayout(listDataSource: dataSource)

    private lazy var assetSearchInput = SearchInputView()
    private lazy var assetListView = AssetListView()

    private lazy var currencyFormatter = CurrencyFormatter()

    private let dataController: AssetListViewDataController

    init(
        dataController: AssetListViewDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        title = "title-add-asset".localized
    }

    override func prepareLayout() {
        super.prepareLayout()

        addAssetSearchInput()
        addAssetList()
    }

    override func linkInteractors() {
        super.linkInteractors()

        assetSearchInput.delegate = self

        assetListView.collectionView.dataSource = dataSource
        assetListView.collectionView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else {
                return
            }

            switch event {
            case .didUpdate(let snapshot):
                if #available(iOS 15, *) {
                    self.dataSource.applySnapshotUsingReloadData(snapshot) {
                        [weak self] in
                        guard let self = self else { return }

                        self.assetListView.collectionView.scrollToTop(animated: true)
                    }
                } else {
                    self.dataSource.apply(
                        snapshot,
                        animatingDifferences: self.isViewAppeared
                    ) { [weak self] in
                        guard let self = self else { return }

                        self.assetListView.collectionView.scrollToTop(animated: true)
                    }
                }
            case .didUpdateNext(let snapshot):
                self.dataSource.apply(
                    snapshot,
                    animatingDifferences: self.isViewAppeared
                )
            case .didOptInAssets(let items):
                for item in items {
                    if let indexPath = self.dataSource.indexPath(for: .asset(item)),
                       let cell = self.assetListView.collectionView.cellForItem(at: indexPath) {
                        self.configureAccessory(
                            cell as? OptInAssetListItemCell,
                            for: item
                        )
                    }
                }
            }
        }

        dataController.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restartLoadingOfVisibleCellsIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        transactionControllers.forEach { controller in
            controller.stopBLEScan()
            controller.stopTimer()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        assetListView.collectionView.visibleCells.forEach {
            let loadingCell = $0 as? PreviewLoadingCell
            loadingCell?.stopAnimating()
        }
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
        let item = AssetListViewItem.asset(OptInAssetListItem(asset: asset))
        let indexPath = dataSource.indexPath(for: item)
        return indexPath.unwrap {
            assetListView.collectionView.cellForItem(at: $0)
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
        defer {
            dataController.loadNextPageIfNeeded(for: indexPath)
        }

        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .asset(let item):
            configureAccessory(
                cell as? OptInAssetListItemCell,
                for: item
            )
            linkInteractors(
                cell as? OptInAssetListItemCell,
                for: item
            )
        case .loading:
            let loadingCell = cell as? PreviewLoadingCell
            loadingCell?.startAnimating()
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .loading:
            let loadingCell = cell as? PreviewLoadingCell
            loadingCell?.stopAnimating()
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard case .asset(let item) = dataSource.itemIdentifier(for: indexPath) else { return }

        let asset = item.model

        if asset.isCollectible {
            let cell = collectionView.cellForItem(at: indexPath)
            let optInCell = cell as? OptInAssetListItemCell
            openCollectibleDetail(
                asset,
                from: optInCell
            )
        } else {
            let cell = collectionView.cellForItem(at: indexPath)
            let optInCell = cell as? OptInAssetListItemCell
            openASADiscovery(
                asset,
                from: optInCell
            )
        }
    }

    private func openCollectibleDetail(
        _ asset: AssetDecoration,
        from cell: OptInAssetListItemCell? = nil
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
                cell?.accessory = .loading
            }
        }
        open(
            screen,
            by: .push
        )
    }

    private func openASADiscovery(
        _ asset: AssetDecoration,
        from cell: OptInAssetListItemCell? = nil
    ) {
        let account = dataController.account
        let screen = Screen.asaDiscovery(
            account: account,
            quickAction: .optIn,
            asset: asset
        ) { event in
            switch event {
            case .didOptInToAsset:
                cell?.accessory = .loading
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
}

extension AssetAdditionViewController {
    private func addAssetSearchInput() {
        assetSearchInput.customize(theme.searchInputViewTheme)
        view.addSubview(assetSearchInput)
        assetSearchInput.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.searchInputTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.searchInputHorizontalPadding)
        }
    }

    private func addAssetList() {
        assetListView.customize(AssetListViewTheme())
        view.addSubview(assetListView)
        assetListView.snp.makeConstraints {
            $0.top.equalTo(assetSearchInput.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension AssetAdditionViewController {
    private func configureAccessory(
        _ cell: OptInAssetListItemCell?,
        for item: OptInAssetListItem
    ) {
        let asset = item.model
        let status = dataController.hasOptedIn(asset)

        let accessory: OptInAssetListItemAccessory
        switch status {
        case .pending: accessory = .loading
        case .optedIn: accessory = .check
        case .rejected: accessory = .add
        }

        cell?.accessory = accessory
    }
}

extension AssetAdditionViewController {
    private func linkInteractors(
        _ cell: OptInAssetListItemCell?,
        for item: OptInAssetListItem
    ) {
        cell?.startObserving(event: .add) {
            [unowned self] in

            let account = self.dataController.account
            let asset = item.model
            let draft = OptInAssetDraft(account: account, asset: asset)
            let screen = Screen.optInAsset(draft: draft) {
                [weak self] event in
                guard let self = self else { return }

                switch event {
                case .performApprove:
                    cell?.accessory = .loading
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

            var account = self.dataController.account

            if !self.canSignTransaction(for: &account) { return }

            let monitor = self.sharedDataController.blockchainUpdatesMonitor
            let request = OptInBlockchainRequest(account: account, asset: asset)
            monitor.startMonitoringOptInUpdates(request)

            let assetTransactionDraft = AssetTransactionSendDraft(from: account, assetIndex: asset.id)
            let transactionController = self.createNewTransactionController(for: asset)
            transactionController.setTransactionDraft(assetTransactionDraft)
            transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)

            if account.requiresLedgerConnection() {
                transactionController.initializeLedgerTransactionAccount()
                transactionController.startTimer()
            }
        }
    }

    private func cancelOptInAsset() {
        dismiss(animated: true)
    }
}

extension AssetAdditionViewController {
    private func restartLoadingOfVisibleCellsIfNeeded() {
        for cell in assetListView.collectionView.visibleCells {
            if let assetCell = cell as? OptInAssetListItemCell,
               assetCell.accessory == .loading {
                assetCell.accessory = .loading
            } else if let loadingCell = cell as? PreviewLoadingCell {
                loadingCell.startAnimating()
            }
        }
    }
}

extension AssetAdditionViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        let query = view.text
        dataController.search(for: query)
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}

extension AssetAdditionViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPTransactionError) {
        if let assetID = getAssetID(from: transactionController) {
            let monitor = self.sharedDataController.blockchainUpdatesMonitor
            let account = dataController.account
            monitor.finishMonitoringOptInUpdates(
                forAssetID: assetID,
                for: account
            )
        }

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
        if let assetID = getAssetID(from: transactionController) {
            let monitor = self.sharedDataController.blockchainUpdatesMonitor
            let account = dataController.account
            monitor.finishMonitoringOptInUpdates(
                forAssetID: assetID,
                for: account
            )
        }

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

    func transactionController(_ transactionController: TransactionController, didRequestUserApprovalFrom ledger: String) {
        let ledgerApprovalTransition = BottomSheetTransition(
            presentingViewController: self,
            interactable: false
        )
        ledgerApprovalViewController = ledgerApprovalTransition.perform(
            .ledgerApproval(mode: .approve, deviceName: ledger),
            by: .present
        )

        ledgerApprovalViewController?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .didCancel:
                self.ledgerApprovalViewController?.dismissScreen()
            }
        }
    }

    func transactionControllerDidResetLedgerOperation(_ transactionController: TransactionController) {
        ledgerApprovalViewController?.dismissScreen()
    }

    func transactionControllerDidRejectedLedgerOperation(
        _ transactionController: TransactionController
    ) {}
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
