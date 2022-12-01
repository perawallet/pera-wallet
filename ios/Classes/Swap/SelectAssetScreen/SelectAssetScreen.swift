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

//   SelectAssetScreen.swift

import Foundation
import MacaroonForm
import MacaroonUIKit
import MacaroonUtils
import MagpieExceptions
import MagpieHipo
import UIKit

final class SelectAssetScreen:
    BaseViewController,
    UICollectionViewDelegateFlowLayout,
    SearchInputViewDelegate,
    SwapAssetFlowCoordinatorObserver,
    TransactionControllerDelegate,
    TransactionSignChecking,
    MacaroonForm.KeyboardControllerDataSource {
    var eventHandler: Screen.EventHandler<SelectAssetScreenEvent>?

    private var ledgerApprovalViewController: LedgerApprovalViewController?

    private lazy var searchInputView = SearchInputView()

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = AccountAssetListLayout.build()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = theme.listBackgroundColor.uiColor
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }()

    private lazy var listDataSource = SelectAssetDataSource(listView)
    private lazy var listLayout = SelectAssetListLayout(listDataSource: listDataSource)

    private lazy var transactionController = createTransactionController()
    private lazy var currencyFormatter = CurrencyFormatter()

    private lazy var keyboardController = MacaroonForm.KeyboardController(
        scrollView: listView,
        screen: self
    )

    private weak var swapAssetFlowCoordinator: SwapAssetFlowCoordinator?
    private let dataController: SelectAssetDataController
    private let theme: SelectAssetScreenTheme

    init(
        dataController: SelectAssetDataController,
        coordinator: SwapAssetFlowCoordinator?,
        theme: SelectAssetScreenTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        self.swapAssetFlowCoordinator = coordinator
        self.theme = theme
        super.init(configuration: configuration)

        swapAssetFlowCoordinator?.add(self)
        keyboardController.activate()
    }

    deinit {
        keyboardController.deactivate()
        swapAssetFlowCoordinator?.remove(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUIWhenKeyboardDidToggle()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else {
                return
            }

            switch event {
            case .didUpdate(let updates):
                self.listDataSource.apply(
                    updates.snapshot,
                    animatingDifferences: true
                )
            }
        }

        dataController.load()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        transactionController.stopBLEScan()
        transactionController.stopTimer()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        listView.visibleCells.forEach {
            let loadingCell = $0 as? PreviewLoadingCell
            loadingCell?.stopAnimating()
        }
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = theme.listBackgroundColor.uiColor
    }

    override func prepareLayout() {
        super.prepareLayout()
        addSearchInput()
        addListView()
    }

    override func linkInteractors() {
        super.linkInteractors()
        searchInputView.delegate = self
        listView.delegate = self
    }
}

extension SelectAssetScreen {
    private func updateUIWhenKeyboardDidToggle() {
        keyboardController.performAlongsideWhenKeyboardIsShowing(animated: true) {
            [unowned self] _ in
            if self.listDataSource.isEmpty {
                self.listView.collectionViewLayout.invalidateLayout()
                self.listView.layoutIfNeeded()
            }
        }
        keyboardController.performAlongsideWhenKeyboardIsHiding(animated: true) {
            [unowned self] _ in
            if self.listDataSource.isEmpty {
                self.listView.collectionViewLayout.invalidateLayout()
                self.listView.layoutIfNeeded()
            }
        }
    }

    private func addSearchInput() {
        searchInputView.customize(theme.searchInputView)

        view.addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top == theme.searchInsets.top
            $0.leading == theme.searchInsets.leading
            $0.trailing == theme.searchInsets.trailing
        }
    }

    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.top == searchInputView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}

extension SelectAssetScreen {
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
        didSelectItemAt indexPath: IndexPath
    ) {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: indexPath.section] else {
            return
        }

        switch listSection {
        case .assets:
            guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
                return
            }

            switch itemIdentifier {
            case .asset(let item):
                eventHandler?(.didSelectAsset(item.model))
            default:
                break
            }
        default:
            break
        }
    }

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
            if case .loading = item {
                let loadingCell = cell as? PreviewLoadingCell
                loadingCell?.startAnimating()
            }
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
            if case .loading = item {
                let loadingCell = cell as? PreviewLoadingCell
                loadingCell?.stopAnimating()
            }
        default:
            break
        }
    }
}

extension SelectAssetScreen {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        guard let query = view.text else { return }

        if query.count == 0 {
            dataController.resetSearch()
            return
        }

        if query.isEmptyOrBlank {
            return
        }

        dataController.search(for: query)
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}

extension SelectAssetScreen {
    func swapAssetFlowCoordinator(
        _ swapAssetFlowCoordinator: SwapAssetFlowCoordinator,
        didPublish event: SwapAssetFlowCoordinatorEvent
    ) {

        switch event {
        case .didApproveOptInToAsset(let asset):
            self.continueToOptInAsset(asset: asset)
        default: break
        }
    }
}

extension SelectAssetScreen {
    private func continueToOptInAsset(
        asset: AssetDecoration
    ) {
        loadingController?.startLoadingWithMessage("title-loading".localized)

        var account = dataController.account

        if !canSignTransaction(for: &account) { return }

        let monitor = sharedDataController.blockchainUpdatesMonitor
        let request = OptInBlockchainRequest(
            account: account,
            asset: asset
        )
        monitor.startMonitoringOptInUpdates(request)

        let assetTransactionDraft = AssetTransactionSendDraft(
            from: account,
            assetIndex: asset.id
        )

        transactionController.delegate = self
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)

        if account.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }
}


extension SelectAssetScreen {
    private func createTransactionController() -> TransactionController {
        return TransactionController(
            api: api!,
            bannerController: bannerController,
            analytics: analytics
        )
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        loadingController?.stopLoading()

        if let assetID = getAssetID(from: transactionController) {
            let monitor = sharedDataController.blockchainUpdatesMonitor
            monitor.finishMonitoringOptInUpdates(
                forAssetID: assetID,
                for: dataController.account
            )
        }

        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        case let .network(apiError):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: apiError.prettyDescription
            )
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedTransaction error: HIPTransactionError
    ) {
        loadingController?.stopLoading()

        if let assetID = getAssetID(from: transactionController) {
            let monitor = self.sharedDataController.blockchainUpdatesMonitor
            monitor.finishMonitoringOptInUpdates(
                forAssetID: assetID,
                for: dataController.account
            )
        }

        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: apiError.prettyDescription
            )
        default:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.debugDescription
            )
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        guard let assetID = getAssetID(from: transactionController),
              let asset = dataController[assetID] else {
            return
        }

        asyncMain(afterDuration: 3.0) {
            [weak self] in
            guard let self = self else { return }

            self.loadingController?.stopLoading()
            self.eventHandler?(.didOptInToAsset(asset))
        }
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
        loadingController?.stopLoading()
        ledgerApprovalViewController?.dismissScreen()
    }

    func transactionControllerDidRejectedLedgerOperation(
        _ transactionController: TransactionController
    ) {}

    private func getAssetID(
        from transactionController: TransactionController
    ) -> AssetID? {
        return transactionController.assetTransactionDraft?.assetIndex
    }
}

enum SelectAssetScreenEvent {
    case didSelectAsset(Asset)
    case didOptInToAsset(Asset)
}
