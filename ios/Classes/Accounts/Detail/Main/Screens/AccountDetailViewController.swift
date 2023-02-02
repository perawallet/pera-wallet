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
//   AccountDetailViewController.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AccountDetailViewController: PageContainer {
    typealias EventHandler = (Event) -> Void
    
    var eventHandler: EventHandler?
    
    private lazy var theme = Theme()
    private lazy var modalTransition = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToRenameAccount = BottomSheetTransition(presentingViewController: self)

    private lazy var assetListScreen = createAssetListScreen()
    private lazy var collectibleListScreen = createCollectibleListScreen()
    
    private lazy var transactionListScreen = AccountTransactionListViewController(
        draft: AccountTransactionListing(accountHandle: accountHandle),
        copyToClipboardController: copyToClipboardController,
        configuration: configuration
    )

    private lazy var buyAlgoFlowCoordinator = BuyAlgoFlowCoordinator(presentingScreen: self)
    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(account: accountHandle.value),
        dataStore: swapDataStore,
        analytics: analytics,
        api: api!,
        sharedDataController: sharedDataController,
        loadingController: loadingController!,
        bannerController: bannerController!,
        presentingScreen: self
    )
    private lazy var sendTransactionFlowCoordinator = SendTransactionFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController,
        account: accountHandle.value
    )
    private lazy var receiveTransactionFlowCoordinator = ReceiveTransactionFlowCoordinator(
        presentingScreen: self,
        account: accountHandle.value
    )

    private lazy var localAuthenticator = LocalAuthenticator()

    private lazy var navigationTitleView = AccountNameTitleView()

    private var accountHandle: AccountHandle

    private let dataController: AccountDetailDataController

    /// <todo>
    /// Normally, we shouldn't retain data store or create flow coordinator here but our currenct
    /// routing approach hasn't been refactored yet.
    private let swapDataStore: SwapDataStore
    private let copyToClipboardController: CopyToClipboardController

    init(
        accountHandle: AccountHandle,
        dataController: AccountDetailDataController,
        swapDataStore: SwapDataStore,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.accountHandle = accountHandle
        self.dataController = dataController
        self.swapDataStore = swapDataStore
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setPageBarItems()
    }

    override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(animated)
        switchToHighlightedNavigationBarAppearance()
    }

    override func viewWillDisappear(
        _ animated: Bool
    ) {
        super.viewWillDisappear(animated)

        if presentedViewController == nil {
            switchToDefaultNavigationBarAppearance()
        }
    }

    override func configureNavigationBarAppearance() {
        addNavigationTitle()
        addNavigationActions()
    }

    override func customizePageBarAppearance() {
        super.customizePageBarAppearance()

        pageBar.customizeAppearance([
            .backgroundColor(Colors.Helpers.heroBackground)
        ])
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func linkInteractors() {
        super.linkInteractors()
        linkInteractors(assetListScreen)
    }

    override func itemDidSelect(
        _ index: Int
    ) {
        endEditing()
    }
}

extension AccountDetailViewController {
    private func linkInteractors(
        _ screen: AccountAssetListViewController
    ) {
        screen.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let accountHandle):
                self.accountHandle = accountHandle
            case .didRenameAccount:
                self.bindNavigationTitle()
                self.eventHandler?(.didEdit)
            case .didRemoveAccount:
                self.eventHandler?(.didRemove)
            case .manageAssets(let isWatchAccount):
                self.assetListScreen.endEditing()
                self.analytics.track(.recordAccountDetailScreen(type: .manageAssets))

                self.modalTransition.perform(
                    .managementOptions(
                        managementType: isWatchAccount ? .watchAccountAssets : .assets,
                        delegate: self
                    ),
                    by: .present
                )
            case .addAsset:
                self.assetListScreen.endEditing()
                self.analytics.track(.recordAccountDetailScreen(type: .addAssets))

                self.openAddAssetScreen()
            case .buyAlgo:
                self.assetListScreen.endEditing()
                self.analytics.track(.recordAccountDetailScreen(type: .buyAlgo))

                let draft = BuyAlgoDraft()
                draft.address = self.accountHandle.value.address
                self.buyAlgoFlowCoordinator.launch(draft: draft)
            case .swap:
                self.assetListScreen.endEditing()
                self.analytics.track(.recordAccountDetailScreen(type: .swap))

                self.swapAssetFlowCoordinator.launch()
            case .send:
                self.assetListScreen.endEditing()

                self.sendTransactionFlowCoordinator.launch()
            case .more:
                self.assetListScreen.endEditing()

                self.presentOptionsScreen()
            case .transactionOption:
                self.openAccountActionsMenu()
            }
        }
    }
}

extension AccountDetailViewController: TransactionOptionsScreenDelegate {
    func transactionOptionsScreenDidAddAsset(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.openAddAssetScreen()
        }
    }

    func transactionOptionsScreenDidBuyAlgo(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [weak self] in

            let buyAlgoDraft = BuyAlgoDraft()
            buyAlgoDraft.address = self?.accountHandle.value.address
            
            self?.buyAlgoFlowCoordinator.launch(draft: buyAlgoDraft)
        }
    }

    func transactionOptionsScreenDidSwap(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [weak self] in
            guard let self = self else { return }
            
            self.analytics.track(.recordAccountDetailScreen(type: .swap))
            self.swapAssetFlowCoordinator.launch()
        }
    }

    func transactionOptionsScreenDidSend(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [weak self] in
            self?.sendTransactionFlowCoordinator.launch()
        }
    }

    func transactionOptionsScreenDidReceive(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [weak self] in
            self?.receiveTransactionFlowCoordinator.launch()
        }
    }

    func transactionOptionsScreenDidMore(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [weak self] in
            self?.presentOptionsScreen()
        }
    }
}

extension AccountDetailViewController {
    private func addNavigationActions() {
        let optionsBarButtonItem = ALGBarButtonItem(kind: .account(accountHandle.value.typeImage)) {
            [unowned self] in

            self.endEditing()

            self.presentOptionsScreen()
        }

        rightBarButtonItems = [ optionsBarButtonItem ]
    }

    private func presentOptionsScreen() {
        modalTransition.perform(
            .options(account: self.accountHandle.value, delegate: self),
            by: .presentWithoutNavigationController
        )
    }

    private func openAddAssetScreen() {
        let controller = open(
            .addAsset(
                account: accountHandle.value
            ),
            by: .present
        ) as? AssetAdditionViewController
        controller?.navigationController?.presentationController?.delegate = assetListScreen
    }

    private func setPageBarItems() {
        items = [
            AssetListPageBarItem(screen: assetListScreen),
            CollectibleListPageBarItem(screen: collectibleListScreen),
            TransactionListPageBarItem(screen: transactionListScreen)
        ]
    }

    private func addNavigationTitle() {
        navigationTitleView.customize(theme.navigationTitle)

        navigationItem.titleView = navigationTitleView

        let recognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(copyAccountAddress(_:))
        )
        navigationTitleView.addGestureRecognizer(recognizer)

        bindNavigationTitle()
    }

    private func bindNavigationTitle() {
        let account = accountHandle.value
        let viewModel = AccountNameTitleViewModel(account)
        navigationTitleView.bindData(viewModel)
    }
}

extension AccountDetailViewController {
    @objc
    private func copyAccountAddress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            copyToClipboardController.copyAddress(accountHandle.value)
        }
    }
}

extension AccountDetailViewController {
    @objc
    private func openAccountActionsMenu() {
        view.endEditing(true)

        self.modalTransition.perform(
            .transactionOptions(delegate: self),
            by: .presentWithoutNavigationController
        )
    }
}

extension AccountDetailViewController: OptionsViewControllerDelegate {
    func optionsViewControllerDidCopyAddress(_ optionsViewController: OptionsViewController) {
        let account = accountHandle.value
        analytics.track(.showQRCopy(account: account))
        copyToClipboardController.copyAddress(account)
    }

    func optionsViewControllerDidOpenRekeying(_ optionsViewController: OptionsViewController) {
        open(
            .rekeyInstruction(account: accountHandle.value),
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            )
        )
    }
    
    func optionsViewControllerDidViewRekeyInformation(_ optionsViewController: OptionsViewController) {
        guard let authAddress = accountHandle.value.authAddress else {
            return
        }

        let draft = QRCreationDraft(address: authAddress, mode: .address, title: accountHandle.value.name)
        open(.qrGenerator(title: "options-auth-account".localized, draft: draft, isTrackable: true), by: .present)
    }

    func optionsViewControllerDidShowQR(_ optionsViewController: OptionsViewController) {
        let account = accountHandle.value
        let accountName = account.primaryDisplayName
        let draft = QRCreationDraft(
            address: account.address,
            mode: .address,
            title: accountName
        )
        let qrGeneratorScreen: Screen = .qrGenerator(
            title: accountName,
            draft: draft,
            isTrackable: true
        )

        open(qrGeneratorScreen, by: .present)
    }

    func optionsViewControllerDidViewPassphrase(_ optionsViewController: OptionsViewController) {
        guard let session = session else {
            return
        }

        if !session.hasPassword() {
            presentPassphraseView()
            return
        }

        if localAuthenticator.localAuthenticationStatus != .allowed {
            let controller = open(
                .choosePassword(mode: .confirm(flow: .viewPassphrase), flow: nil),
                by: .present
            ) as? ChoosePasswordViewController
            controller?.delegate = self
            return
        }

        localAuthenticator.authenticate { [weak self] error in
            guard let self = self,
                  error == nil else {
                return
            }

            self.presentPassphraseView()
        }
    }

    private func presentPassphraseView() {
        modalTransition.perform(
            .passphraseDisplay(address: accountHandle.value.address),
            by: .present
        )
    }

    func optionsViewControllerDidRenameAccount(_ optionsViewController: OptionsViewController) {
        let screen: Screen = .renameAccount(
            account: accountHandle.value,
            delegate: self
        )

        transitionToRenameAccount.perform(
            screen,
            by: .present
        )
    }

    func optionsViewControllerDidRemoveAccount(_ optionsViewController: OptionsViewController) {
        displayRemoveAccountAlert()
    }

    private func displayRemoveAccountAlert() {
        let account = accountHandle.value
        let configurator = BottomWarningViewConfigurator(
            image: "icon-trash-red".uiImage,
            title: "options-remove-account".localized,
            description: .plain(
                account.isWatchAccount()
                ? "options-remove-watch-account-explanation".localized
                : "options-remove-main-account-explanation".localized
            ),
            primaryActionButtonTitle: "title-remove".localized,
            secondaryActionButtonTitle: "title-keep".localized,
            primaryAction: { [weak self] in
                self?.removeAccount()
            }
        )

        modalTransition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
    }

    private func removeAccount() {
        sharedDataController.resetPollingAfterRemoving(accountHandle.value)
        walletConnector.updateSessionsWithRemovingAccount(accountHandle.value)
        eventHandler?(.didRemove)
    }
}

extension AccountDetailViewController: ChoosePasswordViewControllerDelegate {
    func choosePasswordViewController(
        _ choosePasswordViewController: ChoosePasswordViewController,
        didConfirmPassword isConfirmed: Bool
    ) {
        choosePasswordViewController.dismissScreen()
        if isConfirmed {
            presentPassphraseView()
        }
    }
}

extension AccountDetailViewController: RenameAccountScreenDelegate {
    func renameAccountScreenDidTapDoneButton(_ screen: RenameAccountScreen) {
        screen.closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.bindNavigationTitle()
            self.eventHandler?(.didEdit)
        }
    }
}

extension AccountDetailViewController: ManagementOptionsViewControllerDelegate {
    func managementOptionsViewControllerDidTapSort(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {
        let eventHandler: SortAccountAssetListViewController.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didComplete:
                let order = self.sharedDataController.selectedAccountAssetSortingAlgorithm
                self.assetListScreen.reloadData(order)
            }

            self.dismiss(animated: true)
        }

        open(
            .sortAccountAsset(
                dataController: SortAccountAssetListLocalDataController(
                    session: session!,
                    sharedDataController: sharedDataController
                ),
                eventHandler: eventHandler
            ),
            by: .present
        )
    }
    
    func managementOptionsViewControllerDidTapFilterAssets(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {
        var uiInteractions = AssetsFilterSelectionViewController.UIInteractions()
        uiInteractions.didComplete = {
            [unowned self] in

            let filters = AssetFilterOptions()
            self.assetListScreen.reloadData(filters)

            self.dismiss(animated: true)
        }
        uiInteractions.didCancel =  {
            [unowned self] in
            self.dismiss(animated: true)
        }
        
        open(
            .assetsFilterSelection(uiInteractions: uiInteractions),
            by: .present
        )
    }

    func managementOptionsViewControllerDidTapRemove(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {
        let dataController = ManageAssetsListLocalDataController(
            account: accountHandle.value,
            sharedDataController: sharedDataController
        )

        let controller = open(
            .removeAsset(dataController: dataController),
            by: .present
        ) as? ManageAssetsViewController
        controller?.navigationController?.presentationController?.delegate = assetListScreen
    }
    
    func managementOptionsViewControllerDidTapFilterCollectibles(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {}
}

extension AccountDetailViewController {
    private func createAssetListScreen() -> AccountAssetListViewController {
        let query = AccountAssetListQuery(
            filteringBy: .init(),
            sortingBy: sharedDataController.selectedAccountAssetSortingAlgorithm
        )
        return AccountAssetListViewController(
            query: query,
            dataController: dataController.assetListDataController,
            copyToClipboardController: copyToClipboardController,
            configuration: configuration
        )
    }

    private func createCollectibleListScreen() -> AccountCollectibleListViewController {
        let query = CollectibleListQuery(
            filteringBy: .init(),
            sortingBy: sharedDataController.selectedCollectibleSortingAlgorithm
        )
        return AccountCollectibleListViewController(
            account: accountHandle,
            query: query,
            dataController: dataController.collectibleListDataController,
            copyToClipboardController: copyToClipboardController,
            configuration: configuration
        )
    }
}

extension AccountDetailViewController {
    struct AssetListPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = AccountDetailPageBarItemID.assets.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: "accounts-title-overview".localized)
            self.screen = screen
        }
    }

    struct CollectibleListPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = AccountDetailPageBarItemID.collectibles.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: "accounts-title-collectibles".localized)
            self.screen = screen
        }
    }

    struct TransactionListPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = AccountDetailPageBarItemID.transactions.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: "accounts-title-history".localized)
            self.screen = screen
        }
    }

    enum AccountDetailPageBarItemID: String {
        case assets
        case collectibles
        case transactions
    }
}

extension AccountDetailViewController {
    enum Event {
        case didEdit
        case didRemove
    }
}
