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
//  RekeyConfirmationViewController.swift

import UIKit
import Magpie

class RekeyConfirmationViewController: BaseScrollViewController {
    
    private lazy var rekeyConfirmationView = RekeyConfirmationView()

    private var account: Account
    private let ledger: LedgerDetail?
    private let ledgerAddress: String
    private var rekeyConfirmationDataSource: RekeyConfirmationDataSource
    private var rekeyConfirmationListLayout: RekeyConfirmationListLayout
    private let viewModel: RekeyConfirmationViewModel
    
    private lazy var cardModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 354.0))
    )
    
    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(api: api)
    }()
    
    init(account: Account, ledger: LedgerDetail?, ledgerAddress: String, configuration: ViewControllerConfiguration) {
        self.account = account
        self.ledger = ledger
        self.ledgerAddress = ledgerAddress
        self.viewModel = RekeyConfirmationViewModel(account: account, ledgerName: ledger?.name)
        rekeyConfirmationDataSource = RekeyConfirmationDataSource(account: account, rekeyConfirmationViewModel: viewModel)
        rekeyConfirmationListLayout = RekeyConfirmationListLayout(account: account)
        super.init(configuration: configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if rekeyConfirmationDataSource.allAssetsDisplayed {
            setFooterHidden()
        } else {
            rekeyConfirmationView.reloadData()
        }
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "ledger-rekey-confirm-title".localized
        viewModel.configure(rekeyConfirmationView)
    }
    
    override func linkInteractors() {
        rekeyConfirmationView.delegate = self
        rekeyConfirmationDataSource.delegate = self
        transactionController.delegate = self
        rekeyConfirmationView.setDataSource(rekeyConfirmationDataSource)
        rekeyConfirmationView.setListDelegate(rekeyConfirmationListLayout)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupRekeyConfirmationViewLayout()
    }
}

extension RekeyConfirmationViewController {
    private func setupRekeyConfirmationViewLayout() {
        contentView.addSubview(rekeyConfirmationView)
        
        rekeyConfirmationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension RekeyConfirmationViewController: RekeyConfirmationDataSourceDelegate {
    func rekeyConfirmationDataSourceDidShowMoreAssets(_ rekeyConfirmationDataSource: RekeyConfirmationDataSource) {
        setFooterHidden()
    }
    
    private func setFooterHidden() {
        rekeyConfirmationListLayout.setFooterHidden(true)
        rekeyConfirmationView.reloadData()
    }
}

extension RekeyConfirmationViewController: RekeyConfirmationViewDelegate {
    func rekeyConfirmationViewDidFinalizeConfirmation(_ rekeyConfirmationView: RekeyConfirmationView) {
        guard let session = session,
            session.canSignTransaction(for: &account) else {
            return
        }
        
        let rekeyTransactionDraft = RekeyTransactionSendDraft(account: account, rekeyedTo: ledgerAddress)
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
        log(RekeyEvent())
        saveRekeyedAccountDetails()
        openRekeyConfirmationAlert()
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPError<TransactionError>) {
        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            NotificationBanner.showError("title-error".localized, message: error.asAFError?.errorDescription ?? error.localizedDescription)
        }
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPError<TransactionError>) {
        switch error {
        case let .network(apiError):
            NotificationBanner.showError("title-error".localized, message: apiError.debugDescription)
        default:
            NotificationBanner.showError("title-error".localized, message: error.localizedDescription)
        }
    }
}

extension RekeyConfirmationViewController {
    private func saveRekeyedAccountDetails() {
        if let localAccount = session?.accountInformation(from: account.address),
           let ledgerDetail = ledger {
            localAccount.type = .rekeyed
            account.type = .rekeyed
            localAccount.addRekeyDetail(ledgerDetail, for: ledgerAddress)

            session?.authenticatedUser?.updateAccount(localAccount)
            session?.updateAccount(account)
        }
    }

    private func openRekeyConfirmationAlert() {
        let accountName = account.name ?? ""
        let configurator = BottomInformationBundle(
            title: "ledger-rekey-success-title".localized,
            image: img("img-green-checkmark"),
            explanation: "ledger-rekey-success-message".localized(params: accountName),
            actionTitle: "title-go-home".localized,
            actionImage: img("bg-main-button")) {
                self.dismissScreen()
        }
        
        open(
            .bottomInformation(mode: .confirmation, configurator: configurator),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: cardModalPresenter
            )
        )
    }
    
    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            NotificationBanner.showError(
                "asset-min-transaction-error-title".localized,
                message: "send-algos-minimum-amount-custom-error".localized(params: amount.toAlgos.toAlgosStringForLabel ?? "")
            )
        case .invalidAddress:
            NotificationBanner.showError("title-error".localized, message: "send-algos-receiver-address-validation".localized)
        case let .sdkError(error):
            NotificationBanner.showError("title-error".localized, message: error.debugDescription)
        default:
            break
        }
    }
}
