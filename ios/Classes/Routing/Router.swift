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

import CoreServices
import Foundation
import MacaroonUIKit
import MacaroonUtils
import UIKit

final class Router:
    AssetActionConfirmationViewControllerDelegate,
    NotificationObserver,
    SelectAccountViewControllerDelegate,
    TransactionControllerDelegate,
    PeraConnectObserver
    {
    var notificationObservations: [NSObjectProtocol] = []
    
    unowned let rootViewController: RootViewController
    
    /// <todo>
    /// How to dealloc finished transitions?
    private var ongoingTransitions: [BottomSheetTransition] = []

    private unowned let appConfiguration: AppConfiguration

    private lazy var transactionController = TransactionController(
        api: appConfiguration.api,
        sharedDataController: appConfiguration.sharedDataController,
        bannerController: appConfiguration.bannerController,
        analytics: appConfiguration.analytics
    )

    /// <todo>
    /// Change after refactoring routing
    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?

    private var meldFlowCoordinator: MeldFlowCoordinator?


    init(
        rootViewController: RootViewController,
        appConfiguration: AppConfiguration
    ) {
        self.rootViewController = rootViewController
        self.appConfiguration = appConfiguration
        
        startObservingNotifications()
    }
    
    deinit {
        stopObservingNotifications()
    }
    
    func launchAuthorization() {
        if findVisibleScreen(over: rootViewController) is ChoosePasswordViewController {
            return
        }
        
        route(
            to: .choosePassword(mode: .login(flow: .app), flow: nil),
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
    
    func launchMain(completion: (() -> Void)? = nil) {
        rootViewController.launchTabsIfNeeded()
        rootViewController.dismissIfNeeded(animated: true, completion: completion)
    }
    
    func launcMainAfterAuthorization(
        presented viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        rootViewController.launchTabsIfNeeded()
        viewController.dismissScreen(completion: completion)
    }
    
    func launchWithBottomWarning(configurator: BottomWarningViewConfigurator) {
        func launch(
            tab: TabBarItemID
        ) {
            if rootViewController.presentedViewController == nil {
                rootViewController.launch(tab: tab)
            }
        }
        
        launch(tab: .home)
        
        let visibleScreen = findVisibleScreen(over: rootViewController)
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)
        
        transition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
        
        ongoingTransitions.append(transition)
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
        case .actionSelection(let address, let label):
            let visibleScreen = findVisibleScreen(over: rootViewController)
            let transition = BottomSheetTransition(presentingViewController: visibleScreen)

            let eventHandler: QRScanOptionsViewController.EventHandler = {
                [weak self] event in
                guard let self = self else { return }

                switch event {
                case .transaction:
                    launch(tab: .home)

                    var transactionDraft = SendTransactionDraft(
                        from: Account(),
                        transactionMode: .algo
                    )

                    let amount: UInt64 = 0
                    transactionDraft.amount = amount.toAlgos

                    let accountSelectDraft = SelectAccountDraft(
                        transactionAction: .send,
                        requiresAssetSelection: true,
                        transactionDraft: transactionDraft,
                        receiver: address
                    )

                    self.route(
                        to: .accountSelection(
                            draft: accountSelectDraft,
                            delegate: self
                        ),
                        from: self.findVisibleScreen(over: self.rootViewController),
                        by: .present
                    )

                case .watchAccount:
                    launch(tab: .home)

                    let session = self.appConfiguration.session

                    if let authenticatedUser = session.authenticatedUser,
                       authenticatedUser.hasReachedTotalAccountLimit {

                        let bannerController = self.appConfiguration.bannerController
                        bannerController.presentErrorBanner(
                            title: "user-account-limit-error-title".localized,
                            message: "user-account-limit-error-message".localized
                        )
                        return
                    }

                    self.route(
                        to: .watchAccountAddition(
                            flow: .addNewAccount(
                                mode: .watch
                            ),
                            address: address
                        ),
                        from: self.findVisibleScreen(over: self.rootViewController),
                        by: .present
                    )
                case .contact:
                    launch(tab: .home)

                    self.route(
                        to: .addContact(address: address, name: label),
                        from: self.findVisibleScreen(over: self.rootViewController),
                        by: .present
                    )
                }
            }

            transition.perform(
                .qrScanOptions(
                    address: address,
                    eventHandler: eventHandler
                ),
                by: .present
            )

            ongoingTransitions.append(transition)
        case .asaDiscoveryWithOptInAction: break /// <note> .assetActionConfirmation is used instead.
        case .asaDiscoveryWithOptOutAction(let account, let asset):
            launch(tab: .home)

            let visibleScreen = findVisibleScreen(over: rootViewController)
            let screen = Screen.asaDiscovery(
                account: account,
                quickAction: .optOut,
                asset: asset
            )

            route(
                to: screen,
                from: visibleScreen,
                by: .present
            )
        case .asaDetail(let account, let asset):
            launch(tab: .home)

            let screen = Screen.asaDetail(
                account: account,
                asset: asset
            )
            let visibleScreen = findVisibleScreen(over: rootViewController)
            route(
                to: screen,
                from: visibleScreen,
                by: .present
            )
        case .collectibleDetail(account: let account, asset: let asset):
            launch(tab: .home)

            let visibleScreen = findVisibleScreen(over: rootViewController)
            let screen = Screen.collectibleDetail(
                asset: asset,
                account: account
            )

            route(
                to: screen,
                from: visibleScreen,
                by: .present
            )
        case .assetActionConfirmation(let draft, let theme):
            let visibleScreen = findVisibleScreen(over: rootViewController)
            let transition = BottomSheetTransition(presentingViewController: visibleScreen)

            transition.perform(
                .assetActionConfirmation(
                    assetAlertDraft: draft,
                    delegate: self,
                    theme: theme
                ),
                by: .presentWithoutNavigationController
            )
            
            ongoingTransitions.append(transition)
        case .sendTransaction(let draft, let shouldFilterAccount):
            launch(tab: .home)

            let transactionDraft = SendTransactionDraft(
                from: Account(),
                toAccount: Account(address: draft.toAccount),
                amount: draft.amount,
                transactionMode: draft.transactionMode,
                note: draft.note,
                lockedNote: draft.lockedNote
            )

            let accountSelectDraft = SelectAccountDraft(
                transactionAction: .send,
                requiresAssetSelection: false,
                transactionDraft: transactionDraft
            )

            route(
                to: .accountSelection(
                        draft: accountSelectDraft,
                        delegate: self,
                        shouldFilterAccount: shouldFilterAccount
                ),
                from: findVisibleScreen(over: rootViewController),
                by: .present
            )

        case .wcMainTransactionScreen(let draft):
            let task = {
                [weak self] in
                guard let self else { return }

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

            /// <note>
            /// Refactor
            /// This delay should be removed after refactoring the router.
            /// A delay has been added to ensure that the screen is not presented
            /// before the top view controller's view is added to the window's hierarchy.
            /// If the top view controller's view is not in the hierarchy, UIKit will not
            /// present the WC Transaction screen.
            /// Error: Attempt to present <*> on <*> (from <*>) whose view is not in the window hierarchy.
            let delay = 0.3
            let time: DispatchTime = .now() + delay
            let queue: DispatchQueue = .main
            queue.asyncAfter(deadline: time) {
                task()
            }
        case .wcMainArbitraryDataScreen(let draft):
            let task = {
                [weak self] in
                guard let self else { return }

                route(
                    to: .wcMainArbitraryDataScreen(
                        draft: draft,
                        delegate: rootViewController
                    ),
                    from: findVisibleScreen(over: rootViewController),
                    by: .customPresent(
                        presentationStyle: .fullScreen,
                        transitionStyle: nil,
                        transitioningDelegate: nil
                    ),
                    animated: true
                )
            }

            /// <note>
            /// Refactor
            /// This delay should be removed after refactoring the router.
            /// A delay has been added to ensure that the screen is not presented
            /// before the top view controller's view is added to the window's hierarchy.
            /// If the top view controller's view is not in the hierarchy, UIKit will not
            /// present the WC Transaction screen.
            /// Error: Attempt to present <*> on <*> (from <*>) whose view is not in the window hierarchy.
            let delay = 0.3
            let time: DispatchTime = .now() + delay
            let queue: DispatchQueue = .main
            queue.asyncAfter(deadline: time) {
                task()
            }
        case .buyAlgoWithMeld(let draft):
            let visibleScreen = findVisibleScreen(over: rootViewController)
            
            
            let meldFlowCoordinator = MeldFlowCoordinator(
                analytics: appConfiguration.analytics,
                presentingScreen: visibleScreen
            )
            self.meldFlowCoordinator = meldFlowCoordinator
          
            meldFlowCoordinator.launch(draft)
        case .accountSelect(let asset):
            launch(tab: .home)

            let accountSelectDraft = SelectAccountDraft(
                transactionAction: .optIn(asset: asset),
                requiresAssetSelection: false
            )

            route(
                to: .accountSelection(draft: accountSelectDraft, delegate: self),
                from: findVisibleScreen(over: rootViewController),
                by: .present
            )
        case .externalInAppBrowser(let destination):
            let inAppBrowser = route(
                to: .externalInAppBrowser(destination: destination),
                from: findVisibleScreen(over: rootViewController),
                by: .present
            ) as? DiscoverExternalInAppBrowserScreen
            inAppBrowser?.eventHandler = {
                [weak inAppBrowser] event in
                switch event {
                case .goBack:
                    inAppBrowser?.dismiss(animated: true)
                default: break
                }
            }
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
        case .root:
            if let currentViewController = self as? StatusBarConfigurable,
               let nextViewController = viewController as? StatusBarConfigurable {

                let isStatusBarHidden = currentViewController.isStatusBarHidden

                nextViewController.hidesStatusBarWhenAppeared = isStatusBarHidden
                nextViewController.isStatusBarHidden = isStatusBarHidden
            }

            guard let navigationController = sourceViewController.navigationController else {
                return nil
            }

            navigationController.setViewControllers([viewController], animated: animated)
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
            
            let navigationController: NavigationContainer
            
            if let navController = viewController as? NavigationContainer {
                navigationController = navController
            } else {
                if let presentingViewController = self as? StatusBarConfigurable,
                   let presentedViewController = viewController as? StatusBarConfigurable,
                   presentingViewController.isStatusBarHidden {
                    
                    presentedViewController.hidesStatusBarWhenPresented = true
                    presentedViewController.isStatusBarHidden = true
                }
                
                navigationController = NavigationContainer(rootViewController: viewController)
            }
            
            navigationController.modalPresentationStyle = .fullScreen
            
            rootViewController.present(navigationController, animated: false, completion: completion)
        case .present,
                .customPresent:
            let navigationController: NavigationContainer
            
            if let navController = viewController as? NavigationContainer {
                navigationController = navController
            } else {
                if let presentingViewController = self as? StatusBarConfigurable,
                   let presentedViewController = viewController as? StatusBarConfigurable,
                   presentingViewController.isStatusBarHidden {
                    
                    presentedViewController.hidesStatusBarWhenPresented = true
                    presentedViewController.isStatusBarHidden = true
                }
                
                navigationController = NavigationContainer(rootViewController: viewController)
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
        case .asaDetail(let account, let asset, let screenConfiguration):
            let dataController = ASADetailScreenAPIDataController(
                account: account,
                asset: asset,
                api: appConfiguration.api,
                sharedDataController: appConfiguration.sharedDataController,
                configuration: screenConfiguration
            )
            let copyToClipboardController = ALGCopyToClipboardController(
                toastPresentationController: appConfiguration.toastPresentationController
            )
            let aViewController = ASADetailScreen(
                swapDataStore: SwapDataLocalStore(),
                dataController: dataController,
                copyToClipboardController: copyToClipboardController,
                configuration: configuration
            )
            viewController = aViewController
        case .asaDiscovery(let account, let quickAction, let asset, let eventHandler):
            let dataController =
                ASADiscoveryScreenAPIDataController(
                    account: account,
                    asset: asset,
                    api: appConfiguration.api,
                    sharedDataController: appConfiguration.sharedDataController
                )
            let copyToClipboardController = ALGCopyToClipboardController(
                toastPresentationController: appConfiguration.toastPresentationController
            )
            let aViewController = ASADiscoveryScreen(
                quickAction: quickAction,
                dataController: dataController,
                copyToClipboardController: copyToClipboardController,
                configuration: configuration
            )
            aViewController.eventHandler = eventHandler

            viewController = aViewController
        case let .welcome(flow):
            viewController = WelcomeViewController(flow: flow, configuration: configuration)
        case let .recoverAccount(flow):
            viewController = RecoverAccountViewController(flow: flow, configuration: configuration)
        case let .choosePassword(mode, flow):
            viewController = ChoosePasswordViewController(
                mode: mode,
                accountSetupFlow: flow,
                configuration: configuration
            )
        case let .passphraseView(flow, address):
            viewController = PassphraseBackUpViewController(
                flow: flow,
                address: address,
                configuration: configuration
            )
        case let .passphraseVerify(flow, address):
            viewController = PassphraseVerifyViewController(
                address: address,
                flow: flow,
                configuration: configuration
            )
        case let .accountNameSetup(flow, mode, nameServiceName, accountAddress):
            viewController = AccountNameSetupViewController(
                flow: flow,
                mode: mode,
                nameServiceName: nameServiceName,
                accountAddress: accountAddress,
                configuration: configuration
            )
        case let .accountRecover(flow, initialMnemonic):
            viewController = AccountRecoverViewController(
                accountSetupFlow: flow,
                initialMnemonic: initialMnemonic,
                configuration: configuration
            )
        case let .qrScanner(canReadWCSession):
            viewController = QRScannerViewController(
                canReadWCSession: canReadWCSession,
                configuration: configuration
            )
        case let .qrGenerator(title, draft, isTrackable):
            let qrCreationController = QRCreationViewController(
                draft: draft,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration,
                isTrackable: isTrackable
            )
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
        case .contacts:
            viewController = ContactsViewController(configuration: configuration)
        case let .renameAccount(account, delegate):
            let aViewController = RenameAccountScreen(account: account, configuration: configuration)
            aViewController.delegate = delegate
            viewController = aViewController
        case let .addContact(address, name):
            viewController = AddContactViewController(address: address, name: name, configuration: configuration)
        case let .editContact(contact):
            viewController = EditContactViewController(contact: contact, configuration: configuration)
        case let .contactDetail(contact):
            viewController = ContactDetailViewController(contact: contact, configuration: configuration)
        case .nodeSettings:
            viewController = NodeSettingsViewController(configuration: configuration)
        case let .transactionDetail(account, transaction, assetDetail):
            let transactionType =
            transaction.sender == account.address
            ? TransferType.sent
            : .received

            viewController = TransactionDetailViewController(
                account: account,
                transaction: transaction,
                transactionType: transactionType,
                assetDetail: assetDetail,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
        case let .appCallTransactionDetail(
            account,
            transaction,
            transactionTypeFilter,
            assets
        ):
            viewController = AppCallTransactionDetailViewController(
                account: account,
                transaction: transaction,
                transactionTypeFilter: transactionTypeFilter,
                assets: assets,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
        case .appCallAssetList(let dataController):
            viewController = AppCallAssetListViewController(
                dataController: dataController,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
        case .keyRegTransactionDetail(let account, let transaction):
            viewController = KeyRegTransactionDetailViewController(
                account: account,
                transaction: transaction,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
        case let .accountDetail(accountHandle, eventHandler):
            let aViewController = AccountDetailViewController(
                accountHandle: accountHandle,
                dataController: AccountDetailAPIDataController(
                    account: accountHandle,
                    sharedDataController: appConfiguration.sharedDataController
                ),
                swapDataStore: SwapDataLocalStore(),
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case let .addAsset(account):
            let dataController = AssetListViewAPIDataController(
                account: account,
                api: appConfiguration.api,
                sharedDataController: appConfiguration.sharedDataController
            )
            viewController = AssetAdditionViewController(
                dataController: dataController,
                configuration: configuration
            )
        case .notifications:
            viewController = NotificationsViewController(configuration: configuration)
        case let .removeAsset(dataController):
            let query = ManageAssetListQuery(
                sortingBy: appConfiguration.sharedDataController.selectedAccountAssetSortingAlgorithm
            )
            viewController = ManageAssetListViewController(
                query: query,
                dataController: dataController,
                configuration: configuration
            )
        case let .managementOptions(managementType, delegate):
            let managementOptionsViewController = ManagementOptionsViewController(managementType: managementType, configuration: configuration)
            managementOptionsViewController.delegate = delegate
            viewController = managementOptionsViewController
        case let .assetActionConfirmation(assetAlertDraft, delegate, theme):
            let aViewController = AssetActionConfirmationViewController(
                draft: assetAlertDraft,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                api: appConfiguration.api,
                sharedDataController: appConfiguration.sharedDataController,
                bannerController: appConfiguration.bannerController,
                theme: theme
            )
            aViewController.delegate = delegate
            viewController = aViewController
        case let .rewardDetail(account):
            viewController = RewardDetailViewController(
                account: account,
                configuration: configuration
            )
        case let .ledgerTutorial(flow):
            viewController = LedgerTutorialInstructionListViewController(accountSetupFlow: flow, configuration: configuration)
        case let .ledgerDeviceList(flow):
            viewController = LedgerDeviceListViewController(accountSetupFlow: flow, configuration: configuration)
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
        case let .rekeyToLedgerAccountInstructions(sourceAccount):
            let draft = RekeyToLedgerAccountInstructionsDraft(sourceAccount: sourceAccount)
            viewController = RekeyInstructionsScreen(
                draft: draft,
                api: configuration.api
            )
        case let .rekeyToStandardAccountInstructions(sourceAccount):
            let draft = RekeyToStandardAccountInstructionsDraft(sourceAccount: sourceAccount)
            viewController = RekeyInstructionsScreen(
                draft: draft,
                api: configuration.api
            )
        case let .rekeyConfirmation(sourceAccount, authAccount, newAuthAccount):
            viewController = RekeyConfirmationScreen(
                sourceAccount: sourceAccount,
                authAccount: authAccount,
                newAuthAccount: newAuthAccount,
                api: configuration.api!,
                session: configuration.session!,
                sharedDataController: configuration.sharedDataController,
                bannerController: configuration.bannerController!,
                loadingController: configuration.loadingController!,
                analytics: configuration.analytics
            )
        case let .rekeySuccess(sourceAccount, eventHandler):
            let aViewController = RekeySuccessScreen(
                sourceAccount: sourceAccount,
                api: configuration.api!
            )
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case let .undoRekey(sourceAccount, authAccount):
            viewController = UndoRekeyScreen(
                sourceAccount: sourceAccount,
                authAccount: authAccount,
                newAuthAccount: sourceAccount,
                api: configuration.api!,
                session: configuration.session!,
                sharedDataController: configuration.sharedDataController,
                bannerController: configuration.bannerController!,
                loadingController: configuration.loadingController!,
                analytics: configuration.analytics
            )
        case let .undoRekeySuccess(sourceAccount, eventHandler):
            let aViewController = UndoRekeySuccessScreen(
                sourceAccount: sourceAccount,
                api: configuration.api!
            )
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case let .rekeyAccountSelection(eventHandler, account):
            var theme = AccountSelectionListScreenTheme()
            theme.listContentTopInset = 16

            let listView: UICollectionView = {
                let collectionViewLayout = RekeyAccountSelectionListLayout.build()
                let collectionView = UICollectionView(
                    frame: .zero,
                    collectionViewLayout: collectionViewLayout
                )
                collectionView.showsVerticalScrollIndicator = false
                collectionView.showsHorizontalScrollIndicator = false
                collectionView.alwaysBounceVertical = true
                collectionView.backgroundColor = .clear
                return collectionView
            }()

            let dataController = RekeyAccountSelectionListLocalDataController(
                sharedDataController: configuration.sharedDataController,
                session: configuration.session!,
                account: account
            )

            let dataSource = RekeyAccountSelectionListDataSource(dataController)
            let diffableDataSource = UICollectionViewDiffableDataSource<RekeyAccountSelectionListSectionIdentifier, RekeyAccountSelectionListItemIdentifier>(
                collectionView: listView,
                cellProvider: dataSource.getCellProvider()
            )
            diffableDataSource.supplementaryViewProvider = dataSource.getSupplementaryViewProvider(diffableDataSource)
            dataSource.registerSupportedCells(listView)
            dataSource.registerSupportedSupplementaryViews(listView)

            viewController = AccountSelectionListScreen(
                navigationBarTitle: "title-select-account".localized,
                listView: listView,
                dataController: dataController,
                listLayout: RekeyAccountSelectionListLayout(
                    dataSource: diffableDataSource,
                    itemDataSource: dataController
                ),
                listDataSource: diffableDataSource,
                theme: theme,
                eventHandler: eventHandler,
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
            viewController = CurrencySelectionViewController(
                dataController: CurrencySelectionListAPIDataController(
                    sharedDataController: appConfiguration.sharedDataController,
                    api: appConfiguration.api
                ),
                configuration: configuration
            )
        case .appearanceSelection:
            viewController = AppearanceSelectionViewController(configuration: configuration)
        case let .watchAccountAddition(flow, address):
            let pushNotificationController = PushNotificationController(
                target: ALGAppTarget.current,
                session: appConfiguration.session,
                api: appConfiguration.api
            )
            let dataController = WatchAccountAdditionAPIDataController(
                sharedDataController: appConfiguration.sharedDataController,
                api: appConfiguration.api,
                session: appConfiguration.session,
                pushNotificationController: pushNotificationController,
                analytics: appConfiguration.analytics
            )
            viewController = WatchAccountAdditionViewController(
                accountSetupFlow: flow,
                address: address,
                dataController:dataController,
                configuration: configuration
            )
        case let .ledgerAccountDetail(account, authAccount, index, rekeyedAccounts):
            viewController = LedgerAccountDetailViewController(
                account: account,
                authAccount: authAccount,
                ledgerIndex: index,
                rekeyedAccounts: rekeyedAccounts,
                configuration: configuration
            )
        case .notificationFilter:
            viewController = NotificationFilterViewController(configuration: configuration)
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
        case let .wcConnection(draft):
            let dataController = WCSessionConnectionLocalDataController(
                draft: draft,
                sharedDataController: appConfiguration.sharedDataController
            )
            let screen = WCSessionConnectionScreen(
                draft: draft,
                dataController: dataController,
                configuration: configuration
            )
            viewController = screen
        case .walletConnectSessionList:
            let dataController = WCSessionListLocalDataController(
                sharedDataController: configuration.sharedDataController,
                analytics: configuration.analytics,
                peraConnect: configuration.peraConnect
            )
            viewController = WCSessionListViewController(
                dataController: dataController,
                configuration: configuration
            )
        case .walletConnectSessionShortList:
            viewController = WCSessionShortListViewController(configuration: configuration)
        case let .wcTransactionFullDappDetail(viewModel):
            viewController = WCTransactionFullDappDetailViewController(
                viewModel,
                configuration: configuration
            )
        case let .wcAlgosTransaction(transaction, transactionRequest, wcSession):
            viewController = WCAlgosTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                session: wcSession,
                configuration: configuration
            )
        case let .wcAssetTransaction(transaction, transactionRequest, wcSession):
            viewController = WCAssetTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                session: wcSession,
                configuration: configuration
            )
        case let .wcAssetAdditionTransaction(transaction, transactionRequest, wcSession):
            viewController = WCAssetAdditionTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                session: wcSession,
                configuration: configuration
            )
        case let .wcGroupTransaction(transactions, transactionRequest, wcSession):
            viewController = WCGroupTransactionViewController(
                transactions: transactions,
                transactionRequest: transactionRequest,
                session: wcSession,
                configuration: configuration
            )
        case let .wcAppCall(transaction, transactionRequest, wcSession):
            viewController = WCAppCallTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                session: wcSession,
                configuration: configuration
            )
        case let .wcAssetCreationTransaction(transaction, transactionRequest, wcSession):
            viewController = WCAssetCreationTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                session: wcSession,
                configuration: configuration
            )
        case let .wcAssetReconfigurationTransaction(transaction, transactionRequest, wcSession):
            viewController = WCAssetReconfigurationTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                session: wcSession,
                configuration: configuration
            )
        case let .wcAssetDeletionTransaction(transaction, transactionRequest, wcSession):
            viewController = WCAssetDeletionTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                session: wcSession,
                configuration: configuration
            )
        case let .wcKeyRegTransaction(transaction, transactionRequest, wcSession):
            viewController = WCKeyRegTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                session: wcSession,
                configuration: configuration
            )
        case let .jsonDisplay(jsonData, title):
            let copyToClipboardController = ALGCopyToClipboardController(
                toastPresentationController: appConfiguration.toastPresentationController
            )
            viewController = JSONDisplayViewController(
                jsonData: jsonData,
                title: title,
                copyToClipboardController: copyToClipboardController,
                configuration: configuration
            )
        case let .ledgerPairWarning(delegate):
            let ledgerPairWarningViewController = LedgerPairWarningViewController(configuration: configuration)
            ledgerPairWarningViewController.delegate = delegate
            viewController = ledgerPairWarningViewController
        case let .sortAccountList(dataController, eventHandler):
            let aViewController  = SortAccountListViewController(
                dataController: dataController,
                configuration: configuration
            )
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case let .accountSelection(draft, delegate, shouldFilterAccount):
            let dataController = SelectAccountAPIDataController(
                configuration.sharedDataController,
                transactionAction: draft.transactionAction
            )
            dataController.shouldFilterAccount = shouldFilterAccount
            let selectAccountViewController = SelectAccountViewController(
                dataController: dataController,
                draft: draft,
                configuration: configuration
            )
            selectAccountViewController.delegate = delegate
            viewController = selectAccountViewController
        case .assetSelection(let account, let receiver):
            viewController = SelectAssetViewController(
                account: account,
                receiver: receiver,
                configuration: configuration
            )
        case .sendTransaction(let draft):
            let sendScreen = SendTransactionScreen(
                draft: draft,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
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
            resultScreen.isModalInPresentation = true
            viewController = resultScreen
        case .sendTransactionPreview(let draft):
            viewController = SendTransactionPreviewScreen(
                draft: draft,
                configuration: configuration
            )
        case let .wcMainTransactionScreen(draft, delegate):
            let aViewController = WCMainTransactionScreen(
                draft: draft,
                configuration: configuration
            )
            aViewController.delegate = delegate
            viewController = aViewController
        case let .wcMainArbitraryDataScreen(draft, delegate):
            let aViewController = WCMainArbitraryDataScreen(
                draft: draft,
                configuration: configuration
            )
            aViewController.delegate = delegate
            viewController = aViewController
        case let .wcArbitraryDataScreen(data, wcSession):
            viewController = WCArbitraryDataViewController(
                data: data,
                wcSession: wcSession,
                configuration: configuration
            )
        case .asaVerificationInfo(let eventHandler):
            let aViewController = AsaVerificationInfoScreen(api: configuration.api)
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case let .sortCollectibleList(dataController, eventHandler):
            let aViewController = SortCollectibleListViewController(
                dataController: dataController,
                configuration: configuration
            )
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case let .collectiblesFilterSelection(uiInteractions):
            let aViewController = CollectiblesFilterSelectionViewController(api: configuration.api)
            aViewController.uiInteractions = uiInteractions
            viewController = aViewController
        case let .accountCollectibleListFilterSelection(uiInteractions):
            let aViewController = AccountCollectibleListFilterSelectionViewController(api: configuration.api)
            aViewController.uiInteractions = uiInteractions
            viewController = aViewController
        case let .receiveCollectibleAccountList(dataController):
            viewController = ReceiveCollectibleAccountListViewController(
                dataController: dataController,
                configuration: configuration
            )
        case let .receiveCollectibleAssetList(account):
            let dataController = ReceiveCollectibleAssetListAPIDataController(
                account: account.value,
                api: appConfiguration.api,
                sharedDataController: appConfiguration.sharedDataController
            )
            viewController = ReceiveCollectibleAssetListViewController(
                dataController: dataController,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
        case .collectibleDetail(let asset, let account, let thumbnailImage,  let quickAction, let eventHandler):
            let aViewController = CollectibleDetailViewController(
                asset: asset,
                account: account,
                quickAction: quickAction,
                thumbnailImage: thumbnailImage,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
            aViewController.eventHandler = eventHandler

            viewController = aViewController
        case let .sendCollectible(draft):
            let aViewController = SendCollectibleViewController(
                draft: draft,
                configuration: configuration
            )
            viewController = aViewController
        case let .sendCollectibleReceiverAccountSelectionList(addressInputViewText):
            let dataController = ReceiverAccountSelectionListAPIDataController(
                sharedDataController: appConfiguration.sharedDataController,
                api: appConfiguration.api,
                addressInputViewText: addressInputViewText
            )
            let aViewController = ReceiverAccountSelectionListScreen(
                dataController: dataController,
                configuration: configuration
            )
            aViewController.navigationItem.title = "collectible-send-account-list-title".localized
            viewController = aViewController
        case let .sendAssetReceiverAccountSelectionList(asset, addressInputViewText):
            let dataController = ReceiverAccountSelectionListAPIDataController(
                sharedDataController: appConfiguration.sharedDataController,
                api: appConfiguration.api,
                addressInputViewText: addressInputViewText
            )
            let aViewController = ReceiverAccountSelectionListScreen(
                dataController: dataController,
                configuration: configuration
            )
            let titleView = AssetDetailTitleView()
            titleView.customize(AssetDetailTitleViewTheme())
            titleView.bindData(AssetDetailTitleViewModel(asset))
            aViewController.navigationItem.titleView = titleView

            viewController = aViewController
        case let .approveCollectibleTransaction(draft):
            viewController = ApproveCollectibleTransactionViewController(
                draft: draft,
                configuration: configuration
            )
        case let .shareActivity(items):
            let activityController = UIActivityViewController(
                activityItems: items,
                applicationActivities: nil
            )

            activityController.excludedActivityTypes = [
                UIActivity.ActivityType.addToReadingList
            ]

            viewController = activityController
        case .image3DCard(let image, let rendersContinuously):
            viewController = Collectible3DImageViewController(
                image: image,
                rendersContinuously: rendersContinuously,
                configuration: configuration
            )
        case .video3DCard(let image, let url):
            viewController = Collectible3DVideoViewController(
                image: image,
                url: url,
                configuration: configuration
            )
        case .collectibleFullScreenImage(let draft):
            viewController = CollectibleFullScreenImageViewController(
                draft: draft,
                configuration: configuration
            )
        case .collectibleFullScreenVideo(let draft):
            viewController = CollectibleFullScreenVideoViewController(
                draft: draft,
                configuration: configuration
            )
        case .transactionOptions(let account, let delegate):
            let aViewController = TransactionOptionsScreen(
                account: account,
                configuration: configuration
            )
            aViewController.delegate = delegate
            viewController = aViewController
        case .qrScanOptions(let address, let eventHandler):
            let screen = QRScanOptionsViewController(
                address: address,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
            screen.eventHandler = eventHandler
            viewController = screen
        case let .assetsFilterSelection(uiInteractions):
            let aViewController = AssetsFilterSelectionViewController(api: configuration.api)
            aViewController.uiInteractions = uiInteractions
            viewController = aViewController
        case .sortAccountAsset(let dataController, let eventHandler):
            let aViewController = SortAccountAssetListViewController(
                dataController: dataController,
                configuration: configuration
            )
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case .innerTransactionList(let dataController, let eventHandler):
            let aViewController = InnerTransactionListViewController(
                dataController: dataController,
                configuration: configuration
            )
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case .swapAsset(let dataStore, let swapController, let coordinator):
            let dataController = SwapAssetAPIDataController(
                dataStore: dataStore,
                swapController: swapController,
                api: appConfiguration.api,
                sharedDataController: appConfiguration.sharedDataController
            )

            viewController = SwapAssetScreen(
                dataStore: dataStore,
                dataController: dataController,
                coordinator: coordinator,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
        case .swapAccountSelection(let swapAssetFlowCoordinator, let eventHandler):
            var theme = AccountSelectionListScreenTheme()
            theme.listContentTopInset = 16

            let listView: UICollectionView = {
                let collectionViewLayout = SwapAccountSelectionListLayout.build()
                let collectionView = UICollectionView(
                    frame: .zero,
                    collectionViewLayout: collectionViewLayout
                )
                collectionView.showsVerticalScrollIndicator = false
                collectionView.showsHorizontalScrollIndicator = false
                collectionView.alwaysBounceVertical = true
                collectionView.backgroundColor = .clear
                return collectionView
            }()

            let dataController = SwapAccountSelectionListLocalDataController(sharedDataController: configuration.sharedDataController)

            let dataSource = SwapAccountSelectionListDataSource(dataController)
            let diffableDataSource = UICollectionViewDiffableDataSource<SwapAccountSelectionListSectionIdentifier, SwapAccountSelectionListItemIdentifier>(
                collectionView: listView,
                cellProvider: dataSource.getCellProvider()
            )
            diffableDataSource.supplementaryViewProvider = dataSource.getSupplementaryViewProvider(diffableDataSource)
            dataSource.registerSupportedCells(listView)
            dataSource.registerSupportedSupplementaryViews(listView)

            viewController = SwapAccountSelectionListScreen(
                navigationBarTitle: "title-select-account".localized,
                listView: listView,
                dataController: dataController,
                listLayout: SwapAccountSelectionListLayout(
                    dataSource: diffableDataSource,
                    itemDataSource: dataController
                ),
                listDataSource: diffableDataSource,
                swapAssetFlowCoordinator: swapAssetFlowCoordinator,
                theme: theme,
                eventHandler: eventHandler,
                configuration: configuration
            )
        case .ledgerConnection(let eventHandler):
            viewController = LedgerConnectionScreen(eventHandler: eventHandler)
        case .signWithLedgerProcess(let draft, let eventHandler):
            viewController = SignWithLedgerProcessScreen(
                draft: draft,
                eventHandler: eventHandler,
                api: configuration.api
            )
        case .loading(let viewModel, let theme):
            viewController = LoadingScreen(
                viewModel: viewModel,
                theme: theme,
                configuration: configuration
            )
        case .error(let viewModel, let theme):
            viewController = ErrorScreen(
                viewModel: viewModel,
                theme: theme,
                configuration: configuration
            )
        case .swapSuccess(let swapController, let theme):
            viewController = SwapAssetSuccessScreen(
                swapController: swapController,
                theme: theme,
                configuration: configuration
            )
        case .swapSummary(let swapController, let theme):
            viewController = SwapSummaryScreen(
                swapController: swapController,
                theme: theme,
                api: configuration.api
            )
        case .alert(let alert):
            viewController = AlertScreen(
                alert: alert,
                api: configuration.api
            )
        case .swapIntroduction(let draft, let eventHandler):
            let aViewController = SwapIntroductionScreen(
                draft: draft,
                api: configuration.api
            )
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case .optInAsset(let draft, let eventHandler):
            let copyToClipboardController = ALGCopyToClipboardController(
                toastPresentationController: appConfiguration.toastPresentationController
            )
            viewController = OptInAssetScreen(
                draft: draft,
                copyToClipboardController: copyToClipboardController,
                eventHandler: eventHandler,
                api: configuration.api
            )
        case .optOutAsset(let draft, let theme, let eventHandler):
            viewController = OptOutAssetScreen(
                theme: theme,
                draft: draft,
                eventHandler: eventHandler,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                api: configuration.api
            )
        case .transferAssetBalance(let draft, let theme, let eventHandler):
            viewController = TransferAssetBalanceScreen(
                theme: theme,
                draft: draft,
                eventHandler: eventHandler,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                api: configuration.api
            )
        case .sheetAction(let sheet, let theme):
            viewController = UISheetActionScreen(
                sheet: sheet,
                theme: theme,
                api: configuration.api
            )
        case .insufficientAlgoBalance(let draft, let eventHandler):
            viewController = InsufficientAlgoBalanceScreen(
                draft: draft,
                eventHandler: eventHandler,
                api: configuration.api
            )
        case .selectAsset(let dataController, let coordinator, let title, let theme):
            let aViewController = SelectAssetScreen(
                dataController: dataController,
                coordinator: coordinator,
                theme: theme,
                configuration: configuration
            )

            aViewController.title = title
            viewController = aViewController
        case .confirmSwap(let dataStore, let dataController, let eventHandler, let theme):
            let screen = ConfirmSwapScreen(
                dataStore: dataStore,
                dataController: dataController,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                theme: theme,
                configuration: configuration
            )
            screen.eventHandler = eventHandler
            viewController = screen
        case .editSwapAmount(let dataStore, let eventHandler):
            let aViewController = EditSwapAmountScreen(
                dataStore: dataStore,
                dataProvider: EditSwapAmountLocalDataProvider(dataStore: dataStore),
                configuration: configuration
            )
            aViewController.eventHandler = eventHandler

            viewController = aViewController
        case .editSwapSlippage(let dataStore, let eventHandler):
            let aViewController = EditSwapSlippageScreen(
                dataStore: dataStore,
                dataProvider: EditSwapSlippageToleranceLocalDataProvider(dataStore: dataStore),
                configuration: configuration
            )
            aViewController.eventHandler = eventHandler

            viewController = aViewController
        case .discoverSearch(let eventHandler):
            let screen = DiscoverSearchScreen(
                dataController: DiscoverSearchAPIDataController(
                    api: appConfiguration.api,
                    sharedDataController: appConfiguration.sharedDataController
                ),
                configuration: configuration
            )
            screen.eventHandler = eventHandler
            viewController = screen
        case .discoverAssetDetail(let parameters):
            viewController = DiscoverAssetDetailScreen(
                assetParameters: parameters,
                swapDataStore: SwapDataLocalStore(),
                configuration: configuration
            )
        case .discoverDappDetail(let dappParameters, let eventHandler):
            let screen = DiscoverDappDetailScreen(
                dappParameters: dappParameters,
                configuration: configuration
            )
            screen.eventHandler = eventHandler
            viewController = screen
        case .discoverGeneric(let params):
            viewController = DiscoverGenericScreen(
                params: params,
                configuration: configuration
            )
        case .importAccountIntroduction(let eventHandler):
            let screen = WebImportInstructionScreen(api: configuration.api)
            screen.eventHandler = eventHandler
            viewController = screen
        case .importAccountQRScanner(let eventHandler):
            let screen = ImportQRScannerScreen(configuration: configuration)
            screen.eventHandler = eventHandler
            viewController = screen
        case let .importAccount(backupParameters, eventHandler):
            let screen = ImportAccountScreen(configuration: configuration, backupParameters: backupParameters)
            screen.eventHandler = eventHandler
            viewController = screen
        case .importAccountError(let error, let eventHandler):
            let screen = WebImportErrorScreen(
                error: error,
                api: configuration.api
            )
            screen.eventHandler = eventHandler
            viewController = screen
        case let .importAccountSuccess(result, eventHandler):
            let dataController = WebImportSuccessScreenLocalDataController(
                result: result
            )
            let screen = WebImportSuccessScreen(
                dataController: dataController,
                configuration: configuration
            )
            screen.eventHandler = eventHandler
            viewController = screen
        case .algorandSecureBackupInstructions(let eventHandler):
            let screen = AlgorandSecureBackupInstructionsScreen(configuration: configuration)
            screen.eventHandler = eventHandler
            viewController = screen
        case .algorandSecureBackupAccountList(let eventHandler):
            let dataController = AlgorandSecureBackupAccountListLocalDataController(
                sharedDataController: appConfiguration.sharedDataController
            )
            let screen = AlgorandSecureBackupAccountExportListScreen(
                dataController: dataController,
                configuration: configuration
            )
            screen.eventHandler = eventHandler
            viewController = screen
        case let .algorandSecureBackupMnemonic(accounts, eventHandler):
            let screen = AlgorandSecureBackupMnemonicsScreen(accounts: accounts, configuration: configuration)
            screen.eventHandler = eventHandler
            viewController = screen
        case let .algorandSecureBackupSuccess(backup, eventHandler):
            let screen = AlgorandSecureBackupSuccessScreen(backup: backup, configuration: configuration)
            screen.eventHandler = eventHandler
            viewController = screen
        case .algorandSecureBackupError(let eventHandler):
            let screen = AlgorandSecureBackupErrorScreen(api: configuration.api)
            screen.eventHandler = eventHandler
            viewController = screen
        case .algorandSecureBackupImportBackup(let eventHandler):
            let screen = AlgorandSecureBackupImportBackupScreen(configuration: configuration)
            screen.eventHandler = eventHandler
            viewController = screen
        case let .algorandSecureBackupImportSuccess(accountImportParameters, selectedAccounts, eventHandler):
            let dataController = AlgorandSecureBackupImportSuccessScreenLocalDataController(
                configuration: configuration,
                accountImportParameters: accountImportParameters,
                selectedAccounts: selectedAccounts
            )
            let screen = WebImportSuccessScreen(
                dataController: dataController,
                configuration: configuration
            )
            screen.eventHandler = eventHandler
            viewController = screen
        case let .algorandSecureBackupRestoreAccountList(accountImportParameters, eventHandler):
            let dataController = AlgorandSecureBackupRestoreAccountListLocalDataController(
                accountImportParameters: accountImportParameters
            )
            let screen = AlgorandSecureBackupAccountRecoverListScreen(
                dataController: dataController,
                configuration: configuration
            )
            screen.eventHandler = eventHandler
            viewController = screen
        case .algorandSecureBackupRecoverMnemonic(let backup, let eventHandler):
            let screen = AlgorandSecureBackupRecoverMnemonicScreen(
                backup: backup,
                configuration: configuration
            )
            screen.eventHandler = eventHandler
            viewController = screen
        case .importTextDocumentPicker(let delegate):
            let documentPicker: UIDocumentPickerViewController
            if #available(iOS 14.0, *) {
                documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.text, .plainText])
            } else {
                documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeText as String, kUTTypePlainText as String], in: .import)
            }
            documentPicker.allowsMultipleSelection = false
            documentPicker.shouldShowFileExtensions = true
            documentPicker.delegate = delegate
            viewController = documentPicker
        case .buySellOptions(let eventHandler):
            let screen = BuySellOptionsScreen(configuration: configuration)
            screen.eventHandler = eventHandler
            viewController = screen
        case .bidaliIntroduction:
            viewController = BidaliIntroductionScreen(api: configuration.api)
        case .bidaliDappDetail(let account):
            viewController = BidaliDappDetailScreen(
                account: account,
                config: BidaliConfig(network: configuration.api!.network),
                configuration: configuration
            )
        case .bidaliAccountSelection(let eventHandler):
            var theme = AccountSelectionListScreenTheme()
            theme.listContentTopInset = 16

            let listView: UICollectionView = {
                let collectionViewLayout = BidaliAccountSelectionListLayout.build()
                let collectionView = UICollectionView(
                    frame: .zero,
                    collectionViewLayout: collectionViewLayout
                )
                collectionView.showsVerticalScrollIndicator = false
                collectionView.showsHorizontalScrollIndicator = false
                collectionView.alwaysBounceVertical = true
                collectionView.backgroundColor = .clear
                return collectionView
            }()

            let dataController = BidaliAccountSelectionListLocalDataController(sharedDataController: configuration.sharedDataController)

            let dataSource = BidaliAccountSelectionListDataSource(dataController)
            let diffableDataSource = UICollectionViewDiffableDataSource<BidaliAccountSelectionListSectionIdentifier, BidaliAccountSelectionListItemIdentifier>(
                collectionView: listView,
                cellProvider: dataSource.getCellProvider()
            )
            diffableDataSource.supplementaryViewProvider = dataSource.getSupplementaryViewProvider(diffableDataSource)
            dataSource.registerSupportedCells(listView)
            dataSource.registerSupportedSupplementaryViews(listView)

            viewController = AccountSelectionListScreen(
                navigationBarTitle: "title-select-account".localized,
                listView: listView,
                dataController: dataController,
                listLayout: BidaliAccountSelectionListLayout(
                    dataSource: diffableDataSource,
                    itemDataSource: dataController
                ),
                listDataSource: diffableDataSource,
                theme: theme,
                eventHandler: eventHandler,
                configuration: configuration
            )
        case .moonPayIntroduction(let draft, let delegate):
            let aViewController = MoonPayIntroductionScreen(
                draft: draft,
                api: configuration.api!,
                target: ALGAppTarget.current,
                analytics: configuration.analytics,
                loadingController: configuration.loadingController!
            )
            aViewController.delegate = delegate
            viewController = aViewController
        case .moonPayAccountSelection(let eventHandler):
            var theme = AccountSelectionListScreenTheme()
            theme.listContentTopInset = 16

            let listView: UICollectionView = {
                let collectionViewLayout = MoonPayAccountSelectionListLayout.build()
                let collectionView = UICollectionView(
                    frame: .zero,
                    collectionViewLayout: collectionViewLayout
                )
                collectionView.showsVerticalScrollIndicator = false
                collectionView.showsHorizontalScrollIndicator = false
                collectionView.alwaysBounceVertical = true
                collectionView.backgroundColor = .clear
                return collectionView
            }()

            let dataController = MoonPayAccountSelectionListLocalDataController(sharedDataController: configuration.sharedDataController)

            let dataSource = MoonPayAccountSelectionListDataSource(dataController)
            let diffableDataSource = UICollectionViewDiffableDataSource<MoonPayAccountSelectionListSectionIdentifier, MoonPayAccountSelectionListItemIdentifier>(
                collectionView: listView,
                cellProvider: dataSource.getCellProvider()
            )
            diffableDataSource.supplementaryViewProvider = dataSource.getSupplementaryViewProvider(diffableDataSource)
            dataSource.registerSupportedCells(listView)
            dataSource.registerSupportedSupplementaryViews(listView)

            viewController = AccountSelectionListScreen(
                navigationBarTitle: "title-select-account".localized,
                listView: listView,
                dataController: dataController,
                listLayout: MoonPayAccountSelectionListLayout(
                    dataSource: diffableDataSource,
                    itemDataSource: dataController
                ),
                listDataSource: diffableDataSource,
                theme: theme,
                eventHandler: eventHandler,
                configuration: configuration
            )
        case let .moonPayTransaction(moonPayParams):
            viewController = MoonPayTransactionViewController(
                moonPayParams: moonPayParams,
                configuration: configuration
            )
        case .meldAccountSelection(let eventHandler):
            var theme = AccountSelectionListScreenTheme()
            theme.listContentTopInset = 16

            let listView: UICollectionView = {
                let collectionViewLayout = MeldAccountSelectionListLayout.build()
                let collectionView = UICollectionView(
                    frame: .zero,
                    collectionViewLayout: collectionViewLayout
                )
                collectionView.showsVerticalScrollIndicator = false
                collectionView.showsHorizontalScrollIndicator = false
                collectionView.alwaysBounceVertical = true
                collectionView.backgroundColor = .clear
                return collectionView
            }()

            let dataController = MeldAccountSelectionListLocalDataController(sharedDataController: configuration.sharedDataController)

            let dataSource = MeldAccountSelectionListDataSource(dataController)
            let diffableDataSource = UICollectionViewDiffableDataSource<MeldAccountSelectionListSectionIdentifier, MeldAccountSelectionListItemIdentifier>(
                collectionView: listView,
                cellProvider: dataSource.getCellProvider()
            )
            diffableDataSource.supplementaryViewProvider = dataSource.getSupplementaryViewProvider(diffableDataSource)
            dataSource.registerSupportedCells(listView)
            dataSource.registerSupportedSupplementaryViews(listView)

            viewController = AccountSelectionListScreen(
                navigationBarTitle: "title-select-account".localized,
                listView: listView,
                dataController: dataController,
                listLayout: MeldAccountSelectionListLayout(
                    dataSource: diffableDataSource,
                    itemDataSource: dataController
                ),
                listDataSource: diffableDataSource,
                theme: theme,
                eventHandler: eventHandler,
                configuration: configuration
            )
        case .meldDappDetail(let address):
            let config = MeldConfig(address: address)
            let url = URL(string: config.url)
            let destination = DiscoverExternalDestination.url(url)

            let aViewController = DiscoverExternalInAppBrowserScreen(
                destination: destination,
                configuration: configuration
            )
            aViewController.allowsPullToRefresh = false
            viewController = aViewController
        case .transakIntroduction:
            viewController = TransakIntroductionScreen(api: configuration.api)
        case .transakAccountSelection(let eventHandler):
            var theme = AccountSelectionListScreenTheme()
            theme.listContentTopInset = 16

            let listView: UICollectionView = {
                let collectionViewLayout = TransakAccountSelectionListLayout.build()
                let collectionView = UICollectionView(
                    frame: .zero,
                    collectionViewLayout: collectionViewLayout
                )
                collectionView.showsVerticalScrollIndicator = false
                collectionView.showsHorizontalScrollIndicator = false
                collectionView.alwaysBounceVertical = true
                collectionView.backgroundColor = .clear
                return collectionView
            }()

            let dataController = TransakAccountSelectionListLocalDataController(sharedDataController: configuration.sharedDataController)

            let dataSource = TransakAccountSelectionListDataSource(dataController)
            let diffableDataSource = UICollectionViewDiffableDataSource<TransakAccountSelectionListSectionIdentifier, TransakAccountSelectionListItemIdentifier>(
                collectionView: listView,
                cellProvider: dataSource.getCellProvider()
            )
            diffableDataSource.supplementaryViewProvider = dataSource.getSupplementaryViewProvider(diffableDataSource)
            dataSource.registerSupportedCells(listView)
            dataSource.registerSupportedSupplementaryViews(listView)

            viewController = AccountSelectionListScreen(
                navigationBarTitle: "title-select-account".localized,
                listView: listView,
                dataController: dataController,
                listLayout: TransakAccountSelectionListLayout(
                    dataSource: diffableDataSource,
                    itemDataSource: dataController
                ),
                listDataSource: diffableDataSource,
                theme: theme,
                eventHandler: eventHandler,
                configuration: configuration
            )
        case .transakDappDetail(let account):
            let config = TransakConfig(account: account, network: configuration.api!.network)
            let url = URL(string: config.url)
            let destination = DiscoverExternalDestination.url(url)

            let aViewController = DiscoverExternalInAppBrowserScreen(
                destination: destination,
                configuration: configuration
            )
            aViewController.allowsPullToRefresh = false
            viewController = aViewController
        case .standardAccountInformation(let account):
            let copyToClipboardController = ALGCopyToClipboardController(
                toastPresentationController: appConfiguration.toastPresentationController
            )
            viewController = StandardAccountInformationScreen(
                account: account,
                copyToClipboardController: copyToClipboardController
            )
        case .ledgerAccountInformation(let account):
            let copyToClipboardController = ALGCopyToClipboardController(
                toastPresentationController: appConfiguration.toastPresentationController
            )
            viewController = LedgerAccountInformationScreen(
                account: account,
                copyToClipboardController: copyToClipboardController
            )
        case .noAuthAccountInformation(let account):
            let copyToClipboardController = ALGCopyToClipboardController(
                toastPresentationController: appConfiguration.toastPresentationController
            )
            viewController = NoAuthAccountInformationScreen(
                account: account,
                copyToClipboardController: copyToClipboardController
            )
        case .rekeyedAccountInformation(let sourceAccount, let authAccount):
            let copyToClipboardController = ALGCopyToClipboardController(
                toastPresentationController: appConfiguration.toastPresentationController
            )
            viewController = RekeyedAccountInformationScreen(
                sourceAccount: sourceAccount,
                authAccount: authAccount,
                copyToClipboardController: copyToClipboardController
            )
        case .anyToNoAuthRekeyedAccountInformation(let account):
            let copyToClipboardController = ALGCopyToClipboardController(
                toastPresentationController: appConfiguration.toastPresentationController
            )
            viewController = AnyToNoAuthRekeyedAccountInformationScreen(
                account: account,
                copyToClipboardController: copyToClipboardController
            )
        case let .rekeyedAccountSelectionList(authAccount, rekeyedAccounts, eventHandler):
            let dataController = RekeyedAccountSelectionListLocalDataController(
                authAccount: authAccount,
                rekeyedAccounts: rekeyedAccounts,
                sharedDataController: appConfiguration.sharedDataController
            )
            let screen = RekeyedAccountSelectionListScreen(
                dataController: dataController,
                configuration: configuration
            )
            screen.eventHandler = eventHandler
            viewController = screen
        case .watchAccountInformation(let account):
            let copyToClipboardController = ALGCopyToClipboardController(
                toastPresentationController: appConfiguration.toastPresentationController
            )
            viewController = WatchAccountInformationScreen(
                account: account,
                copyToClipboardController: copyToClipboardController
            )
        case let .undoRekeyConfirmation(sourceAccount, authAccount, eventHandler):
            let uiSheet = UndoRekeyConfirmationSheet(
                sourceAccount: sourceAccount,
                authAccount: authAccount,
                eventHandler: eventHandler
            )
            viewController = UISheetActionScreen(
                sheet: uiSheet,
                theme: UISheetActionScreenImageTheme(),
                api: configuration.api
            )
        case let .overwriteRekeyConfirmation(sourceAccount, authAccount, eventHandler):
            let uiSheet = OverwriteRekeyConfirmationSheet(
                sourceAccount: sourceAccount,
                authAccount: authAccount,
                eventHandler: eventHandler
            )
            viewController = UISheetActionScreen(
                sheet: uiSheet,
                theme: UISheetActionScreenImageTheme(),
                api: configuration.api
            )
        case let .backUpBeforeRemovingAccountWarning(eventHandler):
            let uiSheet = BackUpBeforeRemovingAccountWarningSheet(
                eventHandler: eventHandler
            )
            viewController = UISheetActionScreen(
                sheet: uiSheet,
                theme: UISheetActionScreenImageTheme(),
                api: configuration.api
            )
        case let .removeAccount(account, eventHandler):
            let sharedDataController = appConfiguration.sharedDataController
            let peraConnect = appConfiguration.peraConnect
            let uiSheet = RemoveAccountSheet(
                account: account,
                sharedDataController: sharedDataController,
                peraConnect: peraConnect,
                eventHandler: eventHandler
            )
            viewController = UISheetActionScreen(
                sheet: uiSheet,
                theme: UISheetActionScreenImageTheme(),
                api: configuration.api
            )
        case .externalInAppBrowser(let destination):
            viewController = DiscoverExternalInAppBrowserScreen(
                destination: destination,
                configuration: configuration
            )
        case let .extendWCSessionValidity(wcV2Session, eventHandler):
            let uiSheet = ExtendWCSessionValiditySheet(
                wcV2Session: wcV2Session,
                eventHandler: eventHandler
            )
            viewController = UISheetActionScreen(
                sheet: uiSheet,
                theme: UISheetActionScreenImageTheme(),
                api: configuration.api
            )
        case let .wcAdvancedPermissionsInfo(eventHandler):
            let uiSheet = WCAdvancedPermissionsInfoSheet(eventHandler: eventHandler)
            viewController = UISheetActionScreen(
                sheet: uiSheet,
                theme: UISheetActionScreenCommonTheme(),
                api: configuration.api
            )
        case let .wcSessionDetail(draft):
            let wcV2Protocol =
                configuration.peraConnect.walletConnectCoordinator.walletConnectProtocolResolver.walletConnectV2Protocol
            let dataController = WCSessionDetailLocalDataController(
                sharedDataController: appConfiguration.sharedDataController,
                walletConnectV2Protocol: wcV2Protocol,
                draft: draft
            )
            let copyToClipboardController = ALGCopyToClipboardController(
                toastPresentationController: appConfiguration.toastPresentationController
            )
            viewController = WCSessionDetailScreen(
                dataController: dataController,
                copyToClipboardController: copyToClipboardController,
                configuration: configuration
            )
        case let .wcSessionConnectionSuccessful(draft, eventHandler):
            let pairExpiryDate = draft.wcV2Session.unwrap {
                let wcV2Protocol =
                    configuration.peraConnect.walletConnectCoordinator.walletConnectProtocolResolver.walletConnectV2Protocol
                let pairing = wcV2Protocol.getPairing(for: $0.pairingTopic)
                return pairing?.expiryDate
            }
            let uiSheet = WCSessionConnectionSuccessfulSheet(
                draft: draft,
                pairExpiryDate: pairExpiryDate,
                eventHandler: eventHandler
            )
            var theme = UISheetActionScreenImageTheme()
            theme.spacingBetweenTitleAndBody = 12
            theme.infoIcon = []
            theme.spacingBetweeenInfoIconAndInfoMessage = 0
            viewController = UISheetActionScreen(
                sheet: uiSheet,
                theme: theme,
                api: configuration.api
            )
        case let .wcTransactionSignSuccessful(draft, eventHandler):
            let pairExpiryDate = draft.wcV2Session.unwrap {
                let wcV2Protocol =
                    configuration.peraConnect.walletConnectCoordinator.walletConnectProtocolResolver.walletConnectV2Protocol
                let pairing = wcV2Protocol.getPairing(for: $0.pairingTopic)
                return pairing?.expiryDate
            }
            let uiSheet = WCTransactionSignSuccessfulSheet(
                draft: draft,
                pairExpiryDate: pairExpiryDate,
                eventHandler: eventHandler
            )
            var theme = UISheetActionScreenImageTheme()
            theme.spacingBetweenTitleAndBody = 12
            theme.infoIcon = []
            theme.spacingBetweeenInfoIconAndInfoMessage = 0
            viewController = UISheetActionScreen(
                sheet: uiSheet,
                theme: theme,
                api: configuration.api
            )
        case let .backUpAccountSelection(eventHandler):
            var theme = AccountSelectionListScreenTheme()
            theme.listContentTopInset = 16

            let listView: UICollectionView = {
                let collectionViewLayout = BackUpAccountSelectionListLayout.build()
                let collectionView = UICollectionView(
                    frame: .zero,
                    collectionViewLayout: collectionViewLayout
                )
                collectionView.showsVerticalScrollIndicator = false
                collectionView.showsHorizontalScrollIndicator = false
                collectionView.alwaysBounceVertical = true
                collectionView.backgroundColor = .clear
                return collectionView
            }()

            let dataController = BackUpAccountSelectionListLocalDataController(sharedDataController: configuration.sharedDataController)

            let dataSource = BackUpAccountSelectionListDataSource(dataController)
            let diffableDataSource = UICollectionViewDiffableDataSource<BackUpAccountSelectionListSectionIdentifier, BackUpAccountSelectionListItemIdentifier>(
                collectionView: listView,
                cellProvider: dataSource.getCellProvider()
            )
            diffableDataSource.supplementaryViewProvider = dataSource.getSupplementaryViewProvider(diffableDataSource)
            dataSource.registerSupportedCells(listView)
            dataSource.registerSupportedSupplementaryViews(listView)

            viewController = AccountSelectionListScreen(
                navigationBarTitle: "title-select-account".localized,
                listView: listView,
                dataController: dataController,
                listLayout: BackUpAccountSelectionListLayout(
                    dataSource: diffableDataSource,
                    itemDataSource: dataController
                ),
                listDataSource: diffableDataSource,
                theme: theme,
                eventHandler: eventHandler,
                configuration: configuration
            )

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
    /// <todo>:
    /// Remove this after all asset action confirmation screen transformations to new componants (e.g `OptInAssetScreen`) are completed.
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmAction asset: AssetDecoration
    ) {
        let draft = assetActionConfirmationViewController.draft

        guard let account = draft.account,
              account.authorization.isAuthorized else {
            return
        }
        
        if !transactionController.canSignTransaction(for: account) { return }

        appConfiguration.loadingController.startLoadingWithMessage("title-loading".localized)

        let monitor = appConfiguration.sharedDataController.blockchainUpdatesMonitor
        let request = OptInBlockchainRequest(account: account, asset: asset)
        monitor.startMonitoringOptInUpdates(request)

        let assetTransactionDraft = AssetTransactionSendDraft(
            from: account,
            assetIndex: Int64(draft.assetId)
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
}

extension Router {
    private func startObservingNotifications() {
        startObservingPeraConnectEvents()
        startObservingWCSessionConnectionRequestNotification()
    }

    private func startObservingPeraConnectEvents() {
        appConfiguration.peraConnect.add(self)
    }

    private func startObservingWCSessionConnectionRequestNotification() {
        observe(notification: ALGPeraConnect.didReceiveSessionRequestNotification) {
            [weak self] notification in
            guard let self else { return }

            let preferencesKey = ALGPeraConnect.sessionRequestPreferencesKey
            let preferences = notification.userInfo?[preferencesKey] as? WalletConnectSessionCreationPreferences
            guard let preferences else { return }

            let peraConnect = self.appConfiguration.peraConnect
            peraConnect.connectToSession(with: preferences)
        }
    }
}

extension Router {
    private func publishQRScannerScreenResetNotification(_ preferences: WalletConnectSessionCreationPreferences) {
        NotificationCenter.default.post(
            name: QRScannerViewController.didReset,
            object: nil,
            userInfo: [ ALGPeraConnect.sessionRequestPreferencesKey: preferences ]
        )
    }

    private func publishQRScannerWCSessionConnectionSuccessfulNotification(_ preferences: WalletConnectSessionCreationPreferences) {
        NotificationCenter.default.post(
            name: QRScannerViewController.didConnectWCSessionSuccessfully,
            object: nil,
            userInfo: [ ALGPeraConnect.sessionRequestPreferencesKey: preferences ]
        )
    }
}

/// <mark>:  PeraConnectObserver
extension Router {
    func peraConnect(
        _ peraConnect: PeraConnect,
        didPublish event: PeraConnectEvent
    ) {
        switch event {
        case .shouldStartV1(let session, let preferences, let completion):
            peraConnectShouldStartV1Session(
                peraConnect,
                shouldStart: session,
                with: preferences,
                then: completion
            )
        case .didConnectToV1(let session, let preferences):
            peraConnectDidConnectToV1Session(
                peraConnect,
                didConnectTo: session,
                with: preferences
            )
        case .didFailToConnectV1(let error, let preferences):
            peraConnectDidFailToConnectV1(
                with: error,
                preferences: preferences
            )
        case .didCreateV2SessionFail(let preferences),
             .didConnectV2SessionFail(let preferences):
            peraConnectDidFailToConnectV2(preferences)
        case .proposeSessionV2(let proposal, let preferences):
            proposeSession(
                proposal,
                with: preferences
            )
        case .settleSessionV2(let session, let preferences):
            peraConnectDidSettleSessionV2(
                session,
                with: preferences
            )
        default: break
        }
    }
}

/// <mark>: WC v1
extension Router {
    private func peraConnectShouldStartV1Session(
        _ peraConnect: PeraConnect,
        shouldStart session: WalletConnectSession,
        with preferences: WalletConnectSessionCreationPreferences,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    ) {
        let bannerController = appConfiguration.bannerController

        let api = appConfiguration.api
        let sessionChainId = session.chainId(for: api.network)

        if !api.network.allowedChainIDs.contains(sessionChainId) {
            appConfiguration.analytics.track(
                .wcSessionRejected(
                    version: .v1,
                    topic: session.url.topic,
                    dappName: session.dAppInfo.peerMeta.name,
                    dappURL: session.dAppInfo.peerMeta.url.absoluteString
                )
            )
            
            asyncMain {
                [weak bannerController, weak self] in
                guard
                    let bannerController,
                    let self
                else {
                    return
                }

                bannerController.presentErrorBanner(
                    title: "title-error".localized,
                    message: "wallet-connect-transaction-error-node".localized
                )

                completion(
                    session.getDeclinedWalletConnectionInfo(on: api.network)
                )

                self.publishQRScannerScreenResetNotification(preferences)
            }
            return
        }

        let sharedDataController = appConfiguration.sharedDataController
        let hasAuthorizedAccount = 
            sharedDataController.accountCollection.contains(where: \.value.authorization.isAuthorized)
        if !hasAuthorizedAccount {
            appConfiguration.analytics.track(
                .wcSessionRejected(
                    version: .v1,
                    topic: session.url.topic,
                    dappName: session.dAppInfo.peerMeta.name,
                    dappURL: session.dAppInfo.peerMeta.url.absoluteString
                )
            )

            asyncMain {
                [weak bannerController, weak self] in
                guard
                    let bannerController,
                    let self
                else {
                    return
                }
                bannerController.presentErrorBanner(
                    title: "title-error".localized,
                    message: "wallet-connect-session-error-no-account".localized
                )
                
                completion(
                    session.getDeclinedWalletConnectionInfo(on: api.network)
                )

                self.publishQRScannerScreenResetNotification(preferences)
            }
            return
        }

        asyncMain { [weak self] in
            guard let self = self else { return }

            let visibleScreen = self.findVisibleScreen(over: self.rootViewController)
            let transition = BottomSheetTransition(
                presentingViewController: visibleScreen,
                interactable: false
            )
            let draft = WCSessionConnectionDraft(session: session)

            let screen = transition.perform(
                .wcConnection(draft: draft),
                by: .present
            ) as? WCSessionConnectionScreen

            screen?.eventHandler = {
                [weak self, weak screen] event in
                guard
                    let self,
                    let screen
                else {
                    return
                }

                switch event {
                case .performCancel:
                    self.appConfiguration.analytics.track(
                        .wcSessionRejected(
                            version: .v1,
                            topic: session.url.topic,
                            dappName: session.dAppInfo.peerMeta.name,
                            dappURL: session.dAppInfo.peerMeta.url.absoluteString
                        )
                    )

                    asyncMain {
                        [weak self, weak screen] in
                        guard
                            let self,
                            let screen
                        else {
                            return
                        }

                        completion(
                            session.getDeclinedWalletConnectionInfo(on: appConfiguration.api.network)
                        )

                        screen.dismissScreen()

                        self.publishQRScannerScreenResetNotification(preferences)
                    }
                case .performConnect(let accounts):
                    self.appConfiguration.analytics.track(
                        .wcSessionApproved(
                            version: .v1,
                            topic: session.url.topic,
                            dappName: session.dAppInfo.peerMeta.name,
                            dappURL: session.dAppInfo.peerMeta.url.absoluteString,
                            address: accounts.joined(separator: ","),
                            totalAccount: accounts.count
                        )
                    )

                    asyncMain {
                        [weak self, weak screen] in
                        guard
                            let self,
                            let screen
                        else {
                            return
                        }

                        completion(
                            session.getApprovedWalletConnectionInfo(
                                for: accounts,
                                on: appConfiguration.api.network
                            )
                        )

                        screen.dismiss(animated: true)

                        self.publishQRScannerScreenResetNotification(preferences)
                    }
                }
            }

            self.ongoingTransitions.append(transition)
        }
    }

    private func peraConnectDidFailToConnectV1(
        with error: WalletConnectV1Protocol.WCError,
        preferences: WalletConnectSessionCreationPreferences
    ) {
        switch error {
        case .failedToConnect,
             .failedToCreateSession:
            asyncMain { [weak self] in
                guard let self else { return }
               
                self.publishQRScannerScreenResetNotification(preferences)

                appConfiguration.bannerController.presentErrorBanner(
                    title: "title-error".localized,
                    message: "wallet-connect-session-invalid-qr-message".localized
                )
            }
        default:
            break
        }
    }

    private func peraConnectDidConnectToV1Session(
        _ peraConnect: PeraConnect,
        didConnectTo session: WCSession,
        with preferences: WalletConnectSessionCreationPreferences
    ) {
        let shouldShowConnectionApproval = preferences.prefersConnectionApproval
        if shouldShowConnectionApproval {
            let draft = WCSessionDraft(wcV1Session: session)

            /// <note>
            /// Refactor
            /// This delay should be removed after refactoring the router.
            /// A delay has been added to ensure that the screen is not presented
            /// before the top view controller's view is added to the window's hierarchy.
            /// If the top view controller's view is not in the hierarchy, UIKit will not
            /// present the WC Connection Successful screen.
            /// Error: Attempt to present <*> on <*> (from <*>) whose view is not in the window hierarchy.
            asyncMain(afterDuration: 0.3) {
                [weak self] in
                guard let self else { return }
                self.openWCSessionConnectionSuccessful(
                    draft: draft,
                    preferences: preferences
                )
            }
        }

        appConfiguration.walletConnector.clearExpiredSessionsIfNeeded()
    }
}

/// <mark>: WC v2
extension Router {
    private func proposeSession(
        _ sessionProposal: WalletConnectV2SessionProposal,
        with preferences: WalletConnectSessionCreationPreferences
    ) {
        let requiredNamespaces = sessionProposal.requiredNamespaces[WalletConnectNamespaceKey.algorand]
        let requestedChains = requiredNamespaces?.chains ?? []
        guard let requiredNamespaces,
              requestedChains.allSatisfy({ $0.namespace == WalletConnectNamespaceKey.algorand }) else {
            appConfiguration.analytics.track(
                .wcSessionRejected(
                    version: .v2,
                    topic: sessionProposal.pairingTopic,
                    dappName: sessionProposal.proposer.name,
                    dappURL: sessionProposal.proposer.url
                )
            )

            publishQRScannerScreenResetNotification(preferences)

            let params = WalletConnectV2RejectSessionConnectionParams(
                proposalId: sessionProposal.id,
                reason: .userRejected
            )
            appConfiguration.peraConnect.rejectSessionConnection(params)
            return
        }

        let hasNetworkMatch = requestedChains.contains { allowedChainReference in
            return appConfiguration.api.network.allowedChainReference == allowedChainReference.reference
        }
        guard hasNetworkMatch else {
            appConfiguration.analytics.track(
                .wcSessionRejected(
                    version: .v2,
                    topic: sessionProposal.pairingTopic,
                    dappName: sessionProposal.proposer.name,
                    dappURL: sessionProposal.proposer.url
                )
            )

            asyncMain { [weak self] in
                guard let self else { return }

                let requestedNetworks = requestedChains.map {
                    let network = ALGAPI.Network(blockchain: $0)
                    let networkTitle = network.unwrap(\.rawValue.capitalized) ?? $0.reference
                    return networkTitle
                }

                let requestedNetworksTitle = requestedNetworks.joined(separator: ", ")
                let expectedNetworkTitle = appConfiguration.api.network.rawValue.capitalized

                let error: WCTransactionErrorResponse = .userRejectedChains(
                    requestedNetwork: requestedNetworksTitle,
                    expectedNetwork: expectedNetworkTitle
                )

                appConfiguration.bannerController.presentErrorBanner(
                    title: "title-error".localized,
                    message: error.message
                )

                publishQRScannerScreenResetNotification(preferences)

                let params = WalletConnectV2RejectSessionConnectionParams(
                    proposalId: sessionProposal.id,
                    reason: .userRejectedChains
                )
                appConfiguration.peraConnect.rejectSessionConnection(params)
            }
            return
        }

        let requestedMethods = requiredNamespaces.methods 
        let supportsRequestedMethods = WalletConnectMethod.allCases.contains {
            return requestedMethods.contains($0.rawValue)
        }
        guard supportsRequestedMethods else {
            appConfiguration.analytics.track(
                .wcSessionRejected(
                    version: .v2,
                    topic: sessionProposal.pairingTopic,
                    dappName: sessionProposal.proposer.name,
                    dappURL: sessionProposal.proposer.url
                )
            )

            publishQRScannerScreenResetNotification(preferences)

            let params = WalletConnectV2RejectSessionConnectionParams(
                proposalId: sessionProposal.id,
                reason: .userRejectedMethods
            )
            appConfiguration.peraConnect.rejectSessionConnection(params)
            return
        }

        let accounts = appConfiguration.sharedDataController.accountCollection
        guard accounts.contains(where: { $0.value.authorization.isAuthorized }) else {
            appConfiguration.analytics.track(
                .wcSessionRejected(
                    version: .v2,
                    topic: sessionProposal.pairingTopic,
                    dappName: sessionProposal.proposer.name,
                    dappURL: sessionProposal.proposer.url
                )
            )
            
            asyncMain { [weak self] in
                guard let self else { return }

                appConfiguration.bannerController.presentErrorBanner(
                    title: "title-error".localized,
                    message: "wallet-connect-session-error-no-account".localized
                )

                publishQRScannerScreenResetNotification(preferences)

                let params = WalletConnectV2RejectSessionConnectionParams(
                    proposalId: sessionProposal.id,
                    reason: .userRejected
                )
                appConfiguration.peraConnect.rejectSessionConnection(params)
            }
            return
        }

        let draft = WCSessionConnectionDraft(sessionProposal: sessionProposal)

        asyncMain {
            [weak self] in
            guard let self = self else { return }

            let visibleScreen = findVisibleScreen(over: rootViewController)
            let transition = BottomSheetTransition(presentingViewController: visibleScreen)

            let wcConnectionScreen = transition.perform(
                .wcConnection(draft: draft),
                by: .present
            ) as? WCSessionConnectionScreen
            wcConnectionScreen?.eventHandler = {
                [weak self, weak wcConnectionScreen] event in
                guard let self = self else { return }

                switch event {
                case .performCancel:
                    appConfiguration.analytics.track(
                        .wcSessionRejected(
                            version: .v2,
                            topic: sessionProposal.pairingTopic,
                            dappName: sessionProposal.proposer.name,
                            dappURL: sessionProposal.proposer.url
                        )
                    )

                    asyncMain {
                        [weak self, weak wcConnectionScreen] in
                        guard let self else { return }

                        let params = WalletConnectV2RejectSessionConnectionParams(
                            proposalId: sessionProposal.id,
                            reason: .userRejected
                        )
                        appConfiguration.peraConnect.rejectSessionConnection(params)

                        wcConnectionScreen?.dismissScreen()

                        publishQRScannerScreenResetNotification(preferences)
                    }
                case .performConnect(let selectedAccounts):
                    appConfiguration.analytics.track(
                        .wcSessionApproved(
                            version: .v2,
                            topic: sessionProposal.pairingTopic,
                            dappName: sessionProposal.proposer.name,
                            dappURL: sessionProposal.proposer.url,
                            address: selectedAccounts.joined(separator: ","),
                            totalAccount: selectedAccounts.count
                        )
                    )

                    var sessionNamespaces = SessionNamespaces()
                    sessionProposal.requiredNamespaces.forEach {
                        let caip2Namespace = $0.key
                        guard caip2Namespace == WalletConnectNamespaceKey.algorand else {
                            return
                        }

                        let proposalNamespace = $0.value

                        let requestedChains = proposalNamespace.chains
                        guard let requestedChains else { return }
                        let chains = requestedChains.filter { allowedChainReference in
                            return
                                algorandWalletConnectV2TestNetChainReference == allowedChainReference.reference ||
                                algorandWalletConnectV2MainNetChainReference == allowedChainReference.reference
                        }

                        let accounts = Set(
                            chains.compactMap { chain in
                                selectedAccounts.compactMap { account in
                                    return WalletConnectV2Account(
                                        "\(chain.absoluteString):\(account)"
                                    )
                                }
                            }
                        ).flatMap { $0 }

                        let supportedMethods = WalletConnectMethod.allCases.map(\.rawValue)
                        let requestedMethods = proposalNamespace.methods
                        let methods = requestedMethods.filter {
                            return supportedMethods.contains($0)
                        }
                        let sessionNamespace = WalletConnectV2SessionNamespace(
                            accounts: Set(accounts),
                            methods: methods,
                            events: proposalNamespace.events
                        )

                        sessionNamespaces[caip2Namespace] = sessionNamespace
                    }

                    let params = WalletConnectV2ApproveSessionConnectionParams(
                        proposalId: sessionProposal.id,
                        namespaces: sessionNamespaces
                    )
                    appConfiguration.peraConnect.approveSessionConnection(params)

                    wcConnectionScreen?.dismiss(animated: true)

                    publishQRScannerScreenResetNotification(preferences)
                }

                ongoingTransitions.append(transition)
            }
        }
    }

    func peraConnectDidSettleSessionV2(
        _ session: WalletConnectV2Session,
        with preferences: WalletConnectSessionCreationPreferences
    ) {
        if preferences.prefersConnectionApproval {
            let draft = WCSessionDraft(wcV2Session: session)

            /// <note>
            /// Refactor
            /// This delay should be removed after refactoring the router.
            /// A delay has been added to ensure that the screen is not presented
            /// before the top view controller's view is added to the window's hierarchy.
            /// If the top view controller's view is not in the hierarchy, UIKit will not
            /// present the WC Connection Successful screen.
            /// Error: Attempt to present <*> on <*> (from <*>) whose view is not in the window hierarchy.
            asyncMain(afterDuration: 0.3) {
                [weak self] in
                guard let self else { return }
                self.openWCSessionConnectionSuccessful(
                    draft: draft,
                    preferences: preferences
                )
            }
        }
    }

    private func peraConnectDidFailToConnectV2(_ preferences: WalletConnectSessionCreationPreferences) {
        asyncMain { [weak self] in
            guard let self else { return }

            publishQRScannerScreenResetNotification(preferences)

            appConfiguration.bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: "wallet-connect-session-invalid-qr-message".localized
            )
        }
    }
}

extension Router {
    private func openWCSessionConnectionSuccessful(
        draft: WCSessionDraft,
        preferences: WalletConnectSessionCreationPreferences
    ) {
        let visibleScreen = findVisibleScreen(over: rootViewController)
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        let eventHandler: WCSessionConnectionSuccessfulSheet.EventHandler = {
            [weak visibleScreen] event in
            guard let visibleScreen else { return }
            switch event {
            case .didClose:
                visibleScreen.presentedViewController?.dismiss(animated: true) {
                    [weak self] in
                    guard let self else { return }
                    publishQRScannerWCSessionConnectionSuccessfulNotification(preferences)
                }
            }
        }
        transition.perform(
            .wcSessionConnectionSuccessful(
                draft: draft,
                eventHandler: eventHandler
            ),
            by: .presentWithoutNavigationController
        )

        ongoingTransitions.append(transition)
    }
}

extension Router {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for draft: SelectAccountDraft
    ) {
        switch draft.transactionAction {
        case .send:
            if draft.requiresAssetSelection {
                openAssetSelection(
                    with: account,
                    on: selectAccountViewController,
                    receiver: draft.receiver
                )
                return
            }
            
            sendTransction(
                from: selectAccountViewController,
                for: account,
                with: draft.transactionDraft
            )
        case .optIn(let asset):
            requestOptingInToAsset(
                asset,
                to: account
            )
        default:
            break
        }
    }

    private func sendTransction(
        from selectAccountViewController: SelectAccountViewController,
        for account: Account,
        with transactionDraft: TransactionSendDraft?
    ) {
        guard let transactionDraft = transactionDraft as? SendTransactionDraft else {
            return
        }

        let transactionMode = updateTransactionModeIfNeeded(
            transactionDraft,
            for: account
        )
        let draft = SendTransactionDraft(
            from: account,
            toAccount: transactionDraft.toAccount,
            amount: transactionDraft.amount,
            transactionMode: transactionMode,
            note: transactionDraft.note,
            lockedNote: transactionDraft.lockedNote
        )

        selectAccountViewController.open(
            .sendTransaction(
                draft: draft
            ),
            by: .push
        )
    }

    private func updateTransactionModeIfNeeded(
        _ draft: SendTransactionDraft,
        for account: Account
    ) -> TransactionMode {
        var transactionMode = draft.transactionMode

        if case let .asset(asset) = draft.transactionMode {
            let foundAsset = account[asset.id] ?? asset
            transactionMode = .asset(foundAsset)
        }

        return transactionMode
    }

    private func requestOptingInToAsset(
        _ assetID: AssetID,
        to account: Account
    ) {
        if account.containsAsset(assetID) {
            appConfiguration.bannerController.presentInfoBanner("asset-you-already-own-message".localized)
            return
        }

        appConfiguration.loadingController.startLoadingWithMessage("title-loading".localized)

        appConfiguration.api.fetchAssetDetails(
            AssetFetchQuery(ids: [assetID]),
            queue: .main,
            ignoreResponseOnCancelled: false
        ) { [weak self] response in
            guard let self = self else {
                return
            }
            self.appConfiguration.loadingController.stopLoading()
            switch response {
            case let .success(assetResponse):
                if assetResponse.results.isEmpty {
                    self.appConfiguration.bannerController.presentErrorBanner(
                        title: "title-error".localized,
                        message: "asset-confirmation-not-found".localized
                    )
                    return
                }

                if let asset = assetResponse.results.first {
                    self.openOptInAsset(
                        asset: asset,
                        account: account
                    )
                }
            case .failure:
                self.appConfiguration.bannerController.presentErrorBanner(
                    title: "title-error".localized,
                    message: "asset-confirmation-not-fetched".localized
                )
            }
        }
    }

    private func openOptInAsset(
        asset: AssetDecoration,
        account: Account
    ) {
        let draft = OptInAssetDraft(
            account: account,
            asset: asset
        )

        let screen = Screen.optInAsset(draft: draft) {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .performApprove:
                self.continueToOptInAsset(
                    asset: asset,
                    account: account
                )
            case .performClose:
                self.cancelOptInAsset()
            }
        }

        let visibleScreen = findVisibleScreen()
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        ongoingTransitions.append(transition)

        transition.perform(
            screen,
            by: .present
        )
    }

    private func openAssetSelection(
        with account: Account,
        on screen: UIViewController,
        receiver: String?
    ) {
        let assetSelectionScreen: Screen = .assetSelection(
            account: account,
            receiver: receiver
        )

        screen.open(
            assetSelectionScreen,
            by: .push
        )
    }
}

extension Router {
    private func continueToOptInAsset(
        asset: AssetDecoration,
        account: Account
    ) {
        let visibleScreen = findVisibleScreen()

        visibleScreen.dismiss(animated: true) {
            [weak self] in
            guard let self = self else { return }
            
            if !self.transactionController.canSignTransaction(for: account) { return }

            let monitor = self.appConfiguration.sharedDataController.blockchainUpdatesMonitor
            let request = OptInBlockchainRequest(account: account, asset: asset)
            monitor.startMonitoringOptInUpdates(request)

            let assetTransactionDraft = AssetTransactionSendDraft(
                from: account,
                assetIndex: asset.id
            )

            self.appConfiguration.loadingController.startLoadingWithMessage("title-loading".localized)

            self.transactionController.delegate = self
            self.transactionController.setTransactionDraft(assetTransactionDraft)
            self.transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)

            if account.requiresLedgerConnection() {
                self.openLedgerConnection()

                self.transactionController.initializeLedgerTransactionAccount()
                self.transactionController.startTimer()
            }
        }
    }

    private func cancelOptInAsset() {
        let visibleScreen = findVisibleScreen()
        visibleScreen.dismiss(animated: true)
    }
}

extension Router: MoonPayIntroductionScreenDelegate {
    func moonPayIntroductionScreen(
        _ screen: MoonPayIntroductionScreen,
        didCompletedTransaction params: MoonPayParams
    ) {
        screen.dismissScreen(animated: true) {
            self.displayMoonPayTransactionScreen(for: params)
        }
    }

    private func displayMoonPayTransactionScreen(for params: MoonPayParams) {
        let visibleScreen = findVisibleScreen(over: rootViewController)
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        ongoingTransitions.append(transition)

        transition.perform(
            .moonPayTransaction(moonPayParams: params),
            by: .presentWithoutNavigationController
        )
    }

    func moonPayIntroductionScreenDidFailedTransaction(_ screen: MoonPayIntroductionScreen) {
        screen.dismissScreen()
    }
}

/// <todo>
/// Should be handled for each specific transaction separately.
extension Router {
    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        cancelMonitoringOptInUpdates(for: transactionController)

        appConfiguration.loadingController.stopLoading()

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
        cancelMonitoringOptInUpdates(for: transactionController)

        appConfiguration.loadingController.stopLoading()

        switch error {
        case let .network(apiError):
            appConfiguration.bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: apiError.debugDescription
            )
        default:
            appConfiguration.bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: error.localizedDescription
            )
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        appConfiguration.loadingController.stopLoading()

        let visibleScreen = findVisibleScreen(over: rootViewController)
        visibleScreen.dismissScreen()
    }

    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            let currencyFormatter = CurrencyFormatter()
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let amountText = currencyFormatter.format(amount.toAlgos)

            appConfiguration.bannerController.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(
                    params: amountText.someString
                )
            )
        case .invalidAddress:
            appConfiguration.bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: "send-algos-receiver-address-validation".localized
            )
        case let .sdkError(error):
            appConfiguration.bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: error.debugDescription
            )
        case .ledgerConnection:
            ledgerConnectionScreen?.dismiss(animated: true) {
                self.ledgerConnectionScreen = nil

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

        appConfiguration.loadingController.stopLoading()
    }

    func transactionControllerDidResetLedgerOperationOnSuccess(
        _ transactionController: TransactionController
    ) {
        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil

        appConfiguration.loadingController.stopLoading()
    }

    func transactionController(
        _ transactionController: TransactionController,
        didCompletedTransaction id: TransactionID
    ) { }

    func transactionControllerDidFailToSignWithLedger(
        _ transactionController: TransactionController
    ) { }

    func transactionControllerDidRejectedLedgerOperation(
        _ transactionController: TransactionController
    ) { }

    private func cancelMonitoringOptInUpdates(for transactionController: TransactionController) {
        if let assetID = getAssetID(from: transactionController),
           let account = getAccount(from: transactionController) {
            let monitor = appConfiguration.sharedDataController.blockchainUpdatesMonitor
            monitor.cancelMonitoringOptInUpdates(
                forAssetID: assetID,
                for: account
            )
        }
    }

    private func getAssetID(
        from transactionController: TransactionController
    ) -> AssetID? {
        return transactionController.assetTransactionDraft?.assetIndex
    }

    private func getAccount(
        from transactionController: TransactionController
    ) -> Account? {
        return transactionController.assetTransactionDraft?.from
    }
}

extension Router {
    private func openLedgerConnection() {
        let visibleScreen = findVisibleScreen(over: rootViewController)
        let transition = BottomSheetTransition(
            presentingViewController: visibleScreen,
            interactable: false
        )

        let eventHandler: LedgerConnectionScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancel:
                self.transactionController.stopBLEScan()
                self.transactionController.stopTimer()
                self.cancelMonitoringOptInUpdates(for: self.transactionController)

                self.ledgerConnectionScreen?.dismissScreen()
                self.ledgerConnectionScreen = nil

                self.appConfiguration.loadingController.stopLoading()
            }
        }

        ledgerConnectionScreen = transition.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )

        ongoingTransitions.append(transition)
    }
}

extension Router {
    private func openLedgerConnectionIssues() {
        let visibleScreen = findVisibleScreen(over: rootViewController)
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        transition.perform(
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

        ongoingTransitions.append(transition)
    }
}

extension Router {
    private func openSignWithLedgerProcess(
        transactionController: TransactionController,
        ledgerDeviceName: String
    ) {
        let visibleScreen = findVisibleScreen(over: rootViewController)
        let ledgerApprovalTransition = BottomSheetTransition(
            presentingViewController: visibleScreen,
            interactable: false
        )

        ongoingTransitions.append(ledgerApprovalTransition)

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

                self.cancelMonitoringOptInUpdates(for: self.transactionController)

                self.appConfiguration.loadingController.stopLoading()
            }
        }
        signWithLedgerProcessScreen = ledgerApprovalTransition.perform(
            .signWithLedgerProcess(
                draft: draft,
                eventHandler: eventHandler
            ),
            by: .present
        ) as? SignWithLedgerProcessScreen
    }
}
