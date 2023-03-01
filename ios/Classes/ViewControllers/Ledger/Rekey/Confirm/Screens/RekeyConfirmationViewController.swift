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

    private var ledgerApprovalViewController: LedgerApprovalViewController?
    
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

extension RekeyConfirmationViewController:
    RekeyConfirmationViewDelegate,
    TransactionSignChecking {
    func rekeyConfirmationViewDidFinalizeConfirmation(_ rekeyConfirmationView: RekeyConfirmationView) {
        if !canSignTransaction(for: &account) {
            return
        }
        
        let rekeyTransactionDraft = RekeyTransactionSendDraft(
            account: account,
            rekeyedTo: newAuthAddress
        )
        transactionController.setTransactionDraft(rekeyTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .rekey)
        
        if account.requiresLedgerConnection() {
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
        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(title: "title-error".localized, message: apiError.debugDescription)
        default:
            bannerController?.presentErrorBanner(title: "title-error".localized, message: error.debugDescription)
        }
    }

    func transactionController(_ transactionController: TransactionController, didRequestUserApprovalFrom ledger: String) {
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

    func transactionControllerDidResetLedgerOperation(_ transactionController: TransactionController) {
        ledgerApprovalViewController?.dismissScreen()
    }
}

extension RekeyConfirmationViewController {
    private func saveRekeyedAccountDetails() {
        if let localAccount = session?.accountInformation(from: account.address),
           let ledgerDetail = ledger {
            localAccount.type = .rekeyed
            account.type = .rekeyed
            localAccount.addRekeyDetail(
                ledgerDetail,
                for: newAuthAddress
            )

            session?.authenticatedUser?.updateAccount(localAccount)
        }
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
            let bottomTransition = BottomSheetTransition(presentingViewController: self)

            bottomTransition.perform(
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
        default:
            break
        }
    }
}

protocol TransactionSignChecking {
    func canSignTransaction(for selectedAccount: inout Account) -> Bool
}

extension TransactionSignChecking where Self: BaseViewController {
    func canSignTransaction(for selectedAccount: inout Account) -> Bool {
        /// Check whether account is a watch account
        if selectedAccount.isWatchAccount() {
           return false
        }

        let accounts = sharedDataController.sortedAccounts().map { $0.value }

        /// Check whether auth address exists for the selected account.
        if let authAddress = selectedAccount.authAddress {
            if selectedAccount.rekeyDetail?[authAddress] != nil {
                return true
            } else {
                guard let authAccount = accounts.first(where: { account -> Bool in
                    authAddress == account.address
                }) else {
                    bannerController?.presentErrorBanner(
                        title: "title-error".localized,
                        message: "ledger-rekey-error-not-found".localized
                    )
                    
                    return false
                }

                if let ledgerDetail = authAccount.ledgerDetail {
                    selectedAccount.addRekeyDetail(
                        ledgerDetail,
                        for: authAddress
                    )
                }
                
                return true
            }
        }

        /// Check whether ledger details of the selected ledger account exists.
        if selectedAccount.isLedger() {
            if selectedAccount.ledgerDetail == nil {
                AppDelegate.shared?.appConfiguration.bannerController.presentErrorBanner(
                    title: "title-error".localized,
                    message: "ledger-rekey-error-not-found".localized
                )
                return false
            }
            return true
        }

        /// Check whether private key of the selected account exists.
        if session?.privateData(for: selectedAccount.address) == nil {
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "ledger-rekey-error-not-found".localized
            )
            return false
        }

        return true
    }
}
