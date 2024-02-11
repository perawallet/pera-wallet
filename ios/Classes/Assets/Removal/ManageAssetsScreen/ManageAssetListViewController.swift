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
//  ManageAssetListViewController.swift

import UIKit
import MacaroonUIKit
import MagpieHipo

final class ManageAssetListViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
    private lazy var theme = Theme()
    
    private lazy var listLayout = ManageAssetListLayout(dataSource)
    private lazy var dataSource = ManageAssetListDataSource(listView)

    private lazy var transitionToOptOutAsset = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToTransferAssetBalance = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToLedgerConnection = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToLedgerConnectionIssuesWarning = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToSignWithLedgerProcess = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )

    private lazy var titleView = UILabel()
    private lazy var subtitleView = UILabel()
    private lazy var searchInputView = SearchInputView()
    private lazy var searchInputBackgroundView: EffectView = .init()
    private lazy var listView = UICollectionView(
        frame: .zero,
        collectionViewLayout: ManageAssetListLayout.build()
    )
    
    private var account: Account {
        return dataController.account
    }

    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?
    
    private var optOutTransactions: [AssetID: AssetOptOutTransaction] = [:]

    private var transactionControllers: [TransactionController] {
        return Array(optOutTransactions.values.map { $0.transactionController })
    }

    private lazy var currencyFormatter = CurrencyFormatter()
    private lazy var collectibleAmountFormatter = CollectibleAmountFormatter()

    private var query: ManageAssetListQuery
    private let dataController: ManageAssetListDataController

    init(
        query: ManageAssetListQuery,
        dataController: ManageAssetListDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.query = query
        self.dataController = dataController
        
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addUI()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let update):
                self.dataSource.apply(
                    update.snapshot,
                    animatingDifferences: self.isViewAppeared
                )
            }
        }
        
        dataController.load(query: query)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startAnimatingLoadingIfNeededWhenViewWillAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        transactionControllers.forEach { controller in
            controller.stopBLEScan()
            controller.stopTimer()

            cancelMonitoringOptOutUpdates(for: controller)
        }

        stopAnimatingLoadingIfNeededWhenViewDidDisappear()
    }
    
    private func addUI() {
        addBackground()
        addTitle()
        addSubtitle()
        addSearchInput()
        addList()
    }
}

extension ManageAssetListViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }
    
    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        view.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.leading.trailing == theme.horizontalPadding
            $0.top == theme.titleTopPadding
        }
    }
    
    private func addSubtitle() {
        subtitleView.customizeAppearance(theme.subtitle)
        subtitleView.editText = theme.subtitleText
        
        view.addSubview(subtitleView)
        subtitleView.snp.makeConstraints {
            $0.leading.trailing == theme.horizontalPadding
            $0.top == titleView.snp.bottom + theme.subtitleTopPadding
        }
    }
    
    private func addSearchInput() {
        searchInputView.customize(theme.searchInputTheme)
        
        view.addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top == subtitleView.snp.bottom + theme.searchInputTopPadding
            $0.leading.trailing == theme.horizontalPadding
        }
        
        searchInputView.delegate = self
        
        searchInputBackgroundView.effect = theme.searchInputBackground
        searchInputBackgroundView.isUserInteractionEnabled = false

        view.insertSubview(
            searchInputBackgroundView,
            belowSubview: searchInputView
        )
        searchInputBackgroundView.snp.makeConstraints {
            $0.fitToHeight(theme.spacingBetweenSearchInputAndSearchInputBackground)
            $0.top == searchInputView.snp.bottom
            $0.leading.trailing == 0
        }
    }
    
    private func addList() {
        listView.customizeBaseAppearance(backgroundColor: theme.listViewBackgroundColor)
        
        view.insertSubview(
            listView,
            belowSubview: searchInputBackgroundView
        )
        listView.snp.makeConstraints {
            $0.top == searchInputView.snp.bottom
            $0.leading.trailing.bottom == 0
        }
        
        listView.showsVerticalScrollIndicator = false
        listView.showsHorizontalScrollIndicator = false
        listView.alwaysBounceVertical = true
        listView.keyboardDismissMode = .onDrag
        listView.delegate = self
    }
}

/// <mark>
/// UICollectionViewDelegateFlowLayout
extension ManageAssetListViewController {
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
extension ManageAssetListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = self.dataSource.itemIdentifier(for: indexPath) else { return }

        switch itemIdentifier {
        case .asset(let item):
            configureAccessory(
                cell as? OptOutAssetListItemCell,
                for: item
            )
            linkInteractors(
                cell as? OptOutAssetListItemCell,
                for: item
            )
        case .collectibleAsset(let item):
            configureAccessory(
                cell as? OptOutCollectibleAssetListItemCell,
                for: item
            )
            linkInteractors(
                cell as? OptOutCollectibleAssetListItemCell,
                for: item
            )
        case .assetLoading:
            startAnimatingLoadingCellIfNeeded(cell as? ManageAssetListLoadingCell)
        default:
            break
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = self.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch itemIdentifier {
        case .assetLoading:
            stopAnimatingLoadingCellIfNeeded(cell as? ManageAssetListLoadingCell)
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let itemIdentifier = dataSource.itemIdentifier(for: indexPath)

        if case .collectibleAsset(let item) = itemIdentifier {
            let cell = collectionView.cellForItem(at: indexPath)
            let optOutCell = cell as? OptOutCollectibleAssetListItemCell
            let asset = item.model
            openCollectibleDetail(
                asset,
                from: optOutCell
            )
            return
        }

        if case .asset(let item) = itemIdentifier {
            let cell = collectionView.cellForItem(at: indexPath)
            let optOutCell = cell as? OptOutAssetListItemCell
            let assetDetail = AssetDecoration(asset: item.model)
            openASADiscovery(
                assetDetail,
                from: optOutCell
            )
            return
        }
    }
}

extension ManageAssetListViewController {
    private func openCollectibleDetail(
        _ asset: CollectibleAsset,
        from cell: OptOutCollectibleAssetListItemCell? = nil
    ) {
        let screen = Screen.collectibleDetail(
            asset: asset,
            account: account,
            quickAction: .optOut
        ) { event in
            switch event {
            case .didOptOutAssetFromAccount: break
            case .didOptOutFromAssetWithQuickAction:
                cell?.accessory = .loading
            case .didOptInToAsset: break
            }
        }

        open(
            screen,
            by: .push
        )
    }

    private func openASADiscovery(
        _ asset: AssetDecoration,
        from cell: OptOutAssetListItemCell? = nil
    ) {
        let screen = Screen.asaDiscovery(
            account: account,
            quickAction: .optOut,
            asset: asset
        ) { event in
            switch event {
            case .didOptInToAsset: break
            case .didOptOutFromAsset:
                cell?.accessory = .loading
            }
        }
        open(
            screen,
            by: .push
        )
    }
}

extension ManageAssetListViewController {
    private func createNewTransactionController(
        for asset: Asset
    ) -> TransactionController {
        let transactionController = TransactionController(
            api: api!,
            sharedDataController: sharedDataController,
            bannerController: bannerController,
            analytics: analytics
        )
        optOutTransactions[asset.id] = AssetOptOutTransaction(
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
            optOutTransactions[assetID] = nil
        }
    }

    private func getAssetID(
        from transactionController: TransactionController
    ) -> AssetID? {
        return transactionController.assetTransactionDraft?.assetIndex
    }

    private func findCell(
        from asset: StandardAsset
    ) -> OptOutAssetListItemCell?  {
        let assetItem = AssetItem(
            asset: asset,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
        let optOutAssetListItem = OptOutAssetListItem(item: assetItem)
        let listItem = ManageAssetListItem.asset(optOutAssetListItem)
        let indexPath = dataSource.indexPath(for: listItem)

        return indexPath.unwrap {
            listView.cellForItem(at: $0)
        } as? OptOutAssetListItemCell
    }

    private func findCell(
        from asset: CollectibleAsset
    ) -> OptOutCollectibleAssetListItemCell?  {
        let collectibleAssetItem = CollectibleAssetItem(
            account: account,
            asset: asset,
            amountFormatter: collectibleAmountFormatter
        )
        let optOutCollectibleAssetListItem = OptOutCollectibleAssetListItem(item: collectibleAssetItem)
        let listItem = ManageAssetListItem.collectibleAsset(optOutCollectibleAssetListItem)
        let indexPath = dataSource.indexPath(for: listItem)

        return indexPath.unwrap {
            listView.cellForItem(at: $0)
        } as? OptOutCollectibleAssetListItemCell
    }

    private func restoreCellState(
        for transactionController: TransactionController
    ) {
        if let assetID = getAssetID(from: transactionController),
           let asset = optOutTransactions[assetID]?.asset {

            if let asset = asset as? StandardAsset,
               let assetCell = findCell(from: asset) {
                assetCell.accessory = .remove
                return
            }

            if let collectibleAsset = asset as? CollectibleAsset,
               let collectibleAssetCell = findCell(from: collectibleAsset) {
                collectibleAssetCell.accessory = .remove
                return
            }
        }
    }
}

extension ManageAssetListViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        query.keyword = view.text
        dataController.load(query: query)
    }
    
    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}

extension ManageAssetListViewController {
    private func startAnimatingLoadingIfNeededWhenViewWillAppear() {
        for cell in listView.visibleCells {
            if let loadingCell = cell as? ManageAssetListLoadingCell {
                loadingCell.startAnimating()
                return
            }
            
            if let assetCell = cell as? OptOutAssetListItemCell,
               assetCell.accessory == .loading {
                assetCell.accessory = .loading
                return
            }

            if let collectibleAssetCell = cell as? OptOutCollectibleAssetListItemCell,
               collectibleAssetCell.accessory == .loading {
                collectibleAssetCell.accessory = .loading
                return
            }
        }
    }
    
    private func stopAnimatingLoadingIfNeededWhenViewDidDisappear() {
        for cell in listView.visibleCells {
            if let loadingCell = cell as? ManageAssetListLoadingCell {
                loadingCell.stopAnimating()
                return
            }
        }
    }
    
    private func startAnimatingLoadingCellIfNeeded(_ cell: ManageAssetListLoadingCell?) {
        cell?.startAnimating()
    }
    
    private func stopAnimatingLoadingCellIfNeeded(_ cell: ManageAssetListLoadingCell?) {
        cell?.stopAnimating()
    }
}

extension ManageAssetListViewController {
    private func configureAccessory(
        _ cell: OptOutAssetListItemCell?,
        for item: OptOutAssetListItem
    ) {
        let asset = item.model
        let accessory = determineAccessory(asset)
        cell?.accessory = accessory
    }

    private func configureAccessory(
        _ cell: OptOutCollectibleAssetListItemCell?,
        for item: OptOutCollectibleAssetListItem
    ) {
        let asset = item.model
        let accessory = determineAccessory(asset)
        cell?.accessory = accessory
    }

    private func determineAccessory(_ asset: Asset) -> OptOutAssetListItemAccessory {
        let status = dataController.hasOptedOut(asset)

        let accessory: OptOutAssetListItemAccessory
        switch status {
        case .pending: accessory = .loading
        case .rejected: accessory = .remove
        case .optedOut: accessory = .loading
        }

        return accessory
    }
}

extension ManageAssetListViewController {
    private func linkInteractors(
        _ cell: OptOutAssetListItemCell?,
        for item: OptOutAssetListItem
    ) {
        cell?.startObserving(event: .remove) {
            [unowned self] in
            let asset = item.model
            let optOutApprovalCompletion: () -> Void = {
                [unowned cell] in
                cell?.accessory = .loading
            }
            openOptOutAsset(asset, optOutApprovalCompletion: optOutApprovalCompletion)
        }
    }

    private func linkInteractors(
        _ cell: OptOutCollectibleAssetListItemCell?,
        for item: OptOutCollectibleAssetListItem
    ) {
        cell?.startObserving(event: .remove) {
            [unowned self] in
            let asset = item.model

            let optOutApprovalCompletion: () -> Void = {
                [unowned cell] in
                cell?.accessory = .loading
            }
            openOptOutAsset(asset, optOutApprovalCompletion: optOutApprovalCompletion)
        }
    }

    private func openOptOutAsset(
        _ asset: Asset,
        optOutApprovalCompletion: @escaping () -> Void
    ) {
        if !self.isValidAssetDeletion(asset) {
            self.openTransferAssetBalance(asset: asset)
            return
        }

        let account = self.dataController.account
        let draft = OptOutAssetDraft(account: account, asset: asset)
        let screen = Screen.optOutAsset(draft: draft) {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performApprove:
                optOutApprovalCompletion()
                self.continueToOptOutAsset(
                    asset: asset,
                    account: self.account
                )
            case .performClose:
                self.cancelOptOutAsset()
            }
        }
        transitionToOptOutAsset.perform(
            screen,
            by: .present
        )
    }

    private func continueToOptOutAsset(
        asset: Asset,
        account: Account
    ) {
        dismiss(animated: true) {
            [weak self] in
            guard let self = self else { return }

            let account = self.dataController.account
            let transactionController = self.createNewTransactionController(for: asset)
            
            guard transactionController.canSignTransaction(for: account),
                  let creator = asset.creator else {
                self.clearTransactionCache(transactionController)
                self.restoreCellState(for: transactionController)
                return
            }

            let monitor = self.sharedDataController.blockchainUpdatesMonitor
            let request = OptOutBlockchainRequest(account: account, asset: asset)
            monitor.startMonitoringOptOutUpdates(request)

            let assetTransactionDraft = AssetTransactionSendDraft(
                from: account,
                toAccount: Account(address: creator.address),
                amount: 0,
                assetIndex: asset.id,
                assetCreator: creator.address
            )
            transactionController.setTransactionDraft(assetTransactionDraft)
            transactionController.getTransactionParamsAndComposeTransactionData(for: .assetRemoval)

            if account.requiresLedgerConnection() {
                self.openLedgerConnection(transactionController)
                
                transactionController.initializeLedgerTransactionAccount()
                transactionController.startTimer()
            }
        }
    }

    private func cancelOptOutAsset() {
        dismiss(animated: true)
    }
}

extension ManageAssetListViewController {
    private func openTransferAssetBalance(
        asset: Asset
    ) {
        let draft = TransferAssetBalanceDraft(
            account: account,
            asset: asset
        )

        let screen = Screen.transferAssetBalance(draft: draft) {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performApprove:
                self.continueToTransferAssetBalance(
                    asset: asset,
                    account: self.account
                )
            case .performClose:
                self.cancelTransferAssetBalance()
            }
        }

        transitionToTransferAssetBalance.perform(
            screen,
            by: .present
        )
    }

    private func continueToTransferAssetBalance(
        asset: Asset,
        account: Account
    ) {
        dismiss(animated: true) {
            [weak self] in
            guard let self = self else { return }

            var draft = SendTransactionDraft(
                from: account,
                transactionMode: .asset(asset),
                isOptingOut: true
            )
            draft.amount = asset.amountWithFraction

            self.open(
                .sendTransaction(draft: draft),
                by: .push
            )
        }
    }

    private func cancelTransferAssetBalance() {
        dismiss(animated: true)
    }
}

extension ManageAssetListViewController {
    private func isValidAssetDeletion(_ asset: Asset) -> Bool {
        return asset.amountWithFraction == 0
    }
}

extension ManageAssetListViewController: TransactionControllerDelegate {
    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        if let assetID = getAssetID(from: transactionController),
           optOutTransactions[assetID]?.asset is CollectibleAsset {
            NotificationCenter.default.post(
                name: CollectibleListLocalDataController.didRemoveCollectible,
                object: self
            )
        }

        clearTransactionCache(transactionController)
    }
    
    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            break
        }

        cancelMonitoringOptOutUpdates(for: transactionController)
        restoreCellState(for: transactionController)
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
        case .optOutFromCreator:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "asset-creator-opt-out-error-message".localized
            )
        default:
            break
        }
    }
    
    func transactionController(
        _ transactionController: TransactionController,
        didFailedTransaction error: HIPTransactionError
    ) {
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

        cancelMonitoringOptOutUpdates(for: transactionController)
        restoreCellState(for: transactionController)
        clearTransactionCache(transactionController)
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

    func transactionControllerDidResetLedgerOperation(
        _ transactionController: TransactionController
    ) {
        ledgerConnectionScreen?.dismissScreen()
        ledgerConnectionScreen = nil

        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil

        cancelMonitoringOptOutUpdates(for: transactionController)
        restoreCellState(for: transactionController)
    }

    func transactionControllerDidResetLedgerOperationOnSuccess(_ transactionController: TransactionController) {
        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil
    }
    
    private func getRemovedAssetDetail(from draft: AssetTransactionSendDraft?) -> Asset? {
        return draft?.assetIndex.unwrap { account[$0] }
    }
}

extension ManageAssetListViewController {
    private func cancelMonitoringOptOutUpdates(for transactionController: TransactionController) {
        if let assetID = getAssetID(from: transactionController) {
            let monitor = sharedDataController.blockchainUpdatesMonitor
            let account = dataController.account
            monitor.cancelMonitoringOptOutUpdates(
                forAssetID: assetID,
                for: account
            )
        }
    }
}

extension ManageAssetListViewController {
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

                self.cancelMonitoringOptOutUpdates(for: transactionController)
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

extension ManageAssetListViewController {
    private func openLedgerConnection(_ transactionController: TransactionController) {
        let eventHandler: LedgerConnectionScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancel:
                transactionController.stopBLEScan()
                transactionController.stopTimer()
                self.cancelMonitoringOptOutUpdates(for: transactionController)
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

extension ManageAssetListViewController {
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

struct AssetOptOutTransaction: Equatable {
    let asset: Asset
    let transactionController: TransactionController

    static func == (
        lhs: AssetOptOutTransaction,
        rhs: AssetOptOutTransaction
    ) -> Bool {
        return lhs.asset.id == rhs.asset.id
    }
}
