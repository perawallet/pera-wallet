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
//   LedgerAccountVerificationViewController.swift

import UIKit
import SVProgressHUD

class LedgerAccountVerificationViewController: BaseScrollViewController {

    private let layout = Layout<LayoutConstants>()

    private lazy var ledgerAccountVerificationView = LedgerAccountVerificationView()

    private lazy var addButton = MainButton(title: "ledger-verified-add".localized)

    private lazy var ledgerAccountVerificationOperation = LedgerAccountVerifyOperation()
    private lazy var dataController = LedgerAccountVerificationDataController(accounts: selectedAccounts)

    private var currentVerificationStatusView: LedgerAccountVerificationStatusView?
    private var currentVerificationAccount: Account?
    private var isVerificationCompleted = false {
        didSet {
            setAddButtonHidden(!isVerificationCompleted)
        }
    }

    private lazy var accountManager: AccountManager?  = {
        guard let api = api else {
            return nil
        }
        return AccountManager(api: api)
    }()

    private let accountSetupFlow: AccountSetupFlow
    private let selectedAccounts: [Account]

    init(
        accountSetupFlow: AccountSetupFlow,
        selectedAccounts: [Account],
        configuration: ViewControllerConfiguration
    ) {
        self.accountSetupFlow = accountSetupFlow
        self.selectedAccounts = selectedAccounts
        super.init(configuration: configuration)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ledgerAccountVerificationView.startConnectionAnimation()
        startVerification()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ledgerAccountVerificationOperation.reset()
        ledgerAccountVerificationView.stopConnectionAnimation()
    }

    override func configureAppearance() {
        super.configureAppearance()
        addVerificationAccountsToStack()
        setAddButtonHidden(true)
    }

    override func setListeners() {
        super.setListeners()
        addButton.addTarget(self, action: #selector(addVerifiedAccounts), for: .touchUpInside)
    }

    override func prepareLayout() {
        super.prepareLayout()
        setupLedgerAccountVerificationViewLayout()
        setupAddButtonLayout()
    }
}

extension LedgerAccountVerificationViewController {
    private func setupLedgerAccountVerificationViewLayout() {
        contentView.addSubview(ledgerAccountVerificationView)
        ledgerAccountVerificationView.pinToSuperview()
    }

    private func setupAddButtonLayout() {
        view.addSubview(addButton)

        addButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(view.safeAreaBottom + layout.current.bottomInset)
        }
    }
}

extension LedgerAccountVerificationViewController {
    private func addVerificationAccountsToStack() {
        dataController.displayedVerificationAccounts.forEach { account in
            let statusView = LedgerAccountVerificationStatusView()
            let viewModel = LedgerAccountVerificationStatusViewModel(
                account: account,
                status: ledgerAccountVerificationView.isStackViewEmpty ? .awaiting : .pending
            )
            statusView.bind(viewModel)

            if ledgerAccountVerificationView.isStackViewEmpty {
                currentVerificationStatusView = statusView
            }

            ledgerAccountVerificationView.addArrangedSubview(statusView)
        }
    }

    private func startVerification() {
        guard let account = dataController.displayedVerificationAccounts.first else {
            return
        }

        currentVerificationAccount = account
        setVerificationLedgerDetail(for: account)
        ledgerAccountVerificationOperation.delegate = self
    }

    private func setAddButtonHidden(_ isHidden: Bool) {
        addButton.isHidden = isHidden
    }
}

extension LedgerAccountVerificationViewController {
    @objc
    private func addVerifiedAccounts() {
        saveVerifiedAccounts()
        launchHome()
    }

    private func saveVerifiedAccounts() {
        dataController.getVerifiedAccounts().forEach { account in
            if let localAccount = api?.session.accountInformation(from: account.address) {
                updateLocalAccount(localAccount, with: account)
            } else {
                setupLocalAccount(from: account)
            }
        }
    }

    private func updateLocalAccount(_ localAccount: AccountInformation, with account: Account) {
        var localAccount = localAccount
        localAccount.type = account.type
        setupLedgerDetails(of: &localAccount, from: account)

        api?.session.authenticatedUser?.updateAccount(localAccount)
        api?.session.updateAccount(account)
    }

    private func setupLocalAccount(from account: Account) {
        var localAccount = AccountInformation(address: account.address, name: account.address.shortAddressDisplay(), type: account.type)
        setupLedgerDetails(of: &localAccount, from: account)

        let user: User

        if let authenticatedUser = api?.session.authenticatedUser {
            user = authenticatedUser
            user.addAccount(localAccount)
        } else {
            user = User(accounts: [localAccount])
        }

        api?.session.addAccount(Account(accountInformation: localAccount))
        api?.session.authenticatedUser = user
    }

    private func setupLedgerDetails(of localAccount: inout AccountInformation, from account: Account) {
        if let authAddress = account.authAddress,
           let rekeyDetail = account.rekeyDetail {
            UIApplication.shared.firebaseAnalytics?.log(RegistrationEvent(type: .rekeyed))
            localAccount.addRekeyDetail(rekeyDetail, for: authAddress)
        } else {
            UIApplication.shared.firebaseAnalytics?.log(RegistrationEvent(type: .ledger))
            localAccount.ledgerDetail = account.ledgerDetail
        }
    }

    private func launchHome() {
        guard let accountManager = accountManager else {
            return
        }
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        accountManager.fetchAllAccounts(isVerifiedAssetsIncluded: true) {
            SVProgressHUD.showSuccess(withStatus: "title-done".localized)
            SVProgressHUD.dismiss(withDelay: 1.0) {
                switch self.accountSetupFlow {
                case .initializeAccount:
                    DispatchQueue.main.async {
                        self.dismiss(animated: false) {
                            UIApplication.shared.rootViewController()?.setupTabBarController()
                        }
                    }
                case .addNewAccount:
                    self.closeScreen(by: .dismiss, animated: false)
                case .none:
                    break
                }
            }
        }
    }
}

extension LedgerAccountVerificationViewController: LedgerAccountVerifyOperationDelegate {
    func ledgerAccountVerifyOperation(_ ledgerAccountVerifyOperation: LedgerAccountVerifyOperation, didVerify account: String) {
        updateCurrentVerificationStatusView(with: .verified)
        dataController.addVerifiedAccount(currentVerificationAccount?.address)

        if dataController.isLastAccount(currentVerificationAccount) {
            isVerificationCompleted = true
            return
        }

        updatCurrentVerificationStates()
        verifyNextAccountIfExist()
    }

    func ledgerAccountVerifyOperation(_ ledgerAccountVerifyOperation: LedgerAccountVerifyOperation, didFailed error: LedgerOperationError) {
        if error != .cancelled {
            NotificationBanner.showError(
                "ble-error-ledger-connection-title".localized,
                message: "ble-error-ledger-connection-open-app-error".localized
            )
            return
        }
        
        updateCurrentVerificationStatusView(with: .unverified)

        if dataController.isLastAccount(currentVerificationAccount) {
            isVerificationCompleted = true
            return
        }

        updatCurrentVerificationStates()
        verifyNextAccountIfExist()
    }

    private func updateCurrentVerificationStatusView(with status: LedgerVerificationStatus) {
        if let account = currentVerificationAccount {
            currentVerificationStatusView?.bind(LedgerAccountVerificationStatusViewModel(account: account, status: status))
        }
    }

    private func updatCurrentVerificationStates() {
        guard let currentVerificationAccount = currentVerificationAccount,
              let currentVerificationStatusView = currentVerificationStatusView,
              let nextVerificationIndex = dataController.nextIndexForVerification(from: currentVerificationAccount.address),
              let nextVerificationAccount = dataController.displayedVerificationAccounts[safe: nextVerificationIndex],
              let nextVerificationStatusView = ledgerAccountVerificationView.statusViews.nextView(
                of: currentVerificationStatusView
              ) as? LedgerAccountVerificationStatusView else {
            return
        }

        self.currentVerificationAccount = nextVerificationAccount
        self.currentVerificationStatusView = nextVerificationStatusView
    }

    private func verifyNextAccountIfExist() {
        guard let currentVerificationAccount = currentVerificationAccount,
              let currentVerificationStatusView = currentVerificationStatusView else {
            return
        }

        currentVerificationStatusView.bind(LedgerAccountVerificationStatusViewModel(account: currentVerificationAccount, status: .awaiting))
        setVerificationLedgerDetail(for: currentVerificationAccount)
        ledgerAccountVerificationOperation.startOperation()
    }

    private func setVerificationLedgerDetail(for account: Account) {
        if let authAddress = account.authAddress {
            if let rekeyedLedgerDetail = account.rekeyDetail?[authAddress] {
                // If the auth account of rekeyed account is not one of the selected accounts, use the ledger index of the account
                if let ledgerDetail = account.ledgerDetail,
                   rekeyedLedgerDetail.id != ledgerDetail.id {
                    ledgerAccountVerificationOperation.setLedgerDetail(account.ledgerDetail)
                    return
                }
            } else {
                ledgerAccountVerificationOperation.setLedgerDetail(account.ledgerDetail)
                return
            }
        }

        ledgerAccountVerificationOperation.setLedgerDetail(account.currentLedgerDetail)
    }
}

extension LedgerAccountVerificationViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 16.0
    }
}

enum LedgerVerificationStatus {
    case awaiting
    case pending
    case verified
    case unverified
}
