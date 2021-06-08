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
//  LedgerAccountDetailViewController.swift

import UIKit
import SVProgressHUD

class LedgerAccountDetailViewController: BaseScrollViewController {
    
    private lazy var ledgerAccountDetailView = LedgerAccountDetailView()

    private lazy var dataSource: LedgerAccountDetailViewDataSource = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return LedgerAccountDetailViewDataSource(api: api)
    }()

    private let account: Account
    private let ledgerIndex: Int?
    private let rekeyedAccounts: [Account]?
    
    init(account: Account, ledgerIndex: Int?, rekeyedAccounts: [Account]?, configuration: ViewControllerConfiguration) {
        self.account = account
        self.ledgerIndex = ledgerIndex
        self.rekeyedAccounts = rekeyedAccounts
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.fetchAssets(for: account)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        if let index = ledgerIndex {
            title = "Ledger #\(index)"
        } else {
            title = account.address.shortAddressDisplay()
        }
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupLedgerAccountDetailViewLayout()
    }

    override func linkInteractors() {
        super.linkInteractors()
        dataSource.delegate = self
    }
}

extension LedgerAccountDetailViewController {
    private func setupLedgerAccountDetailViewLayout() {
        contentView.addSubview(ledgerAccountDetailView)
        
        ledgerAccountDetailView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LedgerAccountDetailViewController: LedgerAccountDetailViewDataSourceDelegate {
    func ledgerAccountDetailViewDataSource(
        _ ledgerAccountDetailViewDataSource: LedgerAccountDetailViewDataSource,
        didReturn account: Account
    ) {
        ledgerAccountDetailView.bind(LedgerAccountDetailViewModel(account: account, rekeyedAccounts: rekeyedAccounts))
    }
}
