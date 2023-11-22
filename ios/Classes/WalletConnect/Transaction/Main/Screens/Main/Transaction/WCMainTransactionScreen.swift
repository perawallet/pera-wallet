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
import MacaroonUtils
import MagpieHipo
import MacaroonBottomOverlay
import UIKit
import SnapKit

/// <todo>
/// Refactor.
/// <todo>
/// Fix the data management which blocks the main thread on too many transactions.
final class WCMainTransactionScreen:
    BaseViewController,
    Container {
    weak var delegate: WCMainTransactionScreenDelegate?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return api!.isTestNet ? .darkContent : .lightContent
    }

    private lazy var theme = Theme()

    private lazy var dappMessageView = WCTransactionDappMessageView()

    private lazy var transitionToLedgerConnection = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToLedgerConnectionIssuesWarning =
        BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToSignWithLedgerProcess = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToRejectionReason = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToFailedGroupingTransactions = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToSigningFutureTransaction = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToFullDappDetail = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToInitialTransactionWarning = BottomSheetTransition(presentingViewController: self)

    private lazy var wcTransactionSigner = createTransactionSigner()
    private lazy var transactionSignQueue = DispatchQueue.global(qos: .userInitiated)

    private lazy var initialDataLoadingQueue = DispatchQueue(
        label: "wcMainTransactionScreen.initialDataLoadingQueue",
        qos: .userInitiated
    )
    private lazy var initialDataLoadingDispatchGroup = DispatchGroup()

    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?

    private var headerTransaction: WCTransaction?
    
    private var transactionParams: TransactionParams?
    private var signedTransactions: [Data?] = []

    private var isRejected = false

    private var isViewLayoutLoaded = false

    private let transactions: [WCTransaction]
    private let transactionRequest: WalletConnectRequestDraft
    private let transactionOption: WCTransactionOption?
    private let wcSession: WCSessionDraft
    private let dataSource: WCMainTransactionDataSource
    private let currencyFormatter: CurrencyFormatter

    init(
        draft: WalletConnectTransactionSignRequestDraft,
        configuration: ViewControllerConfiguration
    ) {
        self.transactions = draft.transactions
        self.transactionRequest = draft.request
        self.transactionOption = draft.option
        self.wcSession = draft.session
        let currencyFormatter = CurrencyFormatter()
        self.dataSource = WCMainTransactionDataSource(
            sharedDataController: configuration.sharedDataController,
            transactions: transactions,
            transactionRequest: draft.request,
            transactionOption: transactionOption,
            wcSession: draft.session,
            peraConnect: configuration.peraConnect,
            currencyFormatter: currencyFormatter
        )
        self.currencyFormatter = currencyFormatter

        super.init(configuration: configuration)
    }

    deinit {
        removeObservers()
    }

    override func viewDidLoad() {
        setTransactionSigners()

        dataSource.delegate = self
        dataSource.load()

        super.viewDidLoad()

        addUI()

        addObservers()

        logScreenWhenViewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty { return }

        if !isViewLayoutLoaded {
            guard dataSource.hasValidGroupTransaction else {
                /// <note>: This check prevents to show multiple reject sheet
                /// When data source load function called, it will call delegate function to let us know if group transaction is not validated
                /// We could remove group validation in `validateTransactions` function but it also has another logic in it.
                return
            }

            loadInitialData()

            isViewLayoutLoaded = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        logScreenWhenViewDidAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        disconnectFromTheLedgerIfNeeeded()
    }
}

extension WCMainTransactionScreen {
    private func loadInitialData() {
        startLoading()

        initialDataLoadingQueue.async {
            [weak self] in
            guard let self else { return }

            validateTransactions(
                transactions,
                with: dataSource.groupedTransactions,
                sharedDataController: sharedDataController
            )

            /// <note>:
            /// Enter 2 times for `getAssetDetailsIfNeeded` & `getTransactionParams`.
            initialDataLoadingDispatchGroup.enter()
            initialDataLoadingDispatchGroup.enter()

            getAssetDetailsIfNeeded()
            getTransactionParams()

            initialDataLoadingDispatchGroup.notify(queue: .main) {
                [weak self] in
                guard let self else { return }

                stopLoading()

                presentInitialWarningAlertIfNeeded()
            }
        }
    }
}

extension WCMainTransactionScreen {
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdateHeaderTransaction),
            name: .SingleTransactionHeaderUpdate,
            object: nil
        )
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: .SingleTransactionHeaderUpdate,
            object: nil
        )
    }

    @objc
    private func didUpdateHeaderTransaction(notification: Notification) {
        headerTransaction = notification.object as? WCTransaction

        bindDappInfo()
    }
}

extension WCMainTransactionScreen {
    private func bindDappInfo() {
        let viewModel = WCTransactionDappMessageViewModel(
            session: wcSession,
            imageSize: CGSize(width: 48, height: 48),
            transactionOption: transactionOption,
            transaction: headerTransaction
        )
        dappMessageView.bind(viewModel)
    }
}

extension WCMainTransactionScreen {
    private func addUI() {
        addBackground()
        addDappInfo()
        addTransactionFragment()
    }

    private func addBackground() {
        view.backgroundColor = theme.backgroundColor
    }

    private func addDappInfo() {
        view.addSubview(dappMessageView)
        dappMessageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.dappViewLeadingInset)
            $0.top.safeEqualToTop(of: self).offset(theme.dappViewTopInset)
        }

        bindDappInfo()

        dappMessageView.delegate = self
    }

    private func addTransactionFragment() {
        let fragment = makeTransactionFragment()

        let container = NavigationContainer(rootViewController: fragment)

        addFragment(container) { fragmentView in
            fragmentView.roundCorners(
                corners: [.topLeft, .topRight],
                radius: theme.fragmentRadius
            )

            view.addSubview(fragmentView)
            fragmentView.snp.makeConstraints {
                $0.top.equalToSuperview().inset(theme.fragmentTopInset)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        }
    }

    private func makeTransactionFragment() -> UIViewController {
        let isSingleTransaction = transactions.isSingular
        let fragment =
            isSingleTransaction
            ? makeSingleTransactionRequestFragment()
            : makeUnsignedTransactionRequestFragment()
        return fragment
    }

    private func makeSingleTransactionRequestFragment() -> UIViewController {
        let fragment = WCSingleTransactionRequestScreen(
            dataSource: dataSource,
            configuration: configuration,
            currencyFormatter: currencyFormatter
        )
        fragment.delegate = self
        return fragment
    }

    private func makeUnsignedTransactionRequestFragment() -> UIViewController {
        let fragment = WCUnsignedRequestScreen(
            dataSource: dataSource,
            configuration: configuration
        )
        fragment.delegate = self
        return fragment
    }
}

extension WCMainTransactionScreen {
    private func createTransactionSigner() -> WCTransactionSigner {
        let signer = WCTransactionSigner(
            api: api!,
            sharedDataController: sharedDataController,
            analytics: analytics
        )
        signer.delegate = self
        return signer
    }
}

extension WCMainTransactionScreen {
    private func confirmTransaction() {
        startLoading()

        asyncBackground(qos: .userInitiated) {
            [weak self] in
            guard let self else { return }

            let containsFutureTransaction = transactions.contains {
                guard let transactionParams = self.transactionParams else {
                    return false
                }

                return $0.isFutureTransaction(with: transactionParams)
            }

            stopLoading()

            if containsFutureTransaction {
                presentSigningFutureTransactionAlert()
                return
            }

            confirmSigning()
        }
    }

    private func presentSigningFutureTransactionAlert() {
        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-red".uiImage,
            title: "wallet-connect-transaction-request-signing-future-transaction-alert-title".localized,
            description: .plain("wallet-connect-transaction-request-signing-future-transaction-alert-description".localized),
            primaryActionButtonTitle: "title-accept".localized,
            secondaryActionButtonTitle: "title-cancel".localized,
            primaryAction: { [weak self] in
                asyncBackground(qos: .userInitiated) {
                    [weak self] in
                    guard let self else { return }
                    self.confirmSigning()
                }
            }
        )

        asyncMain {
            [weak self] in
            guard let self else { return }

            transitionToSigningFutureTransaction.perform(
                .bottomWarning(configurator: configurator),
                by: .presentWithoutNavigationController
            )
        }
    }

    private func presentInitialWarningAlertIfNeeded() {
        if isRejected { return }

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
        transitionToInitialTransactionWarning.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )

        oneTimeDisplayStorage.setDisplayedOnce(for: .wcInitialWarning)
    }
}

extension WCMainTransactionScreen: WCTransactionSignerDelegate {
    private func setTransactionSigners() {
        if let session {
            transactions.forEach {
                $0.findSignerAccount(
                    in: sharedDataController.accountCollection,
                    on: session
                )
            }
        }
    }

    private func confirmSigning() {
        startLoading()

        guard let transaction = getFirstSignableTransaction(),
              let index = transactions.firstIndex(of: transaction),
              let signerAccount = transaction.requestedSigner.account else {
            rejectSigning(reason: .unauthorized(.transactionSignerNotFound))
            return
        }

        let requiresLedgerConnection: Bool

        if transaction.authAddress != nil {
            requiresLedgerConnection = signerAccount.hasLedgerDetail()
        } else {
            requiresLedgerConnection = signerAccount.requiresLedgerConnection()
        }

        if requiresLedgerConnection {
            openLedgerConnection()
        }

        transactionSignQueue.async {
            [weak self] in
            guard let self else { return }

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
            wcTransactionSigner.signTransaction(
                transaction,
                for: signerAccount
            )
        } else {
            signedTransactions.append(nil)
        }
    }

    func wcTransactionSigner(
        _ wcTransactionSigner: WCTransactionSigner,
        didSign transaction: WCTransaction,
        signedTransaction: Data
    ) {
        asyncMain {
            [weak self] in
            guard let self else { return }
            signWithLedgerProcessScreen?.increaseProgress()
        }

        signedTransactions.append(signedTransaction)

        transactionSignQueue.async {
            [weak self] in
            guard let self else { return }
            self.continueSigningTransactions(after: transaction)
        }
    }

    private func continueSigningTransactions(after transaction: WCTransaction) {
        if let index = transactions.firstIndex(of: transaction),
           let nextTransaction = transactions.nextElement(afterElementAt: index) {
            if let signerAccount = nextTransaction.requestedSigner.account {

                let requiresLedgerConnection: Bool

                if nextTransaction.authAddress != nil {
                    requiresLedgerConnection = signerAccount.hasLedgerDetail() 
                } else {
                    requiresLedgerConnection = signerAccount.requiresLedgerConnection() 
                }

                if requiresLedgerConnection {
                    openLedgerConnection()
                }

                wcTransactionSigner.signTransaction(
                    nextTransaction,
                    for: signerAccount
                )
            } else {
                signedTransactions.append(nil)
                continueSigningTransactions(after: nextTransaction)
            }
            return
        }

        dismissSignWithLedgerProcessScreen()

        if transactions.count != signedTransactions.count {
            rejectSigning(reason: .invalidInput(.unsignable))
            return
        }

        sendSignedTransactions()
    }

    private func sendSignedTransactions() {
        dataSource.signTransactionRequest(signature: signedTransactions)
        logAllTransactions()

        asyncMain {
            [weak self] in
            guard let self else { return }

            self.stopLoading()

            self.delegate?.wcMainTransactionScreen(
                self,
                didSigned: transactionRequest,
                in: wcSession
            )
        }
    }

    func wcTransactionSigner(
        _ wcTransactionSigner: WCTransactionSigner,
        didFailedWith error: WCTransactionSigner.WCSignError
    ) {
        asyncMain {
            [weak self] in
            guard let self else { return }

            stopLoading()

            switch error {
            case .api(let error):
                displaySigningError(error)

                rejectSigning(reason: .rejected(.unsignable))
            case .ledger(let error):
                displayLedgerError(error)
            case .missingUnparsedTransactionDetail:
                displayGenericError()
            }
        }
    }

    func wcTransactionSigner(
        _ wcTransactionSigner: WCTransactionSigner,
        didRequestUserApprovalFrom ledger: String
    ) {
        asyncMain {
            [weak self] in
            guard let self else { return }

            if signWithLedgerProcessScreen != nil { return }

            ledgerConnectionScreen?.dismiss(animated: true) {
                [weak self] in
                guard let self else { return }

                self.ledgerConnectionScreen = nil

                self.openSignWithLedgerProcess(ledgerDeviceName: ledger)
            }
        }
    }

    func wcTransactionSignerDidFinishTimingOperation(_ wcTransactionSigner: WCTransactionSigner) { }

    func wcTransactionSignerDidResetLedgerOperation(_ wcTransactionSigner: WCTransactionSigner) {
        dismissLedgerConnectionScreen()
        dismissSignWithLedgerProcessScreen()
    }

    func wcTransactionSignerDidResetLedgerOperationOnSuccess(_ wcTransactionSigner: WCTransactionSigner) { }

    func wcTransactionSignerDidRejectedLedgerOperation(_ wcTransactionSigner: WCTransactionSigner) { }

    private func disconnectFromTheLedgerIfNeeeded() {
        let isDisconnectNeeded =
            transactions
                .contains(
                    where: { transaction in
                        guard let signerAccount = transaction.requestedSigner.account else {
                            return false
                        }

                        if transaction.authAddress != nil {
                            return signerAccount.hasLedgerDetail()
                        }

                        return signerAccount.requiresLedgerConnection()
                    }
                )
        if isDisconnectNeeded {
            wcTransactionSigner.disonnectFromLedger()
        }
    }
}

extension WCMainTransactionScreen {
    private func logScreenWhenViewDidLoad() {
        analytics.record(
            .wcTransactionRequestDidLoad(transactionRequest: transactionRequest)
        )
        analytics.track(
            .wcTransactionRequestDidLoad(transactionRequest: transactionRequest)
        )
    }

    private func logScreenWhenViewDidAppear() {
        analytics.record(
            .wcTransactionRequestDidAppear(transactionRequest: transactionRequest)
        )
        analytics.track(
            .wcTransactionRequestDidAppear(transactionRequest: transactionRequest)
        )
    }

    private func logAllTransactions() {
        transactions.forEach { transaction in
            if let transactionData = transaction.unparsedTransactionDetail {
                let transactionID = AlgorandSDK().getTransactionID(for: transactionData)

                let dappName =
                    wcSession.wcV1Session?.peerMeta.name ??
                    wcSession.wcV2Session?.peer.name
                let dappURL =
                    wcSession.wcV1Session?.peerMeta.url.absoluteString ??
                    wcSession.wcV2Session?.peer.url
                let version: WalletConnectProtocolID = wcSession.isWCv1Session ? .v1 : .v2
                guard
                    let dappName,
                    let dappURL
                else {
                    return
                }

                analytics.track(
                    .wcTransactionConfirmed(
                        version: version,
                        transactionID: transactionID,
                        dappName: dappName,
                        dappURL: dappURL
                    )
                )
            }
        }
    }
}

extension WCMainTransactionScreen {
    private func displaySigningError(_ error: HIPTransactionError) {
        bannerController?.presentErrorBanner(
            title: "title-error".localized,
            message: error.debugDescription
        )
    }

    private func displayLedgerError(_ ledgerError: LedgerOperationError) {
        switch ledgerError {
        case .cancelled:
            bannerController?.presentErrorBanner(
                title: "ble-error-transaction-cancelled-title".localized,
                message: "ble-error-fail-sign-transaction".localized
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
        case .failedBLEConnectionError(let state):
            guard let errorTitle = state.errorDescription.title,
                  let errorSubtitle = state.errorDescription.subtitle else {
                return
            }

            bannerController?.presentErrorBanner(
                title: errorTitle,
                message: errorSubtitle
            )

            dismissLedgerConnectionScreen()
            dismissSignWithLedgerProcessScreen()
        case .ledgerConnectionWarning:
            ledgerConnectionScreen?.dismiss(animated: true) {
                [weak self] in
                guard let self else { return }

                self.bannerController?.presentErrorBanner(
                    title: "ble-error-connection-title".localized,
                    message: ""
                )

                self.openLedgerConnectionIssues()
            }
        case let .custom(title, message):
            bannerController?.presentErrorBanner(
                title: title,
                message: message
            )
        default:
            break
        }
    }

    private func displayGenericError() {
        bannerController?.presentErrorBanner(
            title: "title-error".localized,
            message: "title-generic-error".localized
        )
    }
}

extension WCMainTransactionScreen {
    private func openLedgerConnection() {
        if signWithLedgerProcessScreen != nil { return }

        if ledgerConnectionScreen != nil { return }

        let eventHandler: LedgerConnectionScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancel:
                self.wcTransactionSigner.disonnectFromLedger()

                self.dismissLedgerConnectionScreen()

                self.stopLoading()
            }
        }

        asyncMain {
            [weak self] in
            guard let self else { return }

            ledgerConnectionScreen = transitionToLedgerConnection.perform(
                .ledgerConnection(eventHandler: eventHandler),
                by: .presentWithoutNavigationController
            )
        }
    }
}

extension WCMainTransactionScreen {
    private func openLedgerConnectionIssues() {
        asyncMain {
            [weak self] in
            guard let self else { return }

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
}

extension WCMainTransactionScreen {
    private func openSignWithLedgerProcess(ledgerDeviceName: String) {
        let draft = SignWithLedgerProcessDraft(
            ledgerDeviceName: ledgerDeviceName,
            totalTransactionCount: dataSource.totalLedgerTransactionCountToSign
        )

        let eventHandler: SignWithLedgerProcessScreen.EventHandler = {
            [weak self] event in
            guard let self else { return }

            switch event {
            case .performCancelApproval:
                self.wcTransactionSigner.disonnectFromLedger()

                self.dismissSignWithLedgerProcessScreen()

                self.stopLoading()
            }
        }

        asyncMain {
            [weak self] in
            guard let self else { return }

            signWithLedgerProcessScreen = transitionToSignWithLedgerProcess.perform(
                .signWithLedgerProcess(
                    draft: draft,
                    eventHandler: eventHandler
                ),
                by: .present
            ) as? SignWithLedgerProcessScreen
        }
    }
}

extension WCMainTransactionScreen {
    private func dismissLedgerConnectionScreen() {
        asyncMain {
            [weak self] in
            guard let self else { return }

            ledgerConnectionScreen?.dismissScreen()
            ledgerConnectionScreen = nil
        }
    }

    private func dismissSignWithLedgerProcessScreen() {
        asyncMain {
            [weak self] in
            guard let self else { return }

            signWithLedgerProcessScreen?.dismissScreen()
            signWithLedgerProcessScreen = nil
        }
    }
}

extension WCMainTransactionScreen: WCSingleTransactionRequestScreenDelegate {
    func wcSingleTransactionRequestScreenDidReject(_ wcSingleTransactionRequestScreen: WCSingleTransactionRequestScreen) {
        rejectSigning()
    }

    func wcSingleTransactionRequestScreenDidConfirm(_ wcSingleTransactionRequestScreen: WCSingleTransactionRequestScreen) {
        confirmTransaction()
    }
}

extension WCMainTransactionScreen: WCUnsignedRequestScreenDelegate {
    func wcUnsignedRequestScreenDidReject(_ wcUnsignedRequestScreen: WCUnsignedRequestScreen) {
        rejectSigning()
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
            secondaryAction: {
                [weak self] in
                guard let self else { return  }
                self.rejectTransaction(with: reason)
            }
        )

        asyncMain {
            [weak self] in
            guard let self else { return }

            transitionToRejectionReason.perform(
                .bottomWarning(configurator: configurator),
                by: .presentWithoutNavigationController
            )
        }
    }

    private func rejectTransaction(with reason: WCTransactionErrorResponse) {
        asyncMain {
            [weak self] in
            guard let self else { return }

            dataSource.rejectTransaction(reason: reason)

            stopLoading()

            delegate?.wcMainTransactionScreen(self, didRejected: transactionRequest)
        }
    }
}

extension WCMainTransactionScreen: WCTransactionValidator {
    func rejectTransactionRequest(with error: WCTransactionErrorResponse) {
        rejectSigning(reason: error)
    }
}

extension WCMainTransactionScreen: WCTransactionDappMessageViewDelegate {
    func wcTransactionDappMessageViewDidTapped(
        _ WCTransactionDappMessageView: WCTransactionDappMessageView
    ) {
        let configurator = WCTransactionFullDappDetailConfigurator(
            from: wcSession,
            option: transactionOption,
            transaction: transactions.first
        )
        transitionToFullDappDetail.perform(
            .wcTransactionFullDappDetail(configurator: configurator),
            by: .presentWithoutNavigationController
        )
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

        asyncMain {
            [weak self] in
            guard let self else { return }

            transitionToFailedGroupingTransactions.perform(
                .bottomWarning(configurator: configurator),
                by: .presentWithoutNavigationController
            )
        }
    }
}

extension WCMainTransactionScreen {
    private func getTransactionParams() {
        sharedDataController.getTransactionParams {
            [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let params):
                self.transactionParams = params
            case .failure:
                break
            }

            asyncBackground(qos: .userInitiated) {
                [weak self] in
                guard let self else { return }

                self.rejectIfTheNetworkIsInvalid()

                self.initialDataLoadingDispatchGroup.leave()
            }
        }
    }

    private func rejectIfTheNetworkIsInvalid() {
        if !hasValidNetwork(for: transactions) {
            rejectSigning(reason: .unauthorized(.nodeMismatch))
            return
        }
    }

    private func hasValidNetwork(for transactions: [WCTransaction]) -> Bool {
        guard let transactionParams else {
            return false
        }

        return transactions.contains { $0.isInTheSameNetwork(with: transactionParams) }
    }
}

extension WCMainTransactionScreen {
    private func getAssetDetailsIfNeeded() {
        asyncBackground(qos: .userInitiated) {
            [weak self] in
            guard let self else { return }

            var validAssetTransactionAssetIDsToFetch = Set<AssetID>()
            for transaction in transactions where !isRejected {
                guard let transactionDetail = transaction.transactionDetail else {
                    continue
                }

                let isValidAssetTransaction = isValidAssetTransaction(transactionDetail)
                if isValidAssetTransaction {
                    guard let assetID = transactionDetail.currentAssetId else {
                        rejectSigning(reason: .invalidInput(.asset))
                        return
                    }

                    let cachedAssetDetail = self.sharedDataController.assetDetailCollection[assetID]
                    if cachedAssetDetail == nil {
                        validAssetTransactionAssetIDsToFetch.insert(assetID)
                    }
                }
            }

            let isNotEmpty = validAssetTransactionAssetIDsToFetch.first != nil
            guard isNotEmpty else {
                publishAssetDetailFetchedNotification()

                initialDataLoadingDispatchGroup.leave()
                return
            }

            fetchAssetDetails(withIDs: Array(validAssetTransactionAssetIDsToFetch)) {
                [weak self] isSuccess in
                guard let self else { return }

                if isSuccess {
                    publishAssetDetailFetchedNotification()
                } else {
                    rejectSigning(reason: .invalidInput(.unableToFetchAsset))
                }

                initialDataLoadingDispatchGroup.leave()
            }
        }
    }

    private func isValidAssetTransaction(_ transactionDetail: WCTransactionDetail) -> Bool {
        let isAssetCreation = transactionDetail.isAssetCreationTransaction
        let isAssetTransfer = transactionDetail.isAssetTransaction
        let isAssetConfig = transactionDetail.isAssetConfigTransaction
        return !isAssetCreation && (isAssetTransfer || isAssetConfig)
    }

    private func publishAssetDetailFetchedNotification() {
        asyncMain {
            NotificationCenter.default.post(
                name: .AssetDetailFetched,
                object: nil
            )
        }
    }
}

extension WCMainTransactionScreen {
    private func startLoading() {
        asyncMain {
            [weak self] in
            guard let self else { return }
            loadingController?.startLoadingWithMessage("title-loading".localized)
        }
    }

    private func stopLoading() {
        asyncMain {
            [weak self] in
            guard let self else { return }
            loadingController?.stopLoading()
        }
    }
}

extension WCMainTransactionScreen {
    private func fetchAssetDetails(
        withIDs ids: [AssetID],
        onComplete handler: @escaping (Bool) -> Void
    ) {
        if isRejected { return }

        let chunkSize = 100
        let chunkedAssetIDs = ids.chunked(by: chunkSize)
        fetchChunkedAssetDetails(
            chunkedAssetIDs: chunkedAssetIDs,
            onComplete: handler
        )
    }

    private func fetchChunkedAssetDetails(
        chunkedAssetIDs: [[AssetID]],
        onComplete handler: @escaping (Bool) -> Void
    ) {
        if isRejected { return }

        let group = DispatchGroup()
        var isAnyAssetDetailFetchFailed = false

        for subAssetIDs in chunkedAssetIDs where !isAnyAssetDetailFetchFailed && !isRejected {
            group.enter()

            fetchAssetDetails(withIDs: subAssetIDs) {
                [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let subAssetDetails):
                    isAnyAssetDetailFetchFailed = subAssetDetails.isEmpty

                    subAssetDetails.forEach {
                        self.sharedDataController.assetDetailCollection[$0.id] = $0
                    }

                    group.leave()
                case .failure:
                    for id in subAssetIDs where !isAnyAssetDetailFetchFailed && !isRejected {
                        group.enter()

                        self.fetchAssetDetailFromNode(id: id) { isSuccess in
                            isAnyAssetDetailFetchFailed = !isSuccess
                            group.leave()
                        }
                    }
                }
            }
        }

        group.notify(queue: .main) {
            handler(!isAnyAssetDetailFetchFailed)
        }
    }

    private func fetchAssetDetails(
        withIDs ids: [AssetID],
        onComplete handler: @escaping (Result<[AssetDecoration], Error>) -> Void
    ) {
        if isRejected { return }

        let draft = AssetFetchQuery(ids: ids, includeDeleted: true)
        let queue = DispatchQueue.global(qos: .userInitiated)
        api!.fetchAssetDetails(
            draft,
            queue: queue,
            ignoreResponseOnCancelled: true
        ) {
            result in
            switch result {
            case .success(let assetList):
                handler(.success(assetList.results))
            case .failure(let apiError, let apiErrorDetail):
                let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                handler(.failure(error))
            }
        }
    }

    private func fetchAssetDetailFromNode(
        id: AssetID,
        onComplete handler: @escaping (Bool) -> Void
    ) {
        if isRejected { return }

        let draft = AssetDetailFetchDraft(id: id)
        api!.fetchAssetDetailFromNode(draft) {
            [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let assetDecoration):
                self.sharedDataController.assetDetailCollection[id] = assetDecoration
                handler(true)
            case .failure:
                handler(false)
            }
        }
    }
}

protocol WCMainTransactionScreenDelegate: AnyObject {
    func wcMainTransactionScreen(
        _ wcMainTransactionScreen: WCMainTransactionScreen,
        didSigned request: WalletConnectRequestDraft,
        in session: WCSessionDraft
    )
    func wcMainTransactionScreen(
        _ wcMainTransactionScreen: WCMainTransactionScreen,
        didRejected request: WalletConnectRequestDraft
    )
}
