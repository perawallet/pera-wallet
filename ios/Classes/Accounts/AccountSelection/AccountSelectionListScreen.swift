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

//   AccountSelectionListScreen.swift

import UIKit
import MacaroonUIKit

class AccountSelectionListScreen<DataController: AccountSelectionListDataController>:
    BaseViewController,
    NavigationBarLargeTitleConfigurable,
    TransactionControllerDelegate,
    UICollectionViewDelegateFlowLayout  {
    var navigationBarScrollView: UIScrollView {
        return listView
    }

    var isNavigationBarAppeared: Bool {
        return isViewAppeared
    }

    private(set) lazy var navigationBarLargeTitleController = NavigationBarLargeTitleController(screen: self)
    private(set) lazy var navigationBarTitleView = createNavigationBarTitleView()
    private(set) lazy var navigationBarLargeTitleView = createNavigationBarLargeTitleView()

    private lazy var transitionToLedgerConnection = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToLedgerConnectionIssuesWarning = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToSignWithLedgerProcess = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )

    private lazy var transactionController = createTransactionController()
    private lazy var currencyFormatter = CurrencyFormatter()

    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?

    private weak var swapAssetFlowCoordinator: SwapAssetFlowCoordinator?

    private var selectedAccount: Account?

    private var isLayoutFinalized = false

    private let navigationBarTitle: String
    private let listView: UICollectionView
    private let dataController: DataController
    private let listLayout: AccountSelectionListLayout

    typealias DataSource = UICollectionViewDiffableDataSource<DataController.SectionIdentifierType, DataController.ItemIdentifierType>
    private let listDataSource: DataSource

    private let theme: AccountSelectionListScreenTheme

    typealias EventHandler = (Event, AccountSelectionListScreen) -> Void
    private let eventHandler: EventHandler

    init(
        navigationBarTitle: String,
        listView: UICollectionView,
        dataController: DataController,
        listLayout: AccountSelectionListLayout,
        listDataSource: DataSource,
        theme: AccountSelectionListScreenTheme,
        eventHandler: @escaping EventHandler,
        configuration: ViewControllerConfiguration
    ) {
        self.navigationBarTitle = navigationBarTitle
        self.listView = listView
        self.dataController = dataController
        self.listLayout = listLayout
        self.listDataSource = listDataSource
        self.eventHandler = eventHandler
        self.theme = theme

        super.init(configuration: configuration)
    }

    deinit {
        navigationBarLargeTitleController.deactivate()
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
                self.listDataSource.apply(
                    snapshot,
                    animatingDifferences: true
                )
            }
        }

        dataController.load()
    }

    override func setListeners() {
        super.setListeners()

        navigationBarLargeTitleController.activate()

        listView.delegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()

        addUI()
    }

    override func bindData() {
        super.bindData()

        navigationBarLargeTitleController.title = navigationBarTitle
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isLayoutFinalized ||
           navigationBarLargeTitleView.bounds.isEmpty {
            return
        }

        updateUIWhenViewDidLayout()

        isLayoutFinalized = true
    }

    private func addUI() {
        addBackground()
        addNavigationBarLargeTitle()
        addList()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let account = dataController[indexPath] else {
            assertionFailure("Account at index path is nil.")
            return
        }

        guard account.isAvailable else {
            return
        }

        selectedAccount = account.value
        eventHandler(.didSelect(account), self)
    }

    /// <todo> Refactor
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let loadingCell = cell as? AccountSelectionListLoadingAccountItemCell
        loadingCell?.startAnimating()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let loadingCell = cell as? AccountSelectionListLoadingAccountItemCell
        loadingCell?.stopAnimating()
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
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            referenceSizeForHeaderInSection: section
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

extension AccountSelectionListScreen {
    private func updateUIWhenViewDidLayout() {
        updateListContentInsetsWhenViewDidLayout()
    }

    private func updateListContentInsetsWhenViewDidLayout() {
        let navigationBarLargeTitleHeight = navigationBarLargeTitleView.bounds.height
        listView.contentInset.top =
            navigationBarLargeTitleHeight +
            theme.listContentTopInset
    }
}

extension AccountSelectionListScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addNavigationBarLargeTitle() {
        view.addSubview(navigationBarLargeTitleView)
        navigationBarLargeTitleView.snp.makeConstraints {
            $0.top == theme.navigationBarEdgeInsets.top
            $0.leading == theme.navigationBarEdgeInsets.leading
            $0.trailing == theme.navigationBarEdgeInsets.trailing
        }
    }

    private func addList() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension AccountSelectionListScreen {
    private func createTransactionController() -> TransactionController {
        return TransactionController(
            api: api!,
            sharedDataController: sharedDataController,
            bannerController: bannerController,
            analytics: analytics
        )
    }

    func continueToOptInAsset(
        asset: AssetDecoration
    ) {
        guard let account = selectedAccount else { return }

        if !transactionController.canSignTransaction(for: account) { return }
        
        loadingController?.startLoadingWithMessage("title-loading".localized)
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
            openLedgerConnection()

            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        cancelMonitoringOptInUpdates(for: transactionController)

        loadingController?.stopLoading()

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
        cancelMonitoringOptInUpdates(for: transactionController)

        loadingController?.stopLoading()

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
              let asset = sharedDataController.assetDetailCollection[assetID] else {
            return
        }

        asyncMain(afterDuration: 3.0) {
            [weak self] in
            guard let self = self else { return }

            self.loadingController?.stopLoading()
            self.eventHandler(.didOptInToAsset(asset), self)
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
            ledgerConnectionScreen?.dismiss(animated: true) {
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

    func transactionControllerDidResetLedgerOperation(
        _ transactionController: TransactionController
    ) {
        ledgerConnectionScreen?.dismissScreen()
        ledgerConnectionScreen = nil

        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil

        cancelMonitoringOptInUpdates(for: transactionController)

        loadingController?.stopLoading()
    }

    func transactionControllerDidResetLedgerOperationOnSuccess(_ transactionController: TransactionController) {
        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil

        loadingController?.stopLoading()
    }

    private func cancelMonitoringOptInUpdates(for transactionController: TransactionController) {
        if let assetID = getAssetID(from: transactionController),
           let selectedAccount {
            let monitor = sharedDataController.blockchainUpdatesMonitor
            monitor.cancelMonitoringOptInUpdates(
                forAssetID: assetID,
                for: selectedAccount
            )
        }
    }

    private func getAssetID(
        from transactionController: TransactionController
    ) -> AssetID? {
        return transactionController.assetTransactionDraft?.assetIndex
    }
}

extension AccountSelectionListScreen {
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

                self.loadingController?.stopLoading()
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

extension AccountSelectionListScreen {
    private func openLedgerConnection() {
        let eventHandler: LedgerConnectionScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancel:
                self.transactionController.stopBLEScan()
                self.transactionController.stopTimer()

                self.ledgerConnectionScreen?.dismissScreen()
                self.ledgerConnectionScreen = nil

                self.cancelMonitoringOptInUpdates(for: self.transactionController)

                self.loadingController?.stopLoading()
            }
        }

        ledgerConnectionScreen = transitionToLedgerConnection.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }
}

extension AccountSelectionListScreen {
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

extension AccountSelectionListScreen {
    enum Event {
        case didSelect(AccountHandle)
        case didOptInToAsset(AssetDecoration)
    }
}
