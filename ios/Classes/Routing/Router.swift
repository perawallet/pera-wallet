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
//  Router.swift

import Foundation
import MacaroonUIKit
import MacaroonUtils
import UIKit

class Router:
    AssetActionConfirmationViewControllerDelegate,
    WalletConnectorDelegate,
    WCConnectionApprovalViewControllerDelegate,
    NotificationObserver {
    var notificationObservations: [NSObjectProtocol] = []
    
    unowned let rootViewController: RootViewController
    
    /// <todo>
    /// How to dealloc finished transitions?
    private var ongoingTransitions: [BottomSheetTransition] = []
    private var qrSendDraft: QRSendTransactionDraft?

    private unowned let appConfiguration: AppConfiguration
    
    init(
        rootViewController: RootViewController,
        appConfiguration: AppConfiguration
    ) {
        self.rootViewController = rootViewController
        self.appConfiguration = appConfiguration
        
        observeNotifications()
    }
    
    deinit {
        unobserveNotifications()
    }
    
    func launchAuthorization() {
        if findVisibleScreen(over: rootViewController) is ChoosePasswordViewController {
            return
        }
        
        route(
            to: .choosePassword(mode: .login, flow: nil),
            from: findVisibleScreen(over: rootViewController),
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            ),
            animated: true
        )
    }
    
    func launchOnboarding() {
        route(
            to: .welcome(flow: .initializeAccount(mode: .none)),
            from: findVisibleScreen(over: rootViewController),
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            ),
            animated: true
        ) { [weak self] in
            guard let self = self else { return }
            self.rootViewController.terminateTabs()
        }
    }
    
    func launchMain() {
        rootViewController.launchTabsIfNeeded()
        rootViewController.dismissIfNeeded()
    }
    
    func launcMainAfterAuthorization(
        presented viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        rootViewController.launchTabsIfNeeded()
        viewController.dismissScreen(completion: completion)
    }
    
    func launch(
        deeplink screen: DeepLinkParser.Screen
    ) {
        func launch(
            tab: TabBarItemID
        ) {
            if rootViewController.presentedViewController == nil {
                rootViewController.launch(tab: tab)
            }
        }
        
        switch screen {
        case .addContact(let address, let name):
            launch(tab: .contacts)
            
            route(
                to: .addContact(address: address, name: name),
                from: findVisibleScreen(over: rootViewController),
                by: .present
            )
        case .algosDetail(let draft):
            launch(tab: .home)

            route(
                to: .algosDetail(draft: draft),
                from: findVisibleScreen(over: rootViewController),
                by: .present
            )
        case .assetActionConfirmation(let draft):
            launch(tab: .home)
            
            let visibleScreen = findVisibleScreen(over: rootViewController)
            let transition = BottomSheetTransition(presentingViewController: visibleScreen)

            transition.perform(
                .assetActionConfirmation(assetAlertDraft: draft, delegate: self),
                by: .presentWithoutNavigationController
            )
            
            ongoingTransitions.append(transition)
        case .assetDetail(let draft):
            launch(tab: .home)
            
            route(
                to: .assetDetail(draft: draft),
                from: findVisibleScreen(over: rootViewController),
                by: .present
            )

        case .sendTransaction(let draft):
            launch(tab: .home)

            qrSendDraft = draft
            route(
                to: .accountSelection(transactionAction: .send, delegate: self),
                from: findVisibleScreen(over: rootViewController),
                by: .present
            )
        case .wcMainTransactionScreen(let draft):
            route(
                to: .wcMainTransactionScreen(draft: draft, delegate: rootViewController),
                from: findVisibleScreen(over: rootViewController),
                by: .customPresent(
                    presentationStyle: .fullScreen,
                    transitionStyle: nil,
                    transitioningDelegate: nil
                ),
                animated: true
            )
        }
    }
    
    @discardableResult
    func route<T: UIViewController>(
        to screen: Screen,
        from sourceViewController: UIViewController,
        by style: Screen.Transition.Open,
        animated: Bool = true,
        then completion: EmptyHandler? = nil
    ) -> T? {
        guard let viewController = buildViewController(for: screen) else {
            return nil
        }
        
        switch style {
        case .push:
            if let currentViewController = self as? StatusBarConfigurable,
               let nextViewController = viewController as? StatusBarConfigurable {
                
                let isStatusBarHidden = currentViewController.isStatusBarHidden
                
                nextViewController.hidesStatusBarWhenAppeared = isStatusBarHidden
                nextViewController.isStatusBarHidden = isStatusBarHidden
            }
            
            sourceViewController.navigationController?.pushViewController(viewController, animated: animated)
        case .launch:
            if !(sourceViewController is RootViewController) {
                sourceViewController.closeScreen(by: .dismiss, animated: false)
            }
            
            let navigationController: NavigationController
            
            if let navController = viewController as? NavigationController {
                navigationController = navController
            } else {
                if let presentingViewController = self as? StatusBarConfigurable,
                   let presentedViewController = viewController as? StatusBarConfigurable,
                   presentingViewController.isStatusBarHidden {
                    
                    presentedViewController.hidesStatusBarWhenPresented = true
                    presentedViewController.isStatusBarHidden = true
                }
                
                navigationController = NavigationController(rootViewController: viewController)
            }
            
            navigationController.modalPresentationStyle = .fullScreen
            
            rootViewController.present(navigationController, animated: false, completion: completion)
        case .present,
            .customPresent:
            let navigationController: NavigationController
            
            if let navController = viewController as? NavigationController {
                navigationController = navController
            } else {
                if let presentingViewController = self as? StatusBarConfigurable,
                   let presentedViewController = viewController as? StatusBarConfigurable,
                   presentingViewController.isStatusBarHidden {
                    
                    presentedViewController.hidesStatusBarWhenPresented = true
                    presentedViewController.isStatusBarHidden = true
                }
                
                navigationController = NavigationController(rootViewController: viewController)
            }
            
            if case .customPresent(
                let presentationStyle,
                let transitionStyle,
                let transitioningDelegate) = style {
                
                if let aPresentationStyle = presentationStyle {
                    navigationController.modalPresentationStyle = aPresentationStyle
                }
                if let aTransitionStyle = transitionStyle {
                    navigationController.modalTransitionStyle = aTransitionStyle
                }
                navigationController.transitioningDelegate = transitioningDelegate
            }
            
            navigationController.modalPresentationCapturesStatusBarAppearance = true
            
            sourceViewController.present(navigationController, animated: animated, completion: completion)
        case .presentWithoutNavigationController:
            if let presentingViewController = self as? StatusBarConfigurable,
               let presentedViewController = viewController as? StatusBarConfigurable,
               presentingViewController.isStatusBarHidden {
                
                presentedViewController.hidesStatusBarWhenPresented = true
                presentedViewController.isStatusBarHidden = true
            }
            
            viewController.modalPresentationCapturesStatusBarAppearance = true
            
            sourceViewController.present(viewController, animated: animated, completion: completion)
            
        case let .customPresentWithoutNavigationController(presentationStyle, transitionStyle, transitioningDelegate):
            if let presentingViewController = self as? StatusBarConfigurable,
               let presentedViewController = viewController as? StatusBarConfigurable,
               presentingViewController.isStatusBarHidden {
                
                presentedViewController.hidesStatusBarWhenPresented = true
                presentedViewController.isStatusBarHidden = true
            }
            
            if let aPresentationStyle = presentationStyle {
                viewController.modalPresentationStyle = aPresentationStyle
            }
            if let aTransitionStyle = transitionStyle {
                viewController.modalTransitionStyle = aTransitionStyle
            }
            viewController.modalPresentationCapturesStatusBarAppearance = true
            viewController.transitioningDelegate = transitioningDelegate
            
            sourceViewController.present(viewController, animated: animated, completion: completion)
        case .set:
            if let currentViewController = self as? StatusBarConfigurable,
               let nextViewController = viewController as? StatusBarConfigurable {
                
                let isStatusBarHidden = currentViewController.isStatusBarHidden
                
                nextViewController.hidesStatusBarWhenAppeared = isStatusBarHidden
                nextViewController.isStatusBarHidden = isStatusBarHidden
            }
            
            guard let navigationController = sourceViewController.navigationController else {
                return nil
            }
            
            var viewControllers = navigationController.viewControllers
            
            let firstViewController = viewControllers[0]
            
            viewControllers = [firstViewController, viewController]
            
            navigationController.setViewControllers(viewControllers, animated: animated)
        }
        
        guard let navigationController = viewController as? UINavigationController,
              let firstViewController = navigationController.viewControllers.first as? T else {
                  return viewController as? T
              }
        
        return firstViewController
    }
    
    // swiftlint:disable function_body_length
    private func buildViewController<T: UIViewController>(for screen: Screen) -> T? {
        let configuration = appConfiguration.all()

        let viewController: UIViewController
        
        switch screen {
        case let .welcome(flow):
            viewController = WelcomeViewController(flow: flow, configuration: configuration)
        case let .addAccount(flow):
            viewController = AddAccountViewController(flow: flow, configuration: configuration)
        case let .recoverAccount(flow):
            viewController = RecoverAccountViewController(flow: flow, configuration: configuration)
        case let .choosePassword(mode, flow):
            viewController = ChoosePasswordViewController(
                mode: mode,
                accountSetupFlow: flow,
                configuration: configuration
            )
        case let .passphraseView(flow, address):
            viewController = PassphraseBackUpViewController(flow: flow, address: address, configuration: configuration)
        case let .passphraseVerify(flow):
            viewController = PassphraseVerifyViewController(flow: flow, configuration: configuration)
        case let .accountNameSetup(flow, mode, accountAddress):
            viewController = AccountNameSetupViewController(flow: flow, mode: mode, accountAddress: accountAddress, configuration: configuration)
        case let .accountRecover(flow):
            viewController = AccountRecoverViewController(accountSetupFlow: flow, configuration: configuration)
        case let .qrScanner(canReadWCSession):
            viewController = QRScannerViewController(canReadWCSession: canReadWCSession, configuration: configuration)
        case let .qrGenerator(title, draft, isTrackable):
            let qrCreationController = QRCreationViewController(draft: draft, configuration: configuration, isTrackable: isTrackable)
            qrCreationController.title = title
            viewController = qrCreationController
        case let .accountList(mode, delegate):
            let accountListViewController = AccountListViewController(mode: mode, configuration: configuration)
            accountListViewController.delegate = delegate
            viewController = accountListViewController
        case let .options(account, delegate):
            let optionsViewController = OptionsViewController(account: account, configuration: configuration)
            optionsViewController.delegate = delegate
            viewController = optionsViewController
        case let .editAccount(account, delegate):
            let aViewController = EditAccountViewController(account: account, configuration: configuration)
            aViewController.delegate = delegate
            viewController = aViewController
        case .contactSelection:
            viewController = ContactSelectionViewController(configuration: configuration)
        case let .addContact(address, name):
            viewController = AddContactViewController(address: address, name: name, configuration: configuration)
        case let .editContact(contact):
            viewController = EditContactViewController(contact: contact, configuration: configuration)
        case let .contactDetail(contact):
            viewController = ContactDetailViewController(contact: contact, configuration: configuration)
        case .nodeSettings:
            viewController = NodeSettingsViewController(configuration: configuration)
        case let .transactionDetail(account, transaction, transactionType, assetDetail):
            viewController = TransactionDetailViewController(
                account: account,
                transaction: transaction,
                transactionType: transactionType,
                assetDetail: assetDetail,
                configuration: configuration
            )
        case let .assetDetail(draft):
            viewController = AssetDetailViewController(draft: draft, configuration: configuration)
        case let .algosDetail(draft):
            viewController = AlgosDetailViewController(draft: draft, configuration: configuration)
        case let .accountDetail(accountHandle, eventHandler):
            let aViewController = AccountDetailViewController(accountHandle: accountHandle, configuration: configuration)
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case let .assetSearch(accountHandle):
            viewController = AssetSearchViewController(accountHandle: accountHandle, configuration: configuration)
        case let .addAsset(account):
            viewController = AssetAdditionViewController(account: account, configuration: configuration)
        case .notifications:
            viewController = NotificationsViewController(configuration: configuration)
        case let .removeAsset(account):
            viewController = ManageAssetsViewController(account: account, configuration: configuration)
        case let .assetActionConfirmation(assetAlertDraft, delegate):
            let aViewController = AssetActionConfirmationViewController(draft: assetAlertDraft, configuration: configuration)
            aViewController.delegate = delegate
            viewController = aViewController
        case let .rewardDetail(account, calculatedRewards):
            viewController = RewardDetailViewController(
                account: account,
                calculatedRewards: calculatedRewards,
                configuration: configuration
            )
        case .verifiedAssetInformation:
            viewController = VerifiedAssetInformationViewController(configuration: configuration)
        case let .ledgerTutorial(flow):
            viewController = LedgerTutorialInstructionListViewController(accountSetupFlow: flow, configuration: configuration)
        case let .ledgerDeviceList(flow):
            viewController = LedgerDeviceListViewController(accountSetupFlow: flow, configuration: configuration)
        case let .ledgerApproval(mode, deviceName):
            viewController = LedgerApprovalViewController(mode: mode, deviceName: deviceName, configuration: configuration)
        case let .tutorialSteps(step):
            viewController = TutorialStepsViewController(
                step: step,
                configuration: configuration
            )
        case let .passphraseDisplay(address):
            viewController = PassphraseDisplayViewController(address: address, configuration: configuration)
        case .pinLimit:
            viewController = PinLimitViewController(configuration: configuration)
        case .assetActionConfirmationNotification,
                .assetDetailNotification:
            return nil
        case let .transactionFilter(filterOption, delegate):
            let transactionFilterViewController = TransactionFilterViewController(filterOption: filterOption, configuration: configuration)
            transactionFilterViewController.delegate = delegate
            viewController = transactionFilterViewController
        case let .transactionFilterCustomRange(fromDate, toDate):
            viewController = TransactionCustomRangeSelectionViewController(fromDate: fromDate, toDate: toDate, configuration: configuration)
        case let .rekeyInstruction(account):
            viewController = RekeyInstructionsViewController(account: account, configuration: configuration)
        case let .rekeyConfirmation(account, ledgerDetail, ledgerAddress):
            viewController = RekeyConfirmationViewController(
                account: account,
                ledger: ledgerDetail,
                ledgerAddress: ledgerAddress,
                configuration: configuration
            )
        case let .ledgerAccountSelection(flow, accounts):
            viewController = LedgerAccountSelectionViewController(
                accountSetupFlow: flow,
                accounts: accounts,
                configuration: configuration
            )
        case .walletRating:
            viewController = WalletRatingViewController(configuration: configuration)
        case .securitySettings:
            viewController = SecuritySettingsViewController(configuration: configuration)
        case .developerSettings:
            viewController = DeveloperSettingsViewController(configuration: configuration)
        case .currencySelection:
            viewController = CurrencySelectionViewController(configuration: configuration)
        case .appearanceSelection:
            viewController = AppearanceSelectionViewController(configuration: configuration)
        case let .watchAccountAddition(flow):
            viewController = WatchAccountAdditionViewController(accountSetupFlow: flow, configuration: configuration)
        case let .ledgerAccountDetail(account, index, rekeyedAccounts):
            viewController = LedgerAccountDetailViewController(
                account: account,
                ledgerIndex: index,
                rekeyedAccounts: rekeyedAccounts,
                configuration: configuration
            )
        case let .notificationFilter(flow):
            viewController = NotificationFilterViewController(flow: flow, configuration: configuration)
        case let .bottomWarning(viewModel):
            viewController = BottomWarningViewController(viewModel, configuration: configuration)
        case let .tutorial(flow, tutorial):
            viewController = TutorialViewController(
                flow: flow,
                tutorial: tutorial,
                configuration: configuration
            )
        case let .transactionTutorial(isInitialDisplay):
            viewController = TransactionTutorialViewController(isInitialDisplay: isInitialDisplay, configuration: configuration)
        case let .recoverOptions(delegate):
            let accountRecoverOptionsViewController = AccountRecoverOptionsViewController(configuration: configuration)
            accountRecoverOptionsViewController.delegate = delegate
            viewController = accountRecoverOptionsViewController
        case let .ledgerAccountVerification(flow, selectedAccounts):
            viewController = LedgerAccountVerificationViewController(
                accountSetupFlow: flow,
                selectedAccounts: selectedAccounts,
                configuration: configuration
            )
        case let .wcConnectionApproval(walletConnectSession, delegate, completion):
            let wcConnectionApprovalViewController = WCConnectionApprovalViewController(
                walletConnectSession: walletConnectSession,
                walletConnectSessionConnectionCompletionHandler: completion,
                configuration: configuration
            )
            wcConnectionApprovalViewController.delegate = delegate
            viewController = wcConnectionApprovalViewController
        case .walletConnectSessionList:
            viewController = WCSessionListViewController(configuration: configuration)
        case .walletConnectSessionShortList:
            viewController = WCSessionShortListViewController(configuration: configuration)
        case let .wcTransactionFullDappDetail(viewModel):
            viewController = WCTransactionFullDappDetailViewController(
                viewModel,
                configuration: configuration
            )
        case let .wcAlgosTransaction(transaction, transactionRequest):
            viewController = WCAlgosTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                configuration: configuration
            )
        case let .wcAssetTransaction(transaction, transactionRequest):
            viewController = WCAssetTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                configuration: configuration
            )
        case let .wcAssetAdditionTransaction(transaction, transactionRequest):
            viewController = WCAssetAdditionTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                configuration: configuration
            )
        case let .wcGroupTransaction(transactions, transactionRequest):
            viewController = WCGroupTransactionViewController(
                transactions: transactions,
                transactionRequest: transactionRequest,
                configuration: configuration
            )
        case let .wcAppCall(transaction, transactionRequest):
            viewController = WCAppCallTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                configuration: configuration
            )
        case let .wcAssetCreationTransaction(transaction, transactionRequest):
            viewController = WCAssetCreationTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                configuration: configuration
            )
        case let .wcAssetReconfigurationTransaction(transaction, transactionRequest):
            viewController = WCAssetReconfigurationTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                configuration: configuration
            )
        case let .wcAssetDeletionTransaction(transaction, transactionRequest):
            viewController = WCAssetDeletionTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                configuration: configuration
            )
        case let .jsonDisplay(jsonData, title):
            viewController = JSONDisplayViewController(jsonData: jsonData, title: title, configuration: configuration)
        case let .ledgerPairWarning(delegate):
            let ledgerPairWarningViewController = LedgerPairWarningViewController(configuration: configuration)
            ledgerPairWarningViewController.delegate = delegate
            viewController = ledgerPairWarningViewController
        case let .accountListOptions(accountType, eventHandler):
            let aViewController = AccountListOptionsViewController(accountType: accountType, configuration: configuration)
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case let .orderAccountList(accountType, eventHandler):
            let aViewController = OrderAccountListViewController(accountType: accountType, configuration: configuration)
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case let .accountSelection(transactionAction, delegate):
            let selectAccountViewController = SelectAccountViewController(
                dataController: SelectAccountAPIDataController(configuration.sharedDataController),
                transactionAction: transactionAction,
                configuration: configuration
            )
            selectAccountViewController.delegate = delegate
            viewController = selectAccountViewController
        case .assetSelection(let account):
            viewController = SelectAssetViewController(account: account, configuration: configuration)
        case .sendTransaction(let draft):
            let sendScreen = SendTransactionScreen(draft: draft, configuration: configuration)
            sendScreen.isModalInPresentation = true
            viewController = sendScreen
        case .editNote(let note, let isLocked, let delegate):
            let editNoteScreen = EditNoteScreen(note: note, isLocked: isLocked, configuration: configuration)
            editNoteScreen.delegate = delegate
            viewController = editNoteScreen
        case .portfolioCalculationInfo(let result, let eventHandler):
            let aViewController = PortfolioCalculationInfoViewController(result: result, configuration: configuration)
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case let .invalidAccount(account, uiInteractions):
            let aViewController = InvalidAccountOptionsViewController(account: account, configuration: configuration)
            aViewController.uiInteractions = uiInteractions
            viewController = aViewController
        case .transactionResult:
            let resultScreen = TransactionResultScreen(configuration: configuration)
            resultScreen.isModalInPresentation = false
            viewController = resultScreen
        case .transactionAccountSelect(let draft):
            viewController = AccountSelectScreen(draft: draft, configuration: configuration)
        case .sendTransactionPreview(let draft, let transactionController):
            viewController = SendTransactionPreviewScreen(
                draft: draft,
                transactionController: transactionController,
                configuration: configuration
            )
        case let .wcMainTransactionScreen(draft, delegate):
            let aViewController = WCMainTransactionScreen(draft: draft, configuration: configuration)
            aViewController.delegate = delegate
            viewController = aViewController
        case .transactionFloatingActionButton:
            viewController = TransactionFloatingActionButtonViewController(configuration: configuration)
        case let .wcSingleTransactionScreen(transactions, transactionRequest, transactionOption):
            let dataSource = WCMainTransactionDataSource(
                sharedDataController: configuration.sharedDataController,
                transactions: transactions,
                transactionRequest: transactionRequest,
                transactionOption: transactionOption,
                walletConnector: configuration.walletConnector
            )
            viewController = WCSingleTransactionRequestScreen(
                dataSource: dataSource,
                configuration: configuration
            )
        case .peraIntroduction:
            viewController = PeraIntroductionViewController(configuration: configuration)
        }

        return viewController as? T
    }
    // swiftlint:enable function_body_length
}

extension Router {
    func findVisibleScreen(
        over screen: UIViewController? = nil
    ) -> UIViewController {
        let topmostPresentedScreen =
            findVisibleScreen(
                presentedBy: screen ?? rootViewController
            )

        return findVisibleScreen(
            in: topmostPresentedScreen
        )
    }

    func findVisibleScreen(
        presentedBy screen: UIViewController
    ) -> UIViewController {
        var topmostPresentedScreen = screen

        while let nextPresentedScreen = topmostPresentedScreen.presentedViewController {
            topmostPresentedScreen = nextPresentedScreen
        }
        return topmostPresentedScreen
    }

    func findVisibleScreen(
        in screen: UIViewController
    ) -> UIViewController {
        switch screen {
        case let navigationContainer as UINavigationController:
            return findVisibleScreen(
                in: navigationContainer
            )
        case let tabbedContainer as TabbedContainer:
            return findVisibleScreen(
                in: tabbedContainer
            )
        default:
            return screen
        }
    }

    func findVisibleScreen(
        in navigationContainer: UINavigationController
    ) -> UIViewController {
        return navigationContainer.viewControllers.last ?? navigationContainer
    }

    func findVisibleScreen(
        in tabbedContainer: TabbedContainer
    ) -> UIViewController {
        guard let selectedScreen = tabbedContainer.selectedScreen else {
            return tabbedContainer
        }

        switch selectedScreen {
        case let navigationContainer as UINavigationController:
            return findVisibleScreen(
                in: navigationContainer
            )
        default:
            return selectedScreen
        }
    }
}

extension Router {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmedActionFor assetDetail: AssetInformation
    ) {
        let draft = assetActionConfirmationViewController.draft
        
        guard let account = draft.account else {
            return
        }
        
        let assetTransactionDraft =
            AssetTransactionSendDraft(from: account, assetIndex: Int64(draft.assetIndex))
        let transactionController = TransactionController(
            api: appConfiguration.api,
            bannerController: appConfiguration.bannerController
        )

        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)
    }
}

extension Router {
    func walletConnector(
        _ walletConnector: WalletConnector,
        shouldStart session: WalletConnectSession,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    ) {
        let sharedDataController = appConfiguration.sharedDataController
        let bannerController = appConfiguration.bannerController
        
        let hasNonWatchAccount = sharedDataController.accountCollection.contains {
            $0.value.type != .watch
        }
        
        if !hasNonWatchAccount {
            asyncMain { [weak bannerController] in
                bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "wallet-connect-session-error-no-account".localized
                )
            }
            return
        }

        asyncMain { [weak self] in
            guard let self = self else { return }
            
            let visibleScreen = self.findVisibleScreen(over: self.rootViewController)
            let transition = BottomSheetTransition(presentingViewController: visibleScreen)

            transition.perform(
                .wcConnectionApproval(
                    walletConnectSession: session,
                    delegate: self,
                    completion: completion
                ),
                by: .present
            )
            
            self.ongoingTransitions.append(transition)
        }
    }

    func walletConnector(
        _ walletConnector: WalletConnector,
        didConnectTo session: WCSession
    ) {
        walletConnector.saveConnectedWCSession(session)
    }
}

extension Router {
    func wcConnectionApprovalViewControllerDidApproveConnection(
        _ wcConnectionApprovalViewController: WCConnectionApprovalViewController
    ) {
        let dAppName = wcConnectionApprovalViewController.walletConnectSession.dAppInfo.peerMeta.name
        
        wcConnectionApprovalViewController.dismissScreen {
            [weak self] in
            guard let self = self else { return }
            
            self.presentWCSessionsApprovedModal(dAppName: dAppName)
        }
    }

    func wcConnectionApprovalViewControllerDidRejectConnection(
        _ wcConnectionApprovalViewController: WCConnectionApprovalViewController
    ) {
        wcConnectionApprovalViewController.dismissScreen()
    }
    
    private func presentWCSessionsApprovedModal(
        dAppName: String
    ) {
        let visibleScreen = self.findVisibleScreen(over: self.rootViewController)
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        transition.perform(
            .bottomWarning(
                configurator:
                    BottomWarningViewConfigurator(
                        image: "icon-approval-check".uiImage,
                        title: "wallet-connect-session-connection-approved-title".localized(dAppName),
                        description: "wallet-connect-session-connection-approved-description".localized(dAppName),
                        secondaryActionButtonTitle: "title-close".localized
                    )
            ),
            by: .presentWithoutNavigationController
        )
        
        ongoingTransitions.append(transition)
    }
}

extension Router {
    private func observeNotifications() {
        observe(notification: WalletConnector.didReceiveSessionRequestNotification) {
            [weak self] notification in
            guard let self = self else { return }
            
            let userInfoKey = WalletConnector.sessionRequestUserInfoKey
            let maybeSessionKey = notification.userInfo?[userInfoKey] as? String

            guard let sessionKey = maybeSessionKey else {
                return
            }
            
            let walletConnector = self.appConfiguration.walletConnector
            
            walletConnector.delegate = self
            walletConnector.connect(to: sessionKey)
        }
    }
}

extension Router: SelectAccountViewControllerDelegate {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for transactionAction: TransactionAction
    ) {
        guard let qrDraft = self.qrSendDraft else {
            return
        }

        let draft = SendTransactionDraft(
            from: account,
            toAccount: Account(address: qrDraft.toAccount, type: .standard),
            amount: qrDraft.amount,
            transactionMode: qrDraft.transactionMode,
            note: qrDraft.lockedNote,
            lockedNote: qrDraft.lockedNote
        )

        selectAccountViewController.open(.sendTransaction(draft: draft), by: .push)

        self.qrSendDraft = nil
    }
}
