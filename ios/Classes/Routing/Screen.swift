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
//  Screen.swifta

import UIKit

indirect enum Screen {
    case asaDetail(
        account: Account,
        asset: Asset,
        configuration: ASADetailScreenConfiguration? = nil,
        eventHandler: ASADetailScreen.EventHandler
    )
    case asaDiscovery(
        account: Account?,
        quickAction: AssetQuickAction?,
        asset: AssetDecoration,
        eventHandler: ASADiscoveryScreen.EventHandler? = nil
    )
    case welcome(flow: AccountSetupFlow)
    case addAccount(flow: AccountSetupFlow)
    case recoverAccount(flow: AccountSetupFlow)
    case choosePassword(mode: ChoosePasswordViewController.Mode, flow: AccountSetupFlow?)
    case passphraseView(flow: AccountSetupFlow, address: String)
    case passphraseVerify(flow: AccountSetupFlow)
    case accountNameSetup(flow: AccountSetupFlow,  mode: AccountSetupMode, nameServiceName: String? = nil, accountAddress: PublicKey)
    case accountRecover(
        flow: AccountSetupFlow,
        initialMnemonic: String? = nil
    )
    case qrScanner(canReadWCSession: Bool)
    case qrGenerator(title: String?, draft: QRCreationDraft, isTrackable: Bool = false)
    case accountDetail(accountHandle: AccountHandle, eventHandler: AccountDetailViewController.EventHandler)
    case options(account: Account, delegate: OptionsViewControllerDelegate)
    case accountList(mode: AccountListViewController.Mode, delegate: AccountListViewControllerDelegate)
    case renameAccount(account: Account, delegate: RenameAccountScreenDelegate)
    case contacts
    case notifications
    case addContact(address: String? = nil, name: String? = nil)
    case editContact(contact: Contact)
    case contactDetail(contact: Contact)
    case nodeSettings
    case transactionDetail(
        account: Account,
        transaction: Transaction,
        assetDetail: Asset?
    )
    case appCallTransactionDetail(
        account: Account,
        transaction: Transaction,
        transactionTypeFilter: TransactionTypeFilter,
        assets: [Asset]?
    )
    case appCallAssetList(
        dataController: AppCallAssetListDataController
    )
    case addAsset(account: Account)
    case removeAsset(dataController: ManageAssetsListDataController)
    case managementOptions(
        managementType: ManagementOptionsViewController.ManagementType,
        delegate: ManagementOptionsViewControllerDelegate
    )
    case assetActionConfirmation(
        assetAlertDraft: AssetAlertDraft,
        delegate: AssetActionConfirmationViewControllerDelegate?,
        theme: AssetActionConfirmationViewControllerTheme = .init()
    )
    case rewardDetail(account: Account)
    case ledgerTutorial(flow: AccountSetupFlow)
    case ledgerDeviceList(flow: AccountSetupFlow)
    case ledgerApproval(mode: LedgerApprovalViewController.Mode, deviceName: String)
    case passphraseDisplay(address: String)
    case assetDetailNotification(address: String, assetId: Int64?)
    case assetActionConfirmationNotification(address: String, assetId: Int64?)
    case transactionFilter(filterOption: TransactionFilterViewController.FilterOption = .allTime, delegate: TransactionFilterViewControllerDelegate)
    case transactionFilterCustomRange(fromDate: Date?, toDate: Date?)
    case pinLimit
    case rekeyInstruction(account: Account)
    case rekeyConfirmation(account: Account, ledgerDetail: LedgerDetail?, ledgerAddress: String)
    case ledgerAccountSelection(flow: AccountSetupFlow, accounts: [Account])
    case walletRating
    case securitySettings
    case developerSettings
    case currencySelection
    case appearanceSelection
    case watchAccountAddition(
        flow: AccountSetupFlow,
        address: String? = nil
    )
    case ledgerAccountDetail(account: Account, ledgerIndex: Int?, rekeyedAccounts: [Account]?)
    case notificationFilter
    case bottomWarning(configurator: BottomWarningViewConfigurator)
    case tutorial(flow: AccountSetupFlow, tutorial: Tutorial)
    case tutorialSteps(step: Troubleshoot.Step)
    case transactionTutorial(isInitialDisplay: Bool)
    case recoverOptions(delegate: AccountRecoverOptionsViewControllerDelegate)
    case ledgerAccountVerification(flow: AccountSetupFlow, selectedAccounts: [Account])
    case wcConnection(
        walletConnectSession: WalletConnectSession,
        completion: WalletConnectSessionConnectionCompletionHandler
    )
    case walletConnectSessionList
    case walletConnectSessionShortList
    case wcTransactionFullDappDetail(configurator: WCTransactionFullDappDetailConfigurator)
    case wcAlgosTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcAssetTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcAssetAdditionTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcGroupTransaction(transactions: [WCTransaction], transactionRequest: WalletConnectRequest)
    case wcAppCall(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcAssetCreationTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcAssetReconfigurationTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcAssetDeletionTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case jsonDisplay(jsonData: Data, title: String)
    case ledgerPairWarning(delegate: LedgerPairWarningViewControllerDelegate)
    case accountListOptions(accountType: AccountType, eventHandler: AccountListOptionsViewController.EventHandler)
    case sortAccountList(
        dataController: SortAccountListDataController,
        eventHandler: SortAccountListViewController.EventHandler
    )
    case accountSelection(
        draft: SelectAccountDraft,
        delegate: SelectAccountViewControllerDelegate?,
        shouldFilterAccount: ((Account) -> Bool)? = nil
    )
    case assetSelection(
        account: Account,
        receiver: String? = nil
    )
    case sendTransaction(draft: SendTransactionDraft)
    case editNote(note: String?, isLocked: Bool, delegate: EditNoteScreenDelegate?)
    case portfolioCalculationInfo(result: PortfolioValue?, eventHandler: PortfolioCalculationInfoViewController.EventHandler)
    case invalidAccount(
        account: AccountHandle,
        uiInteractionsHandler: InvalidAccountOptionsViewController.InvalidAccountOptionsUIInteractions
    )
    case transactionResult
    case transactionAccountSelect(draft: SendTransactionDraft)
    case sendTransactionPreview(draft: TransactionSendDraft)
    case wcMainTransactionScreen(draft: WalletConnectRequestDraft, delegate: WCMainTransactionScreenDelegate)
    case wcSingleTransactionScreen(
        transactions: [WCTransaction],
        transactionRequest: WalletConnectRequest,
        transactionOption: WCTransactionOption?
    )
    case asaVerificationInfo(EventHandler<AsaVerificationInfoEvent>)
    case sortCollectibleList(
        dataController: SortCollectibleListDataController,
        eventHandler: SortCollectibleListViewController.EventHandler
    )
    case accountCollectibleListFilterSelection(uiInteractions: AccountCollectibleListFilterSelectionViewController.UIInteractions)
    case collectiblesFilterSelection(uiInteractions: CollectiblesFilterSelectionViewController.UIInteractions)
    case receiveCollectibleAccountList(
        dataController: ReceiveCollectibleAccountListDataController
    )
    case receiveCollectibleAssetList(account: AccountHandle)
    case collectibleDetail(
        asset: CollectibleAsset,
        account: Account,
        thumbnailImage: UIImage? = nil,
        quickAction: AssetQuickAction? = nil,
        eventHandler: CollectibleDetailViewController.EventHandler? = nil
    )
    case sendCollectible(draft: SendCollectibleDraft)
    case sendCollectibleAccountList(
        dataController: SendCollectibleAccountListDataController
    )
    case approveCollectibleTransaction(draft: SendCollectibleDraft)
    case shareActivity(items: [Any])
    case image3DCard(image: UIImage)
    case video3DCard(
        image: UIImage?,
        url: URL
    )
    case collectibleFullScreenImage(draft: CollectibleFullScreenImageDraft)
    case collectibleFullScreenVideo(draft: CollectibleFullScreenVideoDraft)
    case buyAlgoHome(
        transactionDraft: BuyAlgoDraft,
        delegate: BuyAlgoHomeScreenDelegate?
    )
    case buyAlgoTransaction(buyAlgoParams: BuyAlgoParams)
    case transactionOptions(delegate: TransactionOptionsScreenDelegate?)
    case qrScanOptions(
        address: PublicKey,
        eventHandler: QRScanOptionsViewController.EventHandler
    )
    case assetsFilterSelection(uiInteractions: AssetsFilterSelectionViewController.UIInteractions)
    case sortAccountAsset(
        dataController: SortAccountAssetListDataController,
        eventHandler: SortAccountAssetListViewController.EventHandler
    )
    case innerTransactionList(
        dataController: InnerTransactionListDataController,
        eventHandler: InnerTransactionListViewController.EventHandler
    )
    case swapAsset(
        dataStore: SwapAmountPercentageStore & SwapMutableAmountPercentageStore,
        swapController: SwapController,
        coordinator: SwapAssetFlowCoordinator
    )
    case swapAccountSelection(
        swapAssetFlowCoordinator: SwapAssetFlowCoordinator,
        eventHandler: AccountSelectionListScreen<SwapAccountSelectionListLocalDataController>.EventHandler
    )
    case swapSignWithLedgerProcess(
        transactionSigner: SwapTransactionSigner,
        draft: SignWithLedgerProcessDraft,
        eventHandler: SignWithLedgerProcessScreen.EventHandler
    )
    case loading(
        viewModel: LoadingScreenViewModel,
        theme: LoadingScreenTheme = .init()
    )
    case error(
        viewModel: ErrorScreenViewModel,
        theme: ErrorScreenTheme = .init()
    )
    case swapSuccess(
        swapController: SwapController,
        theme: SwapAssetSuccessScreenTheme = .init()
    )
    case swapSummary(
        swapController: SwapController,
        theme: SwapSummaryScreenTheme = .init()
    )
    case alert(alert: Alert)
    case swapIntroduction(
        draft: SwapIntroductionDraft,
        eventHandler: EventHandler<SwapIntroductionEvent>
    )
    case optInAsset(
        draft: OptInAssetDraft,
        eventHandler: OptInAssetScreen.EventHandler
    )
    case optOutAsset(
        draft: OptOutAssetDraft,
        theme: OptOutAssetScreenTheme = .init(),
        eventHandler: OptOutAssetScreen.EventHandler
    )
    case transferAssetBalance(
        draft: TransferAssetBalanceDraft,
        theme: TransferAssetBalanceScreenTheme = .init(),
        eventHandler: TransferAssetBalanceScreen.EventHandler
    )
    case sheetAction(
        sheet: UISheet,
        theme: UISheetActionScreenTheme = UISheetActionScreenCommonTheme()
    )
    case insufficientAlgoBalance(
        draft: InsufficientAlgoBalanceDraft,
        eventHandler: InsufficientAlgoBalanceScreen.EventHandler
    )
    case exportAccountList(
        eventHandler: ExportAccountListScreen.EventHandler
    )
    case exportAccountsDomainConfirmation(
        hasSingularAccount: Bool,
        eventHandler: ExportAccountsDomainConfirmationScreen.EventHandler
    )
    case exportAccountsConfirmationList(
        selectedAccounts: [Account],
        eventHandler: ExportAccountsConfirmationListScreen.EventHandler
    )
    case selectAsset(
        dataController: SelectAssetDataController,
        coordinator: SwapAssetFlowCoordinator?,
        title: String,
        theme: SelectAssetScreenTheme = .init()
    )
    case confirmSwap(
        dataStore: SwapSlippageTolerancePercentageStore,
        dataController: ConfirmSwapDataController,
        eventHandler: EventHandler<ConfirmSwapScreen.Event>,
        theme: ConfirmSwapScreenTheme = .init()
    )
    /// <todo>
    /// We should find a way to define the EventHandler decoupled to the actual screen when we
    /// refactor the routing mechanism.
    case editSwapAmount(
        dataStore: SwapAmountPercentageStore & SwapMutableAmountPercentageStore,
        eventHandler: EditSwapAmountScreen.EventHandler
    )
    case editSwapSlippage(
        dataStore: SwapSlippageTolerancePercentageStore & SwapMutableSlippageTolerancePercentageStore,
        eventHandler: EditSwapSlippageScreen.EventHandler
    )
    case exportAccountsResult(
        accounts: [Account],
        eventHandler: ExportsAccountsResultScreen.EventHandler
    )
    case discoverSearch(DiscoverSearchScreen.EventHandler)
    case discoverAssetDetail(DiscoverAssetParameters)
    case discoverDappDetail(
        DiscoverDappParamaters,
        eventHandler: DiscoverDappDetailScreen.EventHandler?
    )
}

extension Screen {
    enum Transition {
    }
}

extension Screen.Transition {
    enum Open: Equatable {
        case root
        case push
        case present
        case presentWithoutNavigationController
        case launch
        case set
        case customPresent(
            presentationStyle: UIModalPresentationStyle?,
            transitionStyle: UIModalTransitionStyle?,
            transitioningDelegate: UIViewControllerTransitioningDelegate?)
        case customPresentWithoutNavigationController(
            presentationStyle: UIModalPresentationStyle?,
            transitionStyle: UIModalTransitionStyle?,
            transitioningDelegate: UIViewControllerTransitioningDelegate?)
        
        static func == (lhs: Open, rhs: Open) -> Bool {
            switch (lhs, rhs) {
            case (.push, .push):
                return true
            case (.present, .present):
                return true
            case (.presentWithoutNavigationController, .presentWithoutNavigationController):
                return true
            case (.launch, .launch):
                return true
            case (.set, .set):
                return true
            case (.customPresent, .customPresent):
                return false
            case (.customPresentWithoutNavigationController, .customPresentWithoutNavigationController):
                return false
            default:
                return false
            }
        }
    }
    
    enum Close {
        case pop
        case dismiss
    }
}

extension Screen {
    typealias EventHandler<Event> = (Event) -> Void
}
