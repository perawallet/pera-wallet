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
//   WCMainTransactionViewController.swift

import UIKit
import Magpie
import SVProgressHUD

class WCMainTransactionViewController: BaseViewController {

    private lazy var mainTransactionView = WCMainTransactionView()

    private lazy var dappMessageModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 330.0))
    )

    private lazy var initialWarningModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 380.0))
    )

    private lazy var confirmationModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .backgroundTouch
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 442.0))
    )

    weak var delegate: WCMainTransactionViewControllerDelegate?

    private lazy var dataSource = WCMainTransactionDataSource(
        transactions: transactions,
        transactionRequest: transactionRequest,
        transactionOption: transactionOption,
        session: session,
        walletConnector: walletConnector
    )

    private lazy var layoutBuilder = WCMainTransactionLayout(dataSource: dataSource)

    private lazy var wcTransactionSigner: WCTransactionSigner = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return WCTransactionSigner(api: api)
    }()

    private let transactions: [WCTransaction]
    private let transactionRequest: WalletConnectRequest
    private let wcSession: WCSession?
    private let transactionOption: WCTransactionOption?

    private var transactionParams: TransactionParams?

    private var signedTransactions: [Data?] = []

    init(
        transactions: [WCTransaction],
        transactionRequest: WalletConnectRequest,
        transactionOption: WCTransactionOption?,
        configuration: ViewControllerConfiguration
    ) {
        self.transactions = transactions
        self.transactionRequest = transactionRequest
        self.transactionOption = transactionOption
        self.wcSession = configuration.walletConnector.getWalletConnectSession(with: WCURLMeta(wcURL: transactionRequest.url))
        super.init(configuration: configuration)
        setTransactionSigners()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getAssetDetailsIfNeeded()
        getTransactionParams()
        validateTransactions(transactions, with: dataSource.groupedTransactions)
        cacheAllAssetsInTheTransactions()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentInitialWarningAlertIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if SVProgressHUD.isVisible() {
            SVProgressHUD.showError(withStatus: "title-done".localized)
            SVProgressHUD.dismiss()
        }
        
        if !transactions.allSatisfy({ ($0.signerAccount?.requiresLedgerConnection() ?? false) }) {
            return
        }

        wcTransactionSigner.disonnectFromLedger()
    }

    override func configureAppearance() {
        super.configureAppearance()
        title = "wallet-connect-transaction-title-unsigned".localized
    }

    override func linkInteractors() {
        mainTransactionView.delegate = self
        mainTransactionView.setDataSource(dataSource)
        mainTransactionView.setDelegate(layoutBuilder)
        dataSource.delegate = self
        layoutBuilder.delegate = self
        wcTransactionSigner.delegate = self
    }

    override func prepareLayout() {
        prepareWholeScreenLayoutFor(mainTransactionView)
    }

    override func bindData() {
        super.bindData()
        mainTransactionView.bind(WCMainTransactionViewModel(transactions: transactions))
    }
}

extension WCMainTransactionViewController {
    private func setTransactionSigners() {
        if let session = session {
            transactions.forEach { $0.findSignerAccount(in: session) }
        }
    }

    private func getTransactionParams() {
        api?.getTransactionParams { response in
            switch response {
            case .failure:
                break
            case let .success(params):
                self.transactionParams = params
            }
        }
    }

    private func presentInitialWarningAlertIfNeeded() {
        let oneTimeDisplayStorage = OneTimeDisplayStorage()

        if oneTimeDisplayStorage.isDisplayedOnce(for: .wcInitialWarning) {
            return
        }

        let transitionStyle = Screen.Transition.Open.customPresent(
            presentationStyle: .custom,
            transitionStyle: nil,
            transitioningDelegate: initialWarningModalPresenter
        )

        let warningAlert = WarningAlert(
            title: "node-settings-warning-title".localized,
            image: img("img-warning-circle"),
            description: "wallet-connect-transaction-warning-initial".localized,
            actionTitle: "title-got-it".localized
        )

        oneTimeDisplayStorage.setDisplayedOnce(for: .wcInitialWarning)
        
        let controller = open(.warningAlert(warningAlert: warningAlert), by: transitionStyle) as? WarningAlertViewController
        controller?.delegate = self
    }

    private func presentConfirmationAlert() {
        guard let params = transactionParams ?? UIApplication.shared.accountManager?.params else {
            return
        }

        let transitionStyle = Screen.Transition.Open.customPresent(
            presentationStyle: .custom,
            transitionStyle: nil,
            transitioningDelegate: confirmationModalPresenter
        )

        let containsFutureTransaction = transactions.contains { $0.isFutureTransaction(with: params) }
        let description = containsFutureTransaction ?
            "wallet-connect-transaction-warning-future".localized + "wallet-connect-transaction-warning-confirmation".localized :
            "wallet-connect-transaction-warning-confirmation".localized

        let warningAlert = WarningAlert(
            title: "contacts-close-warning-title".localized,
            image: img("img-warning-circle"),
            description: description,
            actionTitle: "title-accept".localized
        )

        let controller = open(
            .actionableWarningAlert(warningAlert: warningAlert),
            by: transitionStyle
        ) as? ActionableWarningAlertViewController
        controller?.delegate = self
    }

    private func cacheAllAssetsInTheTransactions() {
        for transaction in transactions where transaction.transactionDetail?.currentAssetId != nil {
            guard let assetId = transaction.transactionDetail?.currentAssetId else {
                continue
            }

            cacheAssetDetail(with: assetId) { [weak self] _ in
                guard let self = self else {
                    return
                }

                if self.transactions.last == transaction {
                    self.mainTransactionView.reloadData()
                }
            }
        }
    }
}

extension WCMainTransactionViewController: WCTransactionValidator {
    func rejectTransactionRequest(with error: WCTransactionErrorResponse) {
        walletConnector.rejectTransactionRequest(transactionRequest, with: error)
        delegate?.wcMainTransactionViewController(self, didCompleted: transactionRequest)
        dismissScreen()
    }
}

extension WCMainTransactionViewController: WCMainTransactionViewDelegate {
    func wcMainTransactionViewDidConfirmSigning(_ wcMainTransactionView: WCMainTransactionView) {
        presentConfirmationAlert()
    }

    private func confirmSigning() {
        if let transaction = getFirstSignableTransaction(),
           let index = transactions.firstIndex(of: transaction) {
            fillInitialUnsignedTransactions(until: index)
            signTransaction(transaction)
        }
    }

    private func getFirstSignableTransaction() -> WCTransaction? {
        return transactions.first { transaction in
            transaction.signerAccount != nil
        }
    }

    private func fillInitialUnsignedTransactions(until index: Int) {
        for _ in 0..<index {
            signedTransactions.append(nil)
        }
    }

    private func signTransaction(_ transaction: WCTransaction) {
        if let signerAccount = transaction.signerAccount {
            wcTransactionSigner.signTransaction(transaction, with: transactionRequest, for: signerAccount)
        } else {
            signedTransactions.append(nil)
        }
    }

    func wcMainTransactionViewDidDeclineSigning(_ wcMainTransactionView: WCMainTransactionView) {
        if let session = wcSession {
            log(
                WCTransactionDeclinedEvent(
                    transactionCount: transactions.count,
                    dappName: session.peerMeta.name,
                    dappURL: session.peerMeta.url.absoluteString,
                    address: session.walletMeta?.accounts?.first
                )
            )
        }

        rejectTransactionRequest(with: .rejected(.user))
    }
}

extension WCMainTransactionViewController: WCTransactionSignerDelegate {
    func wcTransactionSigner(_ wcTransactionSigner: WCTransactionSigner, didSign transaction: WCTransaction, signedTransaction: Data) {
        signedTransactions.append(signedTransaction)
        continueSigningTransactions(after: transaction)
    }

    private func continueSigningTransactions(after transaction: WCTransaction) {
        if let index = transactions.firstIndex(of: transaction),
           let nextTransaction = transactions.nextElement(afterElementAt: index) {

            if let signerAccount = nextTransaction.signerAccount {
                wcTransactionSigner.signTransaction(nextTransaction, with: transactionRequest, for: signerAccount)
            } else {
                signedTransactions.append(nil)
                continueSigningTransactions(after: nextTransaction)
            }
            return
        }

        if transactions.count != signedTransactions.count {
            rejectTransactionRequest(with: .invalidInput(.unsignable))
            return
        }

        sendSignedTransactions()
    }

    private func sendSignedTransactions() {
        walletConnector.signTransactionRequest(transactionRequest, with: signedTransactions)
        logAllTransactions()
        delegate?.wcMainTransactionViewController(self, didCompleted: transactionRequest)
        dismissScreen()
    }

    private func logAllTransactions() {
        transactions.forEach { transaction in
            if let transactionData = transaction.unparsedTransactionDetail,
               let session = wcSession {
                let transactionID = AlgorandSDK().getTransactionID(for: transactionData)
                log(
                    WCTransactionConfirmedEvent(
                        transactionID: transactionID,
                        dappName: session.peerMeta.name,
                        dappURL: session.peerMeta.url.absoluteString
                    )
                )
            }
        }
    }

    func wcTransactionSigner(_ wcTransactionSigner: WCTransactionSigner, didFailedWith error: WCTransactionSigner.WCSignError) {
        switch error {
        case .api:
            rejectTransactionRequest(with: .rejected(.unsignable))
        case let .ledger(ledgerError):
            showLedgerError(ledgerError)
        }
    }

    private func showLedgerError(_ ledgerError: LedgerOperationError) {
        switch ledgerError {
        case .cancelled:
            NotificationBanner.showError(
                "ble-error-transaction-cancelled-title".localized,
                message: "ble-error-fail-sign-transaction".localized
            )
        case .closedApp:
            NotificationBanner.showError(
                "ble-error-ledger-connection-title".localized,
                message: "ble-error-ledger-connection-open-app-error".localized
            )
        default:
            break
        }
    }
}

extension WCMainTransactionViewController: WCMainTransactionLayoutDelegate {
    func wcMainTransactionLayout(
        _ wcMainTransactionLayout: WCMainTransactionLayout,
        didSelect transactions: [WCTransaction]
    ) {
        if transactions.count == 1 {
            if let transaction = transactions.first {
                presentSingleWCTransaction(transaction, with: transactionRequest)
            }

            return
        }

        open(.wcGroupTransaction(transactions: transactions, transactionRequest: transactionRequest), by: .push)
    }
}

extension WCMainTransactionViewController: WalletConnectSingleTransactionRequestPresentable { }

extension WCMainTransactionViewController: AssetCachable {
    private func getAssetDetailsIfNeeded() {
        let assetTransactions = transactions.filter { $0.transactionDetail?.type == .assetTransfer }
        for (index, transaction) in assetTransactions.enumerated() {
            if !SVProgressHUD.isVisible() {
                SVProgressHUD.show(withStatus: "title-loading".localized)
            }

            guard let assetId = transaction.transactionDetail?.assetId else {
                SVProgressHUD.showError(withStatus: "title-done".localized)
                SVProgressHUD.dismiss()
                self.rejectTransactionRequest(with: .invalidInput(.asset))
                return
            }

            cacheAssetDetail(with: assetId) { assetDetail in
                if assetDetail == nil {
                    SVProgressHUD.showError(withStatus: "title-done".localized)
                    SVProgressHUD.dismiss()
                    self.rejectTransactionRequest(with: .invalidInput(.asset))
                    return
                }

                if index == assetTransactions.count - 1 {
                    SVProgressHUD.showSuccess(withStatus: "title-done".localized)
                    SVProgressHUD.dismiss()
                    self.mainTransactionView.reloadData()
                }
            }
        }
    }
}

extension WCMainTransactionViewController: WCMainTransactionDataSourceDelegate {
    func wcMainTransactionDataSourceDidFailedGroupingValidation(_ wcMainTransactionDataSource: WCMainTransactionDataSource) {
        rejectTransactionRequest(with: .rejected(.failedValidation))
    }

    func wcMainTransactionDataSourceDidOpenLongDappMessageView(_ wcMainTransactionDataSource: WCMainTransactionDataSource) {
        guard let wcSession = wcSession,
              let message = transactionOption?.message else {
            return
        }

        open(
            .wcTransactionFullDappDetail(
                wcSession: wcSession,
                message: message
            ),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: dappMessageModalPresenter
            )
        )
    }
}

extension WCMainTransactionViewController: WarningAlertViewControllerDelegate {
    func warningAlertViewControllerDidTakeAction(_ warningAlertViewController: WarningAlertViewController) {
        warningAlertViewController.dismissScreen()
    }
}

extension WCMainTransactionViewController: ActionableWarningAlertViewControllerDelegate {
    func actionableWarningAlertViewControllerDidTakeAction(_ actionableWarningAlertViewController: ActionableWarningAlertViewController) {
        actionableWarningAlertViewController.dismissScreen()
        confirmSigning()
    }
}

protocol WCMainTransactionViewControllerDelegate: AnyObject {
    func wcMainTransactionViewController(
        _ wcMainTransactionViewController: WCMainTransactionViewController,
        didCompleted request: WalletConnectRequest
    )
}

enum WCTransactionType {
    case algos
    case asset
    case assetAddition
    case possibleAssetAddition
    case appCall
    case assetConfig(type: AssetConfigType)
}

enum AssetConfigType {
    case create
    case delete
    case reconfig
}
