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
    UIContextMenuInteractionDelegate {
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

    private lazy var bottomSheetTransition = BottomSheetTransition(
        presentingViewController: self
    )

    private lazy var listLayout = ReceiveCollectibleAssetListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = ReceiveCollectibleAssetListDataSource(listView)

    private var isLayoutFinalized = false

    private lazy var transactionController: TransactionController = {
        return TransactionController(
            api: api!,
            bannerController: bannerController
        )
    }()

    private lazy var accountMenuInteraction = UIContextMenuInteraction(delegate: self)

    private lazy var currencyFormatter = CurrencyFormatter()

    private let copyToClipboardController: CopyToClipboardController

    private var ledgerApprovalViewController: LedgerApprovalViewController?
    private var currentAsset: AssetDecoration?

    private let account: AccountHandle
    private let dataController: ReceiveCollectibleAssetListDataController
    private let theme: ReceiveCollectibleAssetListViewControllerTheme

    init(
        account: AccountHandle,
        dataController: ReceiveCollectibleAssetListDataController,
        theme: ReceiveCollectibleAssetListViewControllerTheme = .init(),
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
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
            }
        }

        dataController.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        listView
            .visibleCells
            .forEach {
                let loadingCell = $0 as? PreviewLoadingCell
                loadingCell?.startAnimating()
            }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        listView
            .visibleCells
            .forEach {
                let loadingCell = $0 as? PreviewLoadingCell
                loadingCell?.stopAnimating()
            }
    }

    override func prepareLayout() {
        super.prepareLayout()
        build()
    }

    override func setListeners() {
        super.setListeners()

        listView.delegate = self

        transactionController.delegate = self

        selectedAccountPreviewView.observe(event: .performCopyAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.copyAddress()
        }

        selectedAccountPreviewView.observe(event: .performQRAction) {
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
        transactionController.delegate = self

        selectedAccountPreviewView.addInteraction(accountMenuInteraction)

        selectedAccountPreviewView.observe(event: .performCopyAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.copyAddress()
        }

        selectedAccountPreviewView.observe(event: .performQRAction) {
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
                    account.value
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
        copyToClipboardController.copyAddress(self.account.value)
    }

    private func openQRGenerator() {
        let account = account.value
        
        let draft = QRCreationDraft(
            address: account.address,
            mode: .address,
            title: account.name
        )

        open(
            .qrGenerator(
                title: account.name ?? account.address.shortAddressDisplay,
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
                 self.copyToClipboardController.copyAddress(self.account.value)
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
            backgroundColor: AppColors.Shared.System.background.uiColor
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
            backgroundColor: AppColors.Shared.System.background.uiColor
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
        case .collectible:
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
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        view.endEditing(true)

        switch itemIdentifier {
        case .collectible:
            guard let selectedAsset = dataController[indexPath.item] else {
                return
            }

            if account.value.containsAsset(selectedAsset.id) {
                displaySimpleAlertWith(
                    title: "asset-you-already-own-message".localized,
                    message: .empty
                )
                return
            }

            let assetAlertDraft = AssetAlertDraft(
                account: account.value,
                assetId: selectedAsset.id,
                asset: selectedAsset,
                transactionFee: Transaction.Constant.minimumFee,
                title: "asset-add-confirmation-title".localized,
                detail: "asset-add-warning".localized,
                actionTitle: "title-approve".localized,
                cancelTitle: "title-cancel".localized
            )

            bottomSheetTransition.perform(
                .assetActionConfirmation(assetAlertDraft: assetAlertDraft, delegate: self),
                by: .presentWithoutNavigationController
            )
        default: break
        }
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func linkInteractors(
        _ cell: CollectibleReceiveSearchInputCell
    ) {
        cell.delegate = self
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

extension ReceiveCollectibleAssetListViewController:
    AssetActionConfirmationViewControllerDelegate,
    TransactionSignChecking {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmAction asset: AssetDecoration
    ) {
        var anAccount = account.value

        if !canSignTransaction(for: &anAccount) {
            return
        }

        let assetTransactionDraft = AssetTransactionSendDraft(
            from: anAccount,
            assetIndex: asset.id
        )
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)

        loadingController?.startLoadingWithMessage("title-loading".localized)

        if anAccount.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }

        currentAsset = asset
    }
}

extension ReceiveCollectibleAssetListViewController: TransactionControllerDelegate {
    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        loadingController?.stopLoading()
        currentAsset = nil

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
        currentAsset = nil

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
        loadingController?.stopLoading()

        if let currentAsset = currentAsset {
            let collectibleAsset = CollectibleAsset(
                asset: ALGAsset(id: currentAsset.id),
                decoration: currentAsset
            )

            NotificationCenter.default.post(
                name: CollectibleListLocalDataController.didAddCollectible,
                object: self,
                userInfo: [
                    CollectibleListLocalDataController.accountAssetPairUserInfoKey: (account.value, collectibleAsset)
                ]
            )
        }

        delegate?.receiveCollectibleAssetListViewController(self, didCompleteTransaction: account.value)
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
        let ledgerApprovalTransition = BottomSheetTransition(presentingViewController: self)
        ledgerApprovalViewController = ledgerApprovalTransition.perform(
            .ledgerApproval(mode: .approve, deviceName: ledger),
            by: .present
        )
    }

    func transactionControllerDidResetLedgerOperation(
        _ transactionController: TransactionController
    ) {
        ledgerApprovalViewController?.dismissScreen()
    }

    func transactionControllerDidRejectedLedgerOperation(
        _ transactionController: TransactionController
    ) {
        loadingController?.stopLoading()
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
