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
//  ManageAssetsViewController.swift

import UIKit
import MagpieHipo

final class ManageAssetsViewController:
    BaseViewController,
    TransactionSignChecking,
    UICollectionViewDelegateFlowLayout {    
    private lazy var theme = Theme()
    
    private lazy var listLayout = ManageAssetsListLayout(dataSource)
    private lazy var dataSource = ManageAssetsListDataSource(contextView.assetsCollectionView)

    private lazy var transitionToOptOutAsset = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToTransferAssetBalance = BottomSheetTransition(presentingViewController: self)

    private lazy var contextView = ManageAssetsView()
    
    private var account: Account {
        return dataController.account
    }

    private var ledgerApprovalViewController: LedgerApprovalViewController?
    
    private var optOutTransactions: [AssetID: AssetOptOutTransaction] = [:]

    private var transactionControllers: [TransactionController] {
        return Array(optOutTransactions.values.map { $0.transactionController })
    }

    private lazy var currencyFormatter = CurrencyFormatter()

    private let dataController: ManageAssetsListDataController

    init(
        dataController: ManageAssetsListDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let snapshot):
                self.dataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            }
        }
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
    
    override func setListeners() {
        dataController.dataSource = dataSource
        contextView.assetsCollectionView.dataSource = dataSource
        contextView.assetsCollectionView.delegate = self
        contextView.setSearchInputDelegate(self)
    }

    override func prepareLayout() {
        contextView.customize(theme.contextViewTheme)
        
        view.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

/// <mark>
/// UICollectionViewDelegateFlowLayout
extension ManageAssetsViewController {
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
extension ManageAssetsViewController {
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
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard case .asset(let item) = self.dataSource.itemIdentifier(for: indexPath) else { return }

        let asset = item.model

        if let collectibleAsset = asset as? CollectibleAsset {
            let cell = collectionView.cellForItem(at: indexPath)
            let optOutCell = cell as? OptOutAssetListItemCell
            openCollectibleDetail(
                collectibleAsset,
                from: optOutCell
            )
        } else {
            let cell = collectionView.cellForItem(at: indexPath)
            let optOutCell = cell as? OptOutAssetListItemCell
            let assetDetail = AssetDecoration(asset: asset)
            openASADiscovery(
                assetDetail,
                from: optOutCell
            )
        }
    }
}

extension ManageAssetsViewController {
    private func openCollectibleDetail(
        _ asset: CollectibleAsset,
        from cell: OptOutAssetListItemCell? = nil
    ) {
        let screen = Screen.collectibleDetail(
            asset: asset,
            account: account,
            thumbnailImage: nil,
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

extension ManageAssetsViewController {
    private func createNewTransactionController(
        for asset: Asset
    ) -> TransactionController {
        let transactionController = TransactionController(
            api: api!,
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
        from asset: Asset
    ) -> OptOutAssetListItemCell?  {
        let assetItem = AssetItem(
            asset: asset,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
        let optOutAssetListItem = OptOutAssetListItem(item: assetItem)
        let listItem = ManageAssetSearchItem.asset(optOutAssetListItem)
        let indexPath = dataSource.indexPath(for: listItem)

        return indexPath.unwrap {
            contextView.assetsCollectionView.cellForItem(at: $0)
        } as? OptOutAssetListItemCell
    }

    private func restoreCellState(
        for transactionController: TransactionController
    ) {
        if let assetID = getAssetID(from: transactionController),
           let assetDetail = optOutTransactions[assetID]?.asset,
           let cell = findCell(from: assetDetail) {
            cell.accessory = .remove
        }
    }
}

extension ManageAssetsViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        guard let query = view.text else {
            return
        }
        
        if query.isEmpty {
            dataController.resetSearch()
            return
        }
        
        dataController.search(for: query)
    }
    
    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}

extension ManageAssetsViewController {
    private func restartLoadingOfVisibleCellsIfNeeded() {
        for cell in contextView.assetsCollectionView.visibleCells {
            if let assetCell = cell as? OptOutAssetListItemCell,
               assetCell.accessory == .loading {
                assetCell.accessory = .loading
            }
        }
    }
}

extension ManageAssetsViewController {
    private func configureAccessory(
        _ cell: OptOutAssetListItemCell?,
        for item: OptOutAssetListItem
    ) {
        let asset = item.model
        let status = dataController.hasOptedOut(asset)

        let accessory: OptOutAssetListItemAccessory
        switch status {
        case .pending: accessory = .loading
        case .rejected: accessory = .remove
        case .optedOut: accessory = .loading
        }

        cell?.accessory = accessory
    }
}

extension ManageAssetsViewController {
    private func linkInteractors(
        _ cell: OptOutAssetListItemCell?,
        for item: OptOutAssetListItem
    ) {
        cell?.startObserving(event: .remove) {
            [unowned self] in

            let asset = item.model

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
                    cell?.accessory = .loading
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
    }

    private func continueToOptOutAsset(
        asset: Asset,
        account: Account
    ) {
        dismiss(animated: true) {
            [weak self] in
            guard let self = self else { return }

            var account = self.dataController.account

            if !self.canSignTransaction(for: &account) { return }

            guard let creator = asset.creator else { return }

            let monitor = self.sharedDataController.blockchainUpdatesMonitor
            let request = OptOutBlockchainRequest(account: account, asset: asset)
            monitor.startMonitoringOptOutUpdates(request)

            let assetTransactionDraft = AssetTransactionSendDraft(
                from: account,
                toAccount: Account(address: creator.address, type: .standard),
                amount: 0,
                assetIndex: asset.id,
                assetCreator: creator.address
            )
            let transactionController = self.createNewTransactionController(for: asset)
            transactionController.setTransactionDraft(assetTransactionDraft)
            transactionController.getTransactionParamsAndComposeTransactionData(for: .assetRemoval)

            if account.requiresLedgerConnection() {
                transactionController.initializeLedgerTransactionAccount()
                transactionController.startTimer()
            }
        }
    }

    private func cancelOptOutAsset() {
        dismiss(animated: true)
    }
}

extension ManageAssetsViewController {
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
                transactionMode: .asset(asset)
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

extension ManageAssetsViewController {
    private func isValidAssetDeletion(_ asset: Asset) -> Bool {
        return asset.amountWithFraction == 0
    }
}

extension ManageAssetsViewController: TransactionControllerDelegate {
    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        if let assetID = getAssetID(from: transactionController),
           let collectibleAsset = optOutTransactions[assetID]?.asset as? CollectibleAsset {
            let account = dataController.account

            NotificationCenter.default.post(
                name: CollectibleListLocalDataController.didRemoveCollectible,
                object: self,
                userInfo: [
                    CollectibleListLocalDataController.accountAssetPairUserInfoKey: (account, collectibleAsset)
                ]
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

        finishMonitoringOptOutUpdates(for: transactionController)
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

        finishMonitoringOptOutUpdates(for: transactionController)
        restoreCellState(for: transactionController)
        clearTransactionCache(transactionController)
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

    func transactionControllerDidResetLedgerOperation(
        _ transactionController: TransactionController
    ) {
        ledgerApprovalViewController?.dismissScreen()
    }
    
    private func getRemovedAssetDetail(from draft: AssetTransactionSendDraft?) -> Asset? {
        return draft?.assetIndex.unwrap { account[$0] }
    }
}

extension ManageAssetsViewController {
    private func finishMonitoringOptOutUpdates(for transactionController: TransactionController) {
        if let assetID = getAssetID(from: transactionController) {
            let monitor = self.sharedDataController.blockchainUpdatesMonitor
            let account = dataController.account
            monitor.finishMonitoringOptOutUpdates(
                forAssetID: assetID,
                for: account
            )
        }
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
