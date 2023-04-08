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
//  RekeyConfirmationViewController.swift

import UIKit
import MagpieHipo
import MacaroonUtils

final class RekeyConfirmationViewController: BaseViewController {
    private lazy var rekeyConfirmationView = RekeyConfirmationView()

    private var account: Account
    private let ledger: LedgerDetail?
    private let newAuthAddress: String

    private lazy var transitionToLedgerConnection = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToLedgerConnectionIssuesWarning = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToSignWithLedgerProcess = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )

    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?

    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(
            api: api,
            sharedDataController: sharedDataController,
            bannerController: bannerController,
            analytics: analytics
        )
    }()

    private lazy var currencyFormatter = CurrencyFormatter()
    
    init(
        account: Account,
        ledger: LedgerDetail?,
        newAuthAddress: String,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        self.ledger = ledger
        self.newAuthAddress = newAuthAddress
        super.init(configuration: configuration)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rekeyConfirmationView.startAnimatingImageView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        rekeyConfirmationView.stopAnimatingImageView()
    }
    
    override func linkInteractors() {
        rekeyConfirmationView.delegate = self
        transactionController.delegate = self
    }

    override func setListeners() {
        rekeyConfirmationView.setListeners()
    }

    override func bindData() {
        let viewModel = RekeyConfirmationViewModel(
            account: account,
            ledgerName: ledger?.name,
            newAuthAddress: newAuthAddress
        )
        rekeyConfirmationView.bindData(viewModel)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        rekeyConfirmationView.customize(RekeyConfirmationViewTheme())
        view.addSubview(rekeyConfirmationView)
        rekeyConfirmationView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension RekeyConfirmationViewController: RekeyConfirmationViewDelegate {
    func rekeyConfirmationViewDidFinalizeConfirmation(_ rekeyConfirmationView: RekeyConfirmationView) {
        if !transactionController.canSignTransaction(for: account) { return }

        loadingController?.startLoadingWithMessage("title-loading".localized)

        let rekeyTransactionDraft = RekeyTransactionSendDraft(
            account: account,
            rekeyedTo: newAuthAddress
        )

        transactionController.setTransactionDraft(rekeyTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .rekey)
        
        if account.requiresLedgerConnection() {
            openLedgerConnection()
            
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }
}

extension RekeyConfirmationViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didComposedTransactionDataFor draft: TransactionSendDraft?) {
        loadingController?.stopLoading()

        analytics.track(.rekeyAccount())
        saveRekeyedAccountDetails()
        openRekeyConfirmationAlert()
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPTransactionError) {
        loadingController?.stopLoading()

        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.asAFError?.errorDescription ?? error.localizedDescription
            )
        }
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPTransactionError) {
        loadingController?.stopLoading()

        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(title: "title-error".localized, message: apiError.debugDescription)
        default:
            bannerController?.presentErrorBanner(title: "title-error".localized, message: error.debugDescription)
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

    func transactionControllerDidResetLedgerOperation(_ transactionController: TransactionController) {
        ledgerConnectionScreen?.dismissScreen()
        ledgerConnectionScreen = nil

        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil

        loadingController?.stopLoading()
    }
}

extension RekeyConfirmationViewController {
    private func saveRekeyedAccountDetails() {
        guard let localAccount = session?.accountInformation(from: account.address),
              let ledgerDetail = ledger else {
            return
        }
        
        let accountType = getNewAccountTypeAfterRekeying()
        localAccount.type = accountType
        account.type = accountType
        
        if accountType.isRekeyed {
            localAccount.addRekeyDetail(
                ledgerDetail,
                for: newAuthAddress
            )
        }

        saveAccount(localAccount)
    }
    
    private func getNewAccountTypeAfterRekeying() -> AccountInformation.AccountType {
        return account.isSameAccount(with: newAuthAddress) ? .ledger : .rekeyed
    }
    
    private func saveAccount(_ localAccount: AccountInformation) {
        session?.authenticatedUser?.updateAccount(localAccount)
    }

    private func openRekeyConfirmationAlert() {
        let controller = open(
            .tutorial(flow: .none, tutorial: .accountSuccessfullyRekeyed(accountName: account.name.ifNil(.empty))),
            by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
        ) as? TutorialViewController
        controller?.uiHandlers.didTapButtonPrimaryActionButton = { _ in
            self.dismissScreen()
        }
    }
    
    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let amountText = currencyFormatter.format(amount.toAlgos)

            bannerController?.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "send-algos-minimum-amount-custom-error".localized(
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
                title: "title-error".localized, message: error.debugDescription
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
}

extension RekeyConfirmationViewController {
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

                self.loadingController?.stopLoading()
            }
        }

        ledgerConnectionScreen = transitionToLedgerConnection.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }
}

extension RekeyConfirmationViewController {
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

extension RekeyConfirmationViewController {
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
