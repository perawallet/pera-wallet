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
    
    init(
        sharedDataController: SharedDataController,
        mode: AccountListViewController.Mode
    ) {
        self.mode = mode
        super.init()
        
        let userAccounts = sharedDataController.accountCollection.sorted()

        switch mode {
        case .walletConnect:
            accounts = userAccounts.filter { $0.value.type != .watch }
        case let .transactionReceiver(assetDetail),
            let .transactionSender(assetDetail),
            let .contact(assetDetail):
            guard let assetDetail = assetDetail else {
                accounts.append(contentsOf: userAccounts)
                return
            }
            
            let filteredAccounts = userAccounts.filter { account in
                account.value.compoundAssets.contains { detail in
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
            cell.bindData(AccountCellViewModel(account: account.value, mode: mode))
        }
        return cell
    }

    func cellForAccountSelection(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(AccountSelectionViewCell.self, at: indexPath)
        if indexPath.item < accounts.count {
            let account = accounts[indexPath.item]
            cell.bindData(AccountCellViewModel(account: account.value, mode: mode))
        }
        return cell
    }
}
