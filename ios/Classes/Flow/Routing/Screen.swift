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
//  Screen.swift

import UIKit

indirect enum Screen {
    case introduction(flow: AccountSetupFlow)
    case welcome(flow: AccountSetupFlow)
    case addAccount(flow: AccountSetupFlow)
    case choosePassword(mode: ChoosePasswordViewController.Mode, flow: AccountSetupFlow?, route: Screen?)
    case passphraseView(address: String)
    case passphraseVerify
    case accountNameSetup
    case accountRecover(flow: AccountSetupFlow)
    case qrScanner(canReadWCSession: Bool)
    case qrGenerator(title: String?, draft: QRCreationDraft, isTrackable: Bool = false)
    case home(route: Screen?)
    case assetDetail(account: Account, assetDetail: AssetDetail?)
    case options(account: Account)
    case accountList(mode: AccountListViewController.Mode)
    case editAccount(account: Account)
    case contactSelection
    case addContact(mode: AddContactViewController.Mode)
    case contactDetail(contact: Contact)
    case sendAlgosTransactionPreview(account: Account?, receiver: AssetReceiverState, isSenderEditable: Bool, qrText: QRText? = nil)
    case sendAssetTransactionPreview(
        account: Account?,
        receiver: AssetReceiverState,
        assetDetail: AssetDetail,
        isSenderEditable: Bool,
        isMaxTransaction: Bool,
        qrText: QRText? = nil
    )
    case sendAlgosTransaction(
        algosTransactionSendDraft: AlgosTransactionSendDraft,
        transactionController: TransactionController,
        receiver: AssetReceiverState,
        isSenderEditable: Bool
    )
    case sendAssetTransaction(
        assetTransactionSendDraft: AssetTransactionSendDraft,
        transactionController: TransactionController,
        receiver: AssetReceiverState,
        isSenderEditable: Bool
    )
    case nodeSettings
    case addNode
    case editNode(node: Node)
    case transactionDetail(account: Account, transaction: Transaction, transactionType: TransactionType, assetDetail: AssetDetail?)
    case addAsset(account: Account)
    case removeAsset(account: Account)
    case assetActionConfirmation(assetAlertDraft: AssetAlertDraft)
    case assetSupport(assetAlertDraft: AssetAlertDraft)
    case bottomInformation(mode: BottomInformationViewController.Mode, configurator: BottomInformationBundle)
    case rewardDetail(account: Account)
    case verifiedAssetInformation
    case ledgerTutorial(flow: AccountSetupFlow)
    case ledgerDeviceList(flow: AccountSetupFlow)
    case ledgerTroubleshoot
    case ledgerApproval(mode: LedgerApprovalViewController.Mode)
    case ledgerTroubleshootBluetooth
    case ledgerTroubleshootLedgerConnection
    case ledgerTroubleshootInstallApp
    case ledgerTroubleshootOpenApp
    case selectAsset(transactionAction: TransactionAction, filterOption: SelectAssetViewController.FilterOption = .none)
    case passphraseDisplay(address: String)
    case tooltip(title: String)
    case assetDetailNotification(address: String, assetId: Int64?)
    case assetActionConfirmationNotification(address: String, assetId: Int64?)
    case transactionFilter(filterOption: TransactionFilterViewController.FilterOption = .allTime)
    case transactionFilterCustomRange(fromDate: Date?, toDate: Date?)
    case pinLimit
    case rekeyInstruction(account: Account)
    case rekeyConfirmation(account: Account, ledgerDetail: LedgerDetail?, ledgerAddress: String)
    case ledgerAccountSelection(flow: AccountSetupFlow, accounts: [Account])
    case developerSettings
    case currencySelection
    case appearanceSelection
    case watchAccountAddition(flow: AccountSetupFlow)
    case ledgerAccountDetail(account: Account, ledgerIndex: Int?, rekeyedAccounts: [Account]?)
    case notificationFilter(flow: NotificationFilterViewController.Flow)
    case maximumBalanceWarning(account: Account)
    case screenshotWarning
    case warningAlert(warningAlert: WarningAlert)
    case actionableWarningAlert(warningAlert: WarningAlert)
    case animatedTutorial(flow: AccountSetupFlow, tutorial: AnimatedTutorial, isActionable: Bool)
    case transactionTutorial(isInitialDisplay: Bool)
    case recoverOptions
    case algoUSDAnalytics(account: Account, currency: Currency)
    case ledgerAccountVerification(flow: AccountSetupFlow, selectedAccounts: [Account])
    case wcConnectionApproval(walletConnectSession: WalletConnectSession, completion: WalletConnectSessionConnectionCompletionHandler)
    case walletConnectSessions
    case wcTransactionFullDappDetail(wcSession: WCSession, message: String)
    case wcMainTransaction(
            transactions: [WCTransaction],
            transactionRequest: WalletConnectRequest,
            transactionOption: WCTransactionOption?
         )
    case wcAlgosTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcAssetTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcAssetAdditionTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcGroupTransaction(transactions: [WCTransaction], transactionRequest: WalletConnectRequest)
    case wcAppCall(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcAssetCreationTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcAssetReconfigurationTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcAssetDeletionTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case jsonDisplay(jsonData: Data, title: String)
    case ledgerPairWarning
}

extension Screen {
    enum Transition {
    }
}

extension Screen.Transition {
    enum Open: Equatable {
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
