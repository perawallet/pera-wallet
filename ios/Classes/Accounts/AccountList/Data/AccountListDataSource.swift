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
//  AccountListDataSource.swift

import UIKit

final class AccountListDataSource: NSObject {
    private(set) var accounts = [AccountHandle]()
    private let mode: AccountListViewController.Mode
    private let currencyFormatter: CurrencyFormatter
    
    init(
        sharedDataController: SharedDataController,
        mode: AccountListViewController.Mode,
        currencyFormatter: CurrencyFormatter
    ) {
        self.mode = mode
        self.currencyFormatter = currencyFormatter

        super.init()
        
        let userAccounts = sharedDataController.sortedAccounts()

        switch mode {
        case .walletConnect:
            accounts = userAccounts.filter { !$0.value.isWatchAccount() }
        case let .contact(assetDetail):
            let availableAccounts = userAccounts.filter { !$0.value.isWatchAccount() }

            guard let assetDetail = assetDetail else {
                accounts.append(contentsOf: availableAccounts)
                return
            }

            let filteredAccounts = availableAccounts.filter { account in
                account.value.allAssets.someArray.contains { detail in
                    assetDetail.id == detail.id
                }
            }
            accounts = filteredAccounts

        case let .transactionReceiver(assetDetail),
            let .transactionSender(assetDetail):
            guard let assetDetail = assetDetail else {
                accounts.append(contentsOf: userAccounts)
                return
            }
            
            let filteredAccounts = userAccounts.filter { account in
                account.value.allAssets.someArray.contains { detail in
                    assetDetail.id == detail.id
                }
            }
            accounts = filteredAccounts
        }
    }
}

extension AccountListDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accounts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if case .walletConnect = mode {
            return cellForAccountCheckmarkSelection(collectionView, cellForItemAt: indexPath)
        } else {
            return cellForAccountSelection(collectionView, cellForItemAt: indexPath)
        }
    }

    func cellForAccountCheckmarkSelection(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(AccountCheckmarkSelectionViewCell.self, at: indexPath)
        if indexPath.item < accounts.count {
            let account = accounts[indexPath.item]
            let viewModel = AccountCellViewModel(
                account: account.value,
                mode: mode,
                currencyFormatter: currencyFormatter
            )
            cell.bindData(viewModel)
        }
        return cell
    }

    func cellForAccountSelection(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(AccountSelectionViewCell.self, at: indexPath)
        if indexPath.item < accounts.count {
            let account = accounts[indexPath.item]
            let viewModel = AccountCellViewModel(
                account: account.value,
                mode: mode,
                currencyFormatter: currencyFormatter
            )
            cell.bindData(viewModel)
        }
        return cell
    }
}
