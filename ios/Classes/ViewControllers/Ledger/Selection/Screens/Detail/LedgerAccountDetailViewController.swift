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
//  LedgerAccountDetailViewController.swift

import UIKit

final class LedgerAccountDetailViewController: BaseScrollViewController {
    private lazy var theme = Theme()
    private lazy var ledgerAccountDetailView = LedgerAccountDetailView()
    private lazy var ledgerAccountDetailLayoutBuilder = LedgerAccountDetailLayoutBuilder(theme: theme)
    private lazy var ledgerAccountDetailDataSource: LedgerAccountDetailDataSource = {
        guard let api = api else { fatalError("API should be set.") }
        return LedgerAccountDetailDataSource(
            api: api,
            sharedDataController: sharedDataController,
            loadingController: loadingController,
            account: account,
            authAccount: authAccount,
            rekeyedAccounts: rekeyedAccounts ?? []
        )
    }()

    private let account: Account
    private let authAccount: Account
    private let ledgerIndex: Int?
    private let rekeyedAccounts: [Account]?

    init(
        account: Account,
        authAccount: Account,
        ledgerIndex: Int?,
        rekeyedAccounts: [Account]?,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        self.authAccount = authAccount
        self.ledgerIndex = ledgerIndex

        if account.authorization.isRekeyed {
            let account = Account(address: account.authAddress.unwrap(or: ""))
            account.authorization = .ledger
            self.rekeyedAccounts = [ account ]
        } else {
            self.rekeyedAccounts = rekeyedAccounts
        }

        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        scrollView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        contentView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        setTitle()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        contentView.addSubview(ledgerAccountDetailView)
        ledgerAccountDetailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func linkInteractors() {
        super.linkInteractors()
        ledgerAccountDetailView.collectionView.delegate = ledgerAccountDetailLayoutBuilder
        ledgerAccountDetailView.collectionView.dataSource = ledgerAccountDetailDataSource
    }
}

extension LedgerAccountDetailViewController {
    private func loadData() {
        ledgerAccountDetailDataSource.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didLoadData:
                self.ledgerAccountDetailView.collectionView.reloadData()
            case .didFailLoadingData:
                self.ledgerAccountDetailView.collectionView.reloadData()
            }
        }

        ledgerAccountDetailDataSource.fetchAssets()
    }
}

extension LedgerAccountDetailViewController {
    private func setTitle() {
        if let index = ledgerIndex {
            title = "ledger-account-detail-name".localized(params: "\(index)")
        } else {
            title = account.address.shortAddressDisplay
        }
    }
}
