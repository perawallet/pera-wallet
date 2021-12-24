// Copyright 2019 Algorand, Inc.

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

import UIKit

class Router {

    private weak var rootViewController: RootViewController?
    
    init(rootViewController: RootViewController) {
        self.rootViewController = rootViewController
    }
    
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
            
            rootViewController?.present(navigationController, animated: false, completion: completion)
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
                navigationController.modalPresentationCapturesStatusBarAppearance = true
                navigationController.transitioningDelegate = transitioningDelegate
            }
            
            sourceViewController.present(navigationController, animated: animated, completion: completion)
        case .presentWithoutNavigationController:
            if let presentingViewController = self as? StatusBarConfigurable,
                let presentedViewController = viewController as? StatusBarConfigurable,
                presentingViewController.isStatusBarHidden {
                
                presentedViewController.hidesStatusBarWhenPresented = true
                presentedViewController.isStatusBarHidden = true
            }
            
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
        guard let rootViewController = UIApplication.shared.rootViewController() else {
            return nil
        }
        
        let viewController: UIViewController
        
        let configuration = ViewControllerConfiguration(
            api: rootViewController.appConfiguration.api,
            session: rootViewController.appConfiguration.session,
            walletConnector: rootViewController.appConfiguration.walletConnector
        )
        
        switch screen {
        case let .introduction(flow):
            viewController = IntroductionViewController(accountSetupFlow: flow, configuration: configuration)
        case let .welcome(flow):
            viewController = WelcomeViewController(flow: flow, configuration: configuration)
        case let .addAccount(flow):
            viewController = AddAccountViewController(flow: flow, configuration: configuration)
        case let .choosePassword(mode, flow, route):
            viewController = ChoosePasswordViewController(
                mode: mode,
                accountSetupFlow: flow,
                route: route,
                configuration: configuration
            )
        case let .passphraseView(address):
            viewController = PassphraseBackUpViewController(address: address, configuration: configuration)
        case .passphraseVerify:
            viewController = PassphraseVerifyViewController(configuration: configuration)
        case .accountNameSetup:
            viewController = AccountNameSetupViewController(configuration: configuration)
        case let .accountRecover(flow):
            viewController = AccountRecoverViewController(accountSetupFlow: flow, configuration: configuration)
        case let .qrScanner(canReadWCSession):
            viewController = QRScannerViewController(canReadWCSession: canReadWCSession, configuration: configuration)
        case let .qrGenerator(title, draft, isTrackable):
            let qrCreationController = QRCreationViewController(draft: draft, configuration: configuration, isTrackable: isTrackable)
            qrCreationController.title = title
            viewController = qrCreationController
        case .home:
            viewController = TabBarController(configuration: configuration)
        case let .accountList(mode):
            viewController = AccountListViewController(mode: mode, configuration: configuration)
        case let .options(account):
            viewController = OptionsViewController(account: account, configuration: configuration)
        case let .editAccount(account):
            viewController = EditAccountViewController(account: account, configuration: configuration)
        case .contactSelection:
            viewController = ContactSelectionViewController(configuration: configuration)
        case let .addContact(mode):
            viewController = AddContactViewController(mode: mode, configuration: configuration)
        case let .contactDetail(contact):
            viewController = ContactInfoViewController(contact: contact, configuration: configuration)
        case let .sendAlgosTransactionPreview(account, receiver, isSenderEditable, qrText):
            viewController = SendAlgosTransactionPreviewViewController(
                account: account,
                assetReceiverState: receiver,
                isSenderEditable: isSenderEditable,
                qrText: qrText,
                configuration: configuration
            )
        case let .sendAssetTransactionPreview(account, receiver, assetDetail, isSenderEditable, isMaxTransaction, qrText):
            viewController = SendAssetTransactionPreviewViewController(
                account: account,
                assetReceiverState: receiver,
                assetDetail: assetDetail,
                isSenderEditable: isSenderEditable,
                isMaxTransaction: isMaxTransaction,
                qrText: qrText,
                configuration: configuration
            )
        case let .sendAlgosTransaction(algosTransactionSendDraft, transactionController, receiver, isSenderEditable):
            viewController = SendAlgosTransactionViewController(
                algosTransactionSendDraft: algosTransactionSendDraft,
                assetReceiverState: receiver,
                transactionController: transactionController,
                isSenderEditable: isSenderEditable,
                configuration: configuration
            )
        case let .sendAssetTransaction(assetTransactionSendDraft, transactionController, receiver, isSenderEditable):
            viewController = SendAssetTransactionViewController(
                assetTransactionSendDraft: assetTransactionSendDraft,
                assetReceiverState: receiver,
                transactionController: transactionController,
                isSenderEditable: isSenderEditable,
                configuration: configuration
            )
        case .nodeSettings:
            viewController = NodeSettingsViewController(configuration: configuration)
        case .addNode:
            viewController = AddNodeViewController(mode: .new, configuration: configuration)
        case let .editNode(node):
            viewController = AddNodeViewController(mode: .edit(node: node), configuration: configuration)
        case let .transactionDetail(account, transaction, transactionType, assetDetail):
            viewController = TransactionDetailViewController(
                account: account,
                transaction: transaction,
                transactionType: transactionType,
                assetDetail: assetDetail,
                configuration: configuration
            )
        case let .assetDetail(account, assetDetail):
            viewController = AssetDetailViewController(account: account, configuration: configuration, assetDetail: assetDetail)
        case let .addAsset(account):
            viewController = AssetAdditionViewController(account: account, configuration: configuration)
        case let .removeAsset(account):
            viewController = AssetRemovalViewController(account: account, configuration: configuration)
        case let .assetActionConfirmation(assetAlertDraft):
            viewController = AssetActionConfirmationViewController(assetAlertDraft: assetAlertDraft, configuration: configuration)
        case let .assetSupport(assetAlertDraft):
            viewController = AssetSupportViewController(assetAlertDraft: assetAlertDraft, configuration: configuration)
        case let .bottomInformation(mode, configurator):
            viewController = BottomInformationViewController(
                mode: mode,
                bottomInformationBundle: configurator,
                configuration: configuration
            )
        case let .rewardDetail(account):
            viewController = RewardDetailViewController(account: account, configuration: configuration)
        case .verifiedAssetInformation:
            viewController = VerifiedAssetInformationViewController(configuration: configuration)
        case let .ledgerTutorial(flow):
            viewController = LedgerTutorialViewController(accountSetupFlow: flow, configuration: configuration)
        case let .ledgerDeviceList(flow):
            viewController = LedgerDeviceListViewController(accountSetupFlow: flow, configuration: configuration)
        case .ledgerTroubleshoot:
            viewController = LedgerTroubleshootingViewController(configuration: configuration)
        case let .ledgerApproval(mode):
            viewController = LedgerApprovalViewController(mode: mode, configuration: configuration)
        case .ledgerTroubleshootBluetooth:
            viewController = LedgerTroubleshootBluetoothConnectionViewController(configuration: configuration)
        case .ledgerTroubleshootLedgerConnection:
            viewController = LedgerTroubleshootBluetoothViewController(configuration: configuration)
        case .ledgerTroubleshootInstallApp:
            viewController = LedgerTroubleshootInstallAppViewController(configuration: configuration)
        case .ledgerTroubleshootOpenApp:
            viewController = LedgerTroubleshootOpenAppViewController(configuration: configuration)
        case let .selectAsset(transactionAction, filterOption):
            viewController = SelectAssetViewController(
                transactionAction: transactionAction,
                filterOption: filterOption,
                configuration: configuration
            )
        case let .passphraseDisplay(address):
            viewController = PassphraseDisplayViewController(address: address, configuration: configuration)
        case let .tooltip(title):
            viewController = TooltipViewController(title: title, configuration: configuration)
        case .pinLimit:
            viewController = PinLimitViewController(configuration: configuration)
        case .assetActionConfirmationNotification,
             .assetDetailNotification:
            return nil
        case let .transactionFilter(filterOption):
            viewController = TransactionFilterViewController(filterOption: filterOption, configuration: configuration)
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
        case let .maximumBalanceWarning(account):
            viewController = MaximumBalanceWarningViewController(account: account, configuration: configuration)
        case .screenshotWarning:
            viewController = ScreenshotWarningViewController(configuration: configuration)
        case let .warningAlert(warningAlert):
            viewController = WarningAlertViewController(warningAlert: warningAlert, configuration: configuration)
        case let .actionableWarningAlert(warningAlert):
            viewController = ActionableWarningAlertViewController(warningAlert: warningAlert, configuration: configuration)
        case let .animatedTutorial(flow, tutorial, isActionable):
            viewController = AnimatedTutorialViewController(
                flow: flow,
                tutorial: tutorial,
                isActionable: isActionable,
                configuration: configuration
            )
        case let .transactionTutorial(isInitialDisplay):
            viewController = TransactionTutorialViewController(isInitialDisplay: isInitialDisplay, configuration: configuration)
        case .recoverOptions:
            viewController = AccountRecoverOptionsViewController(configuration: configuration)
        case let .algoUSDAnalytics(account, currency):
            viewController = AlgoUSDAnalyticsViewController(account: account, currency: currency, configuration: configuration)
        case let .ledgerAccountVerification(flow, selectedAccounts):
            viewController = LedgerAccountVerificationViewController(
                accountSetupFlow: flow,
                selectedAccounts: selectedAccounts,
                configuration: configuration
            )
        case let .wcConnectionApproval(walletConnectSession, completion):
            viewController = WCConnectionApprovalViewController(
                walletConnectSession: walletConnectSession,
                walletConnectSessionConnectionCompletionHandler: completion,
                configuration: configuration
            )
        case .walletConnectSessions:
            viewController = WCSessionListViewController(configuration: configuration)
        case let .wcTransactionFullDappDetail(wcSession, message):
            viewController = WCTransactionFullDappDetailViewController(
                wcSession: wcSession,
                message: message,
                configuration: configuration
            )
        case let .wcMainTransaction(transactions, transactionRequest, transactionOption):
            viewController = WCMainTransactionViewController(
                transactions: transactions,
                transactionRequest: transactionRequest,
                transactionOption: transactionOption,
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
        case .ledgerPairWarning:
            viewController = LedgerPairWarningViewController(configuration: configuration)
        }
        
        return viewController as? T
    }
    // swiftlint:enable function_body_length
}
