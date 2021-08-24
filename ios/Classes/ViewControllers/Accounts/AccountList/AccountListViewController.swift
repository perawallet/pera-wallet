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
//  AccountListViewController.swift

import UIKit

class AccountListViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var accountListView = AccountListView()

    private lazy var emptyStateView = SearchEmptyView()

    weak var delegate: AccountListViewControllerDelegate?
    
    private var accountListLayoutBuilder: AccountListLayoutBuilder
    private var accountListDataSource: AccountListDataSource
    private var mode: Mode
    
    init(mode: Mode, configuration: ViewControllerConfiguration) {
        self.mode = mode
        accountListLayoutBuilder = AccountListLayoutBuilder()
        accountListDataSource = AccountListDataSource(mode: mode)
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.secondary
        emptyStateView.setTitle("asset-not-found-title".localized)
        setTitle()
        updateContentStateView()
    }
    
    override func setListeners() {
        accountListLayoutBuilder.delegate = self
        accountListView.delegate = self
        accountListView.accountsCollectionView.dataSource = accountListDataSource
        accountListView.accountsCollectionView.delegate = accountListLayoutBuilder
    }
    
    override func prepareLayout() {
        setupAccountListViewLayout()
    }
}

extension AccountListViewController {
    private func setupAccountListViewLayout() {
        view.addSubview(accountListView)
        
        accountListView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AccountListViewController {
    private func setTitle() {
        switch mode {
        case .contact,
             .transactionSender:
            accountListView.titleLabel.text = "send-sending-algos-select".localized
        case .transactionReceiver:
            accountListView.titleLabel.text = "send-receiving-algos-select".localized
        case .walletConnect:
            accountListView.titleLabel.text = "accounts-title".localized
        }
    }

    private func updateContentStateView() {
        if accountListDataSource.accounts.isEmpty {
            accountListView.accountsCollectionView.contentState = .empty(emptyStateView)
        } else {
            accountListView.accountsCollectionView.contentState = .none
        }
    }
}

extension AccountListViewController: AccountListViewDelegate {
    func accountListViewDidTapCancelButton(_ accountListView: AccountListView) {
        delegate?.accountListViewControllerDidCancelScreen(self)
    }
}

extension AccountListViewController: AccountListLayoutBuilderDelegate {
    func accountListLayoutBuilder(_ layoutBuilder: AccountListLayoutBuilder, didSelectAt indexPath: IndexPath) {
        let accounts = accountListDataSource.accounts
        
        guard indexPath.item < accounts.count else {
            return
        }
        
        let account = accounts[indexPath.item]
        delegate?.accountListViewController(self, didSelectAccount: account)
    }
}

extension AccountListViewController {
    enum Mode {
        case walletConnect
        case contact(assetDetail: AssetDetail?)
        case transactionReceiver(assetDetail: AssetDetail?)
        case transactionSender(assetDetail: AssetDetail?)
    }
}

protocol AccountListViewControllerDelegate: AnyObject {
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account)
    func accountListViewControllerDidCancelScreen(_ viewController: AccountListViewController)
}
