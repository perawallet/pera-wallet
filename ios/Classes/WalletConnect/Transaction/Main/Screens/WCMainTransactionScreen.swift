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
//   WCMainTransactionScreen.swift

import Foundation
import MacaroonUIKit
import MacaroonBottomOverlay
import UIKit
import SnapKit

protocol WCMainTransactionScreenDelegate: AnyObject {
    func wcMainTransactionScreen(
        _ wcMainTransactionScreen: WCMainTransactionScreen,
        didSigned request: WalletConnectRequest,
        in session: WCSession?
    )
    func wcMainTransactionScreen(
         _ wcMainTransactionScreen: WCMainTransactionScreen,
         didRejected request: WalletConnectRequest
     )
}

final class WCMainTransactionScreen: BaseViewController, Container {
    weak var delegate: WCMainTransactionScreenDelegate?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var dappMessageView = WCTransactionDappMessageView()

    private lazy var theme = Theme()

    private lazy var singleTransactionFragment: WCSingleTransactionRequestScreen = {
        return WCSingleTransactionRequestScreen(
            dataSource: self.dataSource,
            configuration: configuration,
            currencyFormatter: currencyFormatter
        )
    }()

    private lazy var unsignedTransactionFragment: WCUnsignedRequestScreen = {
        return WCUnsignedRequestScreen(
            dataSource: self.dataSource,
            configuration: configuration
        )
    }()

    private var headerTransaction: WCTransaction?
    private var ledgerApprovalViewController: LedgerApprovalViewController?

    private lazy var modalTransition = BottomSheetTransition(presentingViewController: self)

    private lazy var wcTransactionSigner: WCTransactionSigner = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return WCTransactionSigner(api: api, analytics: analytics)
    }()

    private var transactionParams: TransactionParams?
    private var signedTransactions: [Data?] = []

    private var isRejected = false

    private let wcSession: WCSession?

    let transactions: [WCTransaction]
    let transactionRequest: WalletConnectRequest
    let transactionOption: WCTransactionOption?

    let dataSource: WCMainTransactionDataSource

    private let currencyFormatter: CurrencyFormatter

    init(
        draft: WalletConnectRequestDraft,
        configuration: ViewControllerConfiguration
    ) {
        let currencyFormatter = CurrencyFormatter()

        self.transactions = draft.transactions
        self.transactionRequest = draft.request
        self.transactionOption = draft.option
        self.wcSession = configuration.walletConnector.getWalletConnectSession(with: WCURLMeta(wcURL: transactionRequest.url))
        self.dataSource = WCMainTransactionDataSource(
            sharedDataController: configuration.sharedDataController,
            transactions: transactions,
            transactionRequest: transactionRequest,
            transactionOption: transactionOption,
            walletConnector: configuration.walletConnector,
            currencyFormatter: currencyFormatter
        )
        self.currencyFormatter = currencyFormatter

        super.init(configuration: configuration)

        dataSource.delegate = self
        setTransactionSigners()
        setupObserver()
    }

    deinit {
        removeObserver()
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.backgroundColor = theme.backgroundColor
    }

    override func prepareLayout() {
        super.prepareLayout()

        addDappInfoView()
        addSingleTransaction()
    }

    override func linkInteractors() {
        super.linkInteractors()

        singleTransactionFragment.delegate = self
        unsignedTransactionFragment.delegate = self
        wcTransactionSigner.delegate = self
        dappMessageView.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        loadingController?.stopLoading()

        if !transactions.allSatisfy({ ($0.requestedSigner.account?.requiresLedgerConnection() ?? false) }) {
            return
        }

        wcTransactionSigner.disonnectFromLedger()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentInitialWarningAlertIfNeeded()
    }

    override func viewDidLoad() {
        dataSource.load()

        super.viewDidLoad()

        guard dataSource.hasValidGroupTransaction else {
            /// <note>: This check prevents to show multiple reject sheet
            /// When data source load function called, it will call delegate function to let us know if group transaction is not validated
            /// We could remove group validation in `validateTransactions` function but it also has another logic in it.s
            return
        }

        validateTransactions(transactions, with: dataSource.groupedTransactions)
        getAssetDetailsIfNeeded()
        getTransactionParams()
    }

    override func bindData() {
        super.bindData()

        bindDappInfoView()
    }

    private func setupObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observeHeaderUpdate(notification:)),
            name: .SingleTransactionHeaderUpdate,
            object: nil
        )
    }

    private func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: .SingleTransactionHeaderUpdate,
            object: nil
        )
    }

    @objc
    private func observeHeaderUpdate(notification: Notification) {
        self.headerTransaction = notification.object as? WCTransaction

        bindDappInfoView()
    }

    private func bindDappInfoView() {
        guard let wcSession = walletConnector.allWalletConnectSessions.first(matching: (\.urlMeta.wcURL, transactionRequest.url)) else {
            return
        }

        let viewModel = WCTransactionDappMessageViewModel(
            session: wcSession,
            imageSize: CGSize(width: 48.0, height: 48.0),
            transactionOption: transactionOption,
            transaction: headerTransaction
        )

        dappMessageView.bind(viewModel)
    }

    private func addDappInfoView() {
        view.addSubview(dappMessageView)
        dappMessageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(theme.dappViewLeadingInset)
            make.top.safeEqualToTop(of: self).offset(theme.dappViewTopInset)
        }
    }

    private func addSingleTransaction() {
        let fragment = transactions.count > 1 ? unsignedTransactionFragment : singleTransactionFragment
        let container = NavigationContainer(rootViewController: fragment)
        addFragment(container) { fragmentView in
            fragmentView.roundCorners(corners: [.topLeft, .topRight], radius: theme.fragmentRadius)
            view.addSubview(fragmentView)
            fragmentView.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(theme.fragmentTopInset)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
    }
}

//MARK: Signing Transactions
extension WCMainTransactionScreen: WCTransactionSignerDelegate {
    private func setTransactionSigners() {
        if let session = session {
            transactions.forEach { $0.findSignerAccount(in: sharedDataController.accountCollection, on: session) }
        }
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
            transaction.requestedSigner.account != nil
        }
    }

    private func fillInitialUnsignedTransactions(until index: Int) {
        for _ in 0..<index {
            signedTransactions.append(nil)
        }
    }

    private func signTransaction(_ transaction: WCTransaction) {
        if let signerAccount = transaction.requestedSigner.account {
            wcTransactionSigner.signTransaction(transaction, with: dataSource.transactionRequest, for: signerAccount)
        } else {
            signedTransactions.append(nil)
        }
    }

    func wcTransactionSigner(_ wcTransactionSigner: WCTransactionSigner, didSign transaction: WCTransaction, signedTransaction: Data) {
        signedTransactions.append(signedTransaction)
        continueSigningTransactions(after: transaction)
    }

    private func continueSigningTransactions(after transaction: WCTransaction) {
        if let index = transactions.firstIndex(of: transaction),
           let nextTransaction = transactions.nextElement(afterElementAt: index) {
            if let signerAccount = nextTransaction.requestedSigner.account {
                wcTransactionSigner.signTransaction(nextTransaction, with: transactionRequest, for: signerAccount)
            } else {
                signedTransactions.append(nil)
                continueSigningTransactions(after: nextTransaction)
            }
            return
        }

        if transactions.count != signedTransactions.count {
            rejectSigning(reason: .invalidInput(.unsignable))
            return
        }

        sendSignedTransactions()
    }

    private func sendSignedTransactions() {
        dataSource.signTransactionRequest(signature: signedTransactions)
        logAllTransactions()
        delegate?.wcMainTransactionScreen(self, didSigned: transactionRequest, in: wcSession)
    }

    private func logAllTransactions() {
        transactions.forEach { transaction in
            if let transactionData = transaction.unparsedTransactionDetail,
               let session = wcSession {
                let transactionID = AlgorandSDK().getTransactionID(for: transactionData)
                analytics.track(
                    .wcTransactionConfirmed(
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
            rejectSigning(reason: .rejected(.unsignable))
        case let .ledger(ledgerError):
            showLedgerError(ledgerError)
        }
    }

    func wcTransactionSigner(
        _ wcTransactionSigner: WCTransactionSigner,
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
                self.loadingController?.stopLoading()
            }
        }
    }

    func wcTransactionSignerDidFinishTimingOperation(_ wcTransactionSigner: WCTransactionSigner) {

    }

    func wcTransactionSignerDidResetLedgerOperation(_ wcTransactionSigner: WCTransactionSigner) {
        ledgerApprovalViewController?.dismissScreen()
    }

    func wcTransactionSignerDidRejectedLedgerOperation(_ wcTransactionSigner: WCTransactionSigner) {
        loadingController?.stopLoading()
    }

    private func showLedgerError(_ ledgerError: LedgerOperationError) {
        switch ledgerError {
        case .cancelled:
            bannerController?.presentErrorBanner(
                title: "ble-error-transaction-cancelled-title".localized, message: "ble-error-fail-sign-transaction".localized
            )
        case .closedApp:
            bannerController?.presentErrorBanner(
                title: "ble-error-ledger-connection-title".localized, message: "ble-error-ledger-connection-open-app-error".localized
            )
        case .failedToFetchAddress:
            bannerController?.presentErrorBanner(
                title: "ble-error-transmission-title".localized,
                message: "ble-error-fail-fetch-account-address".localized
            )
        case .failedToFetchAccountFromIndexer:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "ledger-account-fetct-error".localized
            )
        case let .custom(title, message):
            bannerController?.presentErrorBanner(
                title: title,
                message: message
            )
        default:
            break
        }
    }

    private func confirmTransaction() {
        let containsFutureTransaction = transactions.contains {
            guard let params = transactionParams else {
                return false
            }

            return $0.isFutureTransaction(with: params)
        }

        if containsFutureTransaction {
            presentSigningFutureTransactionAlert()
            return
        }

        confirmSigning()
    }

    private func presentSigningFutureTransactionAlert() {
        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-red".uiImage,
            title: "wallet-connect-transaction-request-signing-future-transaction-alert-title".localized,
            description: .plain("wallet-connect-transaction-request-signing-future-transaction-alert-description".localized),
            primaryActionButtonTitle: "title-accept".localized,
            secondaryActionButtonTitle: "title-cancel".localized,
            primaryAction: { [weak self] in
                self?.confirmSigning()
            }
        )

        modalTransition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
    }

    private func presentInitialWarningAlertIfNeeded() {
        let oneTimeDisplayStorage = OneTimeDisplayStorage()

        if oneTimeDisplayStorage.isDisplayedOnce(for: .wcInitialWarning) {
            return
        }

        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-green-large".uiImage,
            title: "wallet-connect-transaction-warning-initial-title".localized,
            description: .plain("wallet-connect-transaction-warning-initial-description".localized),
            secondaryActionButtonTitle: "title-close".localized
        )

        modalTransition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
        oneTimeDisplayStorage.setDisplayedOnce(for: .wcInitialWarning)
    }
}

extension WCMainTransactionScreen: WCSingleTransactionRequestScreenDelegate {
    func wcSingleTransactionRequestScreenDidReject(_ wcSingleTransactionRequestScreen: WCSingleTransactionRequestScreen) {
        rejectSigning()
        dismissScreen()

    }

    func wcSingleTransactionRequestScreenDidConfirm(_ wcSingleTransactionRequestScreen: WCSingleTransactionRequestScreen) {
        confirmTransaction()
    }
}

extension WCMainTransactionScreen: WCUnsignedRequestScreenDelegate {
    func wcUnsignedRequestScreenDidReject(_ wcUnsignedRequestScreen: WCUnsignedRequestScreen) {
        rejectSigning()
        dismissScreen()
    }

    func wcUnsignedRequestScreenDidConfirm(_ wcUnsignedRequestScreen: WCUnsignedRequestScreen) {
        confirmTransaction()
    }
}

extension WCMainTransactionScreen {

    private func rejectSigning(reason: WCTransactionErrorResponse = .rejected(.user)) {
        if isRejected { return }

        switch reason {
        case .rejected(let rejection):
            if rejection == .user {
                rejectTransaction(with: reason)
            }
        default:
            showRejectionReasonBottomSheet(reason)
        }

        self.isRejected = true
    }

    private func showRejectionReasonBottomSheet(_ reason: WCTransactionErrorResponse) {
        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-red".uiImage,
            title: "title-error".localized,
            description: .plain("wallet-connect-no-account-for-transaction".localized(params: reason.message)),
            secondaryActionButtonTitle: "title-ok".localized,
            secondaryAction: { [weak self] in
                guard let self = self else {
                    return
                }
                self.rejectTransaction(with: reason)
            }
        )

        modalTransition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
    }

    private func rejectTransaction(with reason: WCTransactionErrorResponse) {
        dataSource.rejectTransaction(reason: reason)
        delegate?.wcMainTransactionScreen(self, didRejected: transactionRequest)
    }
}

extension WCMainTransactionScreen: WCTransactionValidator {
    func rejectTransactionRequest(with error: WCTransactionErrorResponse) {
        rejectSigning(reason: error)
    }
}

extension WCMainTransactionScreen: AssetCachable {
    private func getAssetDetailsIfNeeded() {
        let assetTransactions = transactions.filter {
            if let transactionDetail = $0.transactionDetail {
                return (!transactionDetail.isAssetCreationTransaction) &&
                    (transactionDetail.type == .assetTransfer || transactionDetail.type == .assetConfig)
            }

            return false
        }

        guard !assetTransactions.isEmpty else {
            return
        }

        for (index, transaction) in assetTransactions.enumerated() {
            guard let assetId = transaction.transactionDetail?.currentAssetId else {
                loadingController?.stopLoading()
                self.rejectSigning(reason: .invalidInput(.asset))
                return
            }

            cacheAssetDetail(with: assetId) { [weak self] assetDetail in
                guard let self = self else {
                    return
                }

                if assetDetail == nil {
                    self.loadingController?.stopLoading()
                    self.rejectSigning(reason: .invalidInput(.unableToFetchAsset))
                    return
                }

                self.sharedDataController.assetDetailCollection[assetId] = assetDetail

                if index == assetTransactions.count - 1 {
                    self.loadingController?.stopLoading()
                    NotificationCenter.default.post(name: .AssetDetailFetched, object: nil)
                }
            }
        }
    }
}

extension WCMainTransactionScreen {
    private func getTransactionParams() {
        sharedDataController.getTransactionParams { [weak self] result in
            guard let self else {
                return
            }

            switch result {
            case .success(let params):
                self.transactionParams = params
            case .failure:
                break
            }

            self.rejectIfTheNetworkIsInvalid()
        }
    }

    private func rejectIfTheNetworkIsInvalid() {
         if !hasValidNetwork(for: transactions) {
             rejectSigning(reason: .unauthorized(.nodeMismatch))
             return
         }
     }

     private func hasValidNetwork(for transactions: [WCTransaction]) -> Bool {
         guard let params = transactionParams else {
             return false
         }

         return transactions.contains { $0.isInTheSameNetwork(with: params) }
     }
}

extension WCMainTransactionScreen: WCTransactionDappMessageViewDelegate {
    func wcTransactionDappMessageViewDidTapped(
        _ WCTransactionDappMessageView: WCTransactionDappMessageView
    ) {
        guard let session = wcSession else {
            return
        }

        let configurator = WCTransactionFullDappDetailConfigurator(
            from: session,
            option: transactionOption,
            transaction: transactions.first
        )

        modalTransition.perform(.wcTransactionFullDappDetail(configurator: configurator), by: .presentWithoutNavigationController)
    }
}

extension WCMainTransactionScreen: WCMainTransactionDataSourceDelegate {
    func wcMainTransactionDataSourceDidFailedGroupingValidation(
        _ wcMainTransactionDataSource: WCMainTransactionDataSource
    ) {
        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-red".uiImage,
            title: "title-error".localized,
            description: .plain("wallet-connect-transaction-error-invalid-group".localized),
            secondaryActionButtonTitle: "title-ok".localized,
            secondaryAction: { [weak self] in
                self?.rejectTransaction(with: .rejected(.failedValidation))
            }
        )

        modalTransition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
    }

    func wcMainTransactionDataSourceDidOpenLongDappMessageView(
        _ wcMainTransactionDataSource: WCMainTransactionDataSource
    ) {

    }
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
