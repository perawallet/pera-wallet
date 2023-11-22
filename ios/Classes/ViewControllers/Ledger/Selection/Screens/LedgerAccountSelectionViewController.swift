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
//  LedgerAccountSelectionViewController.swift

import Foundation
import UIKit

final class LedgerAccountSelectionViewController: BaseViewController {
    private lazy var ledgerAccountSelectionView = LedgerAccountSelectionView(isMultiSelect: isMultiSelect)
    private lazy var theme = Theme()

    private var accounts: [Account]
    private let accountSetupFlow: AccountSetupFlow

    private var selectedAccountCount: Int {
        return ledgerAccountSelectionView.selectedIndexes.count
    }
    
    private var isMultiSelect: Bool {
        switch accountSetupFlow {
        case .initializeAccount:
            return true
        case let .addNewAccount(mode):
            switch mode {
            case .rekey:
                return false
            default:
                return true
            }
        case .backUpAccount,
             .none:
            return false
        }
    }

    private lazy var dataSource = LedgerAccountSelectionDataSource(
        api: api!,
        analytics: analytics,
        sharedDataController: sharedDataController,
        accounts: accounts,
        rekeyingAccount: accountSetupFlow.rekeyingAccount,
        isMultiSelect: isMultiSelect
    )
    
    private lazy var listLayout = LedgerAccountSelectionListLayout(theme: theme, dataSource: dataSource)
    
    init(accountSetupFlow: AccountSetupFlow, accounts: [Account], configuration: ViewControllerConfiguration) {
        self.accountSetupFlow = accountSetupFlow
        self.accounts = accounts
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingController?.startLoadingWithMessage("title-loading".localized)
        ledgerAccountSelectionView.setLoadingState()
        dataSource.loadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loadingController?.stopLoading()
    }
    
    override func configureAppearance() {
        super.configureAppearance()

        title = accounts.first?.ledgerDetail?.name

        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    override func linkInteractors() {
        ledgerAccountSelectionView.delegate = self
        ledgerAccountSelectionView.setDataSource(dataSource)
        ledgerAccountSelectionView.setListDelegate(listLayout)
        dataSource.delegate = self
        listLayout.delegate = self
    }

    override func bindData() {
        bindLedgerAccountSelectionView()
    }
    
    override func prepareLayout() {
        view.addSubview(ledgerAccountSelectionView)
        ledgerAccountSelectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension LedgerAccountSelectionViewController: LedgerAccountSelectionDataSourceDelegate {
    func ledgerAccountSelectionDataSource(
        _ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource,
        didFetch accounts: [Account]
    ) {
        self.accounts = accounts

        loadingController?.stopLoading()
        ledgerAccountSelectionView.setNormalState()
        ledgerAccountSelectionView.reloadData()

        bindLedgerAccountSelectionView()
    }
    
    func ledgerAccountSelectionDataSourceDidFailToFetch(_ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource) {
        loadingController?.stopLoading()
        ledgerAccountSelectionView.setErrorState()
        ledgerAccountSelectionView.reloadData()
    }
    
    func ledgerAccountSelectionDataSource(
        _ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource,
        didTapMoreInfoFor cell: LedgerAccountCell
    ) {
        guard let indexPath = ledgerAccountSelectionView.indexPath(for: cell),
              let account = dataSource.account(at: indexPath.item) else {
            return
        }

        let authAccount: Account?

        if account.authorization.isRekeyed {
            authAccount = dataSource.getAuthAccount(of: account)
        } else {
            authAccount = account
        }

        guard let authAccount else {
            return
        }
        
        open(
            .ledgerAccountDetail(
                account: account,
                authAccount: authAccount,
                ledgerIndex: dataSource.ledgerAccountIndex(for: account.address),
                rekeyedAccounts: dataSource.rekeyedAccounts(for: account.address)
            ),
            by: .present
        )
    }
}

extension LedgerAccountSelectionViewController: LedgerAccountSelectionViewDelegate {
    func ledgerAccountSelectionViewDidTryAgain(_ ledgerAccountSelectionView: LedgerAccountSelectionView) {
        loadingController?.startLoadingWithMessage("title-loading".localized)
        ledgerAccountSelectionView.setLoadingState()
        dataSource.loadData()
    }

    func ledgerAccountSelectionViewDidAddAccount(_ ledgerAccountSelectionView: LedgerAccountSelectionView) {
        switch accountSetupFlow {
        case let .addNewAccount(mode):
            switch mode {
            case let .rekey(rekeyedAccount):
                openRekeyConfirmationScreen(for: rekeyedAccount)
            default:
                openAccountVerification()
            }
        case .initializeAccount:
            openAccountVerification()
        case .backUpAccount,
             .none:
            break
        }
    }

    private func openRekeyConfirmationScreen(for rekeyedAccount: Account) {
        guard let selectedIndex = ledgerAccountSelectionView.selectedIndexes.first,
              let account = dataSource.account(at: selectedIndex.item),
              !isMultiSelect else {
            return
        }

        let authAccount = sharedDataController.authAccount(of: rekeyedAccount)
        let screen = open(
            .rekeyConfirmation(
                sourceAccount: rekeyedAccount,
                authAccount: authAccount?.value,
                newAuthAccount: account
            ),
            by: .push
        ) as? RekeyConfirmationScreen
        screen?.eventHandler = {
            [weak self, weak screen] event in
            guard let self,
                  let screen else {
                return
            }

            switch event {
            case .didRekey:
                self.openRekeySuccessScreen(
                    sourceAccount: rekeyedAccount,
                    screen: screen
                )
            }
        }
    }

    private func openRekeySuccessScreen(
        sourceAccount: Account,
        screen: UIViewController
    ) {
        let eventHandler: RekeySuccessScreen.EventHandler = {
            [weak self] event in
            guard let self else { return }
            switch event {
            case .performPrimaryAction:
                self.dismissScreen()
            case .performCloseAction:
                self.dismissScreen()
            }
        }
        let rekeySuccessScreen = screen.open(
            .rekeySuccess(
                sourceAccount: sourceAccount,
                eventHandler: eventHandler
            ),
            by: .push
        ) as? RekeySuccessScreen
        rekeySuccessScreen?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    private func openAccountVerification() {
        let selectedAccounts = dataSource.getSelectedAccounts(ledgerAccountSelectionView.selectedIndexes)
        open(.ledgerAccountVerification(flow: accountSetupFlow, selectedAccounts: selectedAccounts), by: .push)
    }
}

extension LedgerAccountSelectionViewController: LedgerAccountSelectionListLayoutDelegate {
    func ledgerAccountSelectionListLayout(
        _ ledgerAccountSelectionListLayout: LedgerAccountSelectionListLayout,
        didSelectItemAt indexPath: IndexPath
    ) {
        bindLedgerAccountSelectionView()
    }
    
    func ledgerAccountSelectionListLayout(
        _ ledgerAccountSelectionListLayout: LedgerAccountSelectionListLayout,
        didDeselectItemAt indexPath: IndexPath
    ) {
        bindLedgerAccountSelectionView()
    }
}

extension LedgerAccountSelectionViewController {
    private func bindLedgerAccountSelectionView() {
        let viewModel = LedgerAccountSelectionViewModel(
            accounts: accounts,
            isMultiSelect: isMultiSelect,
            selectedCount: selectedAccountCount
        )
        ledgerAccountSelectionView.bindData(viewModel)
    }
}
