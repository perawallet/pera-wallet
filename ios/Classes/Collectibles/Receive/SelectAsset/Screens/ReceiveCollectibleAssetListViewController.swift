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

//   ReceiveCollectibleAssetListViewController.swift

import UIKit
import MacaroonUIKit
import MacaroonUtils

final class ReceiveCollectibleAssetListViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout,
    NotificationObserver,
    UIContextMenuInteractionDelegate,
    TransactionSignChecking {
    var notificationObservations: [NSObjectProtocol] = []

    weak var delegate: ReceiveCollectibleAssetListViewControllerDelegate?

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = ReceiveCollectibleAssetListLayout.build()
        let collectionView =
        UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var selectedAccountPreviewCanvasView = MacaroonUIKit.BaseView()
    private lazy var selectedAccountPreviewView = SelectedAccountPreviewView()

    private lazy var transitionToOptInAsset = BottomSheetTransition(presentingViewController: self)

    private lazy var listLayout = ReceiveCollectibleAssetListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = ReceiveCollectibleAssetListDataSource(listView)

    private var isLayoutFinalized = false

    private var optInTransactions: [AssetID: AssetOptInTransaction] = [:]

    private var transactionControllers: [TransactionController] {
        return Array(optInTransactions.values.map { $0.transactionController })
    }

    private lazy var accountMenuInteraction = UIContextMenuInteraction(delegate: self)

    private lazy var currencyFormatter = CurrencyFormatter()

    private let copyToClipboardController: CopyToClipboardController

    private var ledgerApprovalViewController: LedgerApprovalViewController?

    private let dataController: ReceiveCollectibleAssetListDataController
    private let theme: ReceiveCollectibleAssetListViewControllerTheme

    init(
        dataController: ReceiveCollectibleAssetListDataController,
        theme: ReceiveCollectibleAssetListViewControllerTheme = .init(),
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        self.theme = theme
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }

    deinit {
        stopObservingNotifications()
    }

    override func configureNavigationBarAppearance() {
        navigationItem.title = "collectibles-receive-asset-title".localized
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let snapshot):
                self.listDataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            case .didOptInAssets(let items):
                for item in items {
                    if let indexPath = self.listDataSource.indexPath(for: .collectible(item)),
                       let cell = self.listView.cellForItem(at: indexPath) {
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

    override func prepareLayout() {
        super.prepareLayout()
        build()
    }

    override func setListeners() {
        super.setListeners()

        listView.delegate = self

        selectedAccountPreviewView.startObserving(event: .performCopyAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.copyAddress()
        }

        selectedAccountPreviewView.startObserving(event: .performQRAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.openQRGenerator()
        }

        observeWhenKeyboardWillShow(using: didReceive(keyboardWillShow:))
        observeWhenKeyboardWillHide(using: didReceive(keyboardWillHide:))
    }

    override func linkInteractors() {
        selectedAccountPreviewView.addInteraction(accountMenuInteraction)

        selectedAccountPreviewView.startObserving(event: .performCopyAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.copyAddress()
        }

        selectedAccountPreviewView.startObserving(event: .performQRAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.openQRGenerator()
        }
    }

    override func bindData() {
        selectedAccountPreviewView.bindData(
            SelectedAccountPreviewViewModel(
                IconWithShortAddressDraft(
                    dataController.account
                )
            )
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isLayoutFinalized {
            isLayoutFinalized = true
            listLayout.selectedAccountPreviewCanvasViewHeight = selectedAccountPreviewCanvasView.frame.height
        }
    }

    private func build() {
        addBackground()
        addListView()
        addSelectedAccountPreviewView()
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func addBackground() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func addSelectedAccountPreviewView() {
        selectedAccountPreviewCanvasView.backgroundColor = theme.backgroundColor.uiColor

        view.addSubview(selectedAccountPreviewCanvasView)
        selectedAccountPreviewCanvasView.snp.makeConstraints {
            $0.setPaddings((.noMetric, 0, 0, 0))
        }

        selectedAccountPreviewView.customize(
            SelectedAccountPreviewViewTheme()
        )

        selectedAccountPreviewCanvasView.addSubview(selectedAccountPreviewView)
        selectedAccountPreviewView.snp.makeConstraints {
            $0.bottom == view.safeAreaBottom

            $0.setPaddings((0, 0, .noMetric, 0))
        }
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func copyAddress() {
        let account = dataController.account
        copyToClipboardController.copyAddress(account)
    }

    private func openQRGenerator() {
        let account = dataController.account
        
        let draft = QRCreationDraft(
            address: account.address,
            mode: .address,
            title: account.name
        )

        open(
            .qrGenerator(
                title: account.primaryDisplayName,
                draft: draft,
                isTrackable: true
            ),
            by: .present
        )
    }
}

extension ReceiveCollectibleAssetListViewController {
     func contextMenuInteraction(
         _ interaction: UIContextMenuInteraction,
         configurationForMenuAtLocation location: CGPoint
     ) -> UIContextMenuConfiguration? {
         return UIContextMenuConfiguration { _ in
             let copyActionItem = UIAction(item: .copyAddress) {
                 [unowned self] _ in
                 let account = self.dataController.account
                 self.copyToClipboardController.copyAddress(account)
             }
             return UIMenu(children: [ copyActionItem ])
         }
     }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let view = interaction.view else {
            return nil
        }

        return UITargetedPreview(
            view: view,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let view = interaction.view else {
            return nil
        }

        return UITargetedPreview(
            view: view,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }
 }

extension ReceiveCollectibleAssetListViewController {
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

extension ReceiveCollectibleAssetListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? PreviewLoadingCell
                loadingCell?.startAnimating()
            default:
                break
            }
        case .search:
            linkInteractors(cell as! CollectibleReceiveSearchInputCell)
        case .collectible(let item):
            configureAccessory(
                cell as? OptInAssetListItemCell,
                for: item
            )
            linkInteractors(
                cell as? OptInAssetListItemCell,
                for: item
            )

            dataController.loadNextPageIfNeeded(for: indexPath)
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? PreviewLoadingCell
                loadingCell?.stopAnimating()
            default:
                break
            }
        default:
            break
        }
    }
}

extension ReceiveCollectibleAssetListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        view.endEditing(true)

        guard case .collectible(let item) = listDataSource.itemIdentifier(for: indexPath) else { return }

        let asset = item.model
        let cell = collectionView.cellForItem(at: indexPath)
        let optInCell = cell as? OptInAssetListItemCell
        openCollectibleDetail(
            asset,
            from: optInCell
        )
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
            case .didOptOutAssetFromAccount: break
            case .didOptOutFromAssetWithQuickAction: break
            case .didOptInToAsset:
                cell?.accessory = .loading
            }
        }
        open(
            screen,
            by: .push
        )
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

            let assetTransactionDraft = AssetTransactionSendDraft(
                from: account,
                assetIndex: asset.id
            )
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

extension ReceiveCollectibleAssetListViewController {
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

extension ReceiveCollectibleAssetListViewController {
    private func linkInteractors(
        _ cell: CollectibleReceiveSearchInputCell
    ) {
        cell.delegate = self
    }

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
}

extension ReceiveCollectibleAssetListViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        guard let query = view.text else {
            return
        }

        dataController.search(for: query)
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func restartLoadingOfVisibleCellsIfNeeded() {
        for cell in listView.visibleCells {
            if let assetCell = cell as? OptInAssetListItemCell,
               assetCell.accessory == .loading {
                assetCell.accessory = .loading
            } else if let loadingCell = cell as? PreviewLoadingCell {
                loadingCell.startAnimating()
            }
        }
    }
}

extension ReceiveCollectibleAssetListViewController: TransactionControllerDelegate {
    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
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
        default:
            break
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedTransaction error: HIPTransactionError
    ) {
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
            bannerController?.presentErrorBanner(title: "title-error".localized, message: apiError.debugDescription)
        default:
            bannerController?.presentErrorBanner(title: "title-error".localized, message: error.localizedDescription)
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        guard
            let assetID = getAssetID(from: transactionController),
            let assetDetail = optInTransactions[assetID]?.asset
        else {
            return
        }

        let collectibleAsset = CollectibleAsset(
            asset: ALGAsset(id: assetDetail.id),
            decoration: assetDetail
        )

        NotificationCenter.default.post(
            name: CollectibleListLocalDataController.didAddCollectible,
            object: self,
            userInfo: [
                CollectibleListLocalDataController.accountAssetPairUserInfoKey: (dataController.account, collectibleAsset)
            ]
        )

        delegate?.receiveCollectibleAssetListViewController(
            self,
            didCompleteTransaction: dataController.account
        )

        clearTransactionCache(transactionController)
    }

    private func displayTransactionError(
        from transactionError: TransactionError
    ) {
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

    func transactionControllerDidRejectedLedgerOperation(
        _ transactionController: TransactionController
    ) {}
}

extension ReceiveCollectibleAssetListViewController {
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
        let item = ReceiveCollectibleAssetListItem.collectible(OptInAssetListItem(asset: asset))
        let indexPath = listDataSource.indexPath(for: item)
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

extension ReceiveCollectibleAssetListViewController {
    private func updateLayoutWhenKeyboardHeightDidChange(
        _ keyboardHeight: LayoutMetric = 0,
        isShowing: Bool
    ) {
        if isShowing {
            selectedAccountPreviewCanvasView.snp.updateConstraints {
                $0.bottom == keyboardHeight
            }

            selectedAccountPreviewView.snp.updateConstraints {
                $0.bottom == 0
            }
        } else {
            selectedAccountPreviewCanvasView.snp.updateConstraints {
                $0.bottom == 0
            }

            selectedAccountPreviewView.snp.updateConstraints {
                $0.bottom == view.safeAreaBottom
            }
        }

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: UIView.AnimationOptions(
                rawValue: UInt(UIView.AnimationCurve.linear.rawValue >> 16)
            ),
            animations: {
                [weak self] in
                guard let self = self else { return }
                self.view.layoutIfNeeded()
            }
        )
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func didReceive(
        keyboardWillShow notification: Notification
    ) {
        guard UIApplication.shared.isActive,
              let keyboardHeight = notification.keyboardHeight else {
                  return
              }

        updateLayoutWhenKeyboardHeightDidChange(
            keyboardHeight,
            isShowing: true
        )
    }

    private func didReceive(
        keyboardWillHide notification: Notification
    ) {
        guard UIApplication.shared.isActive else {
            return
        }

        updateLayoutWhenKeyboardHeightDidChange(isShowing: false)
    }
}

protocol ReceiveCollectibleAssetListViewControllerDelegate: AnyObject {
    func receiveCollectibleAssetListViewController(
        _ controller: ReceiveCollectibleAssetListViewController,
        didCompleteTransaction account: Account
    )
}
