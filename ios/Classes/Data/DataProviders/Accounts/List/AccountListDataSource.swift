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
//  AccountListDataSource.swift

import UIKit

class AccountListDataSource: NSObject, UICollectionViewDataSource {

    private(set) var accounts = [Account]()
    private let mode: AccountListViewController.Mode
    
    init(mode: AccountListViewController.Mode) {
        self.mode = mode
        super.init()
        
        guard let userAccounts = UIApplication.shared.appConfiguration?.session.accounts else {
            return
        }
        
        switch mode {
        case .empty,
             .assetCount:
            accounts.append(contentsOf: userAccounts)
        case let .transactionReceiver(assetDetail),
             let .transactionSender(assetDetail),
             let .contact(assetDetail):
            guard let assetDetail = assetDetail else {
                accounts.append(contentsOf: userAccounts)
                return
            }
            
            let filteredAccounts = userAccounts.filter { account -> Bool in
                account.assetDetails.contains { detail -> Bool in
                     assetDetail.id == detail.id
                }
            }
            accounts = filteredAccounts
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AccountViewCell.reusableIdentifier,
            for: indexPath) as? AccountViewCell else {
                fatalError("Index path is out of bounds")
        }
        
        if indexPath.item < accounts.count {
            let account = accounts[indexPath.item]
            cell.bind(AccountListViewModel(account: account, mode: mode))
        }
        
        return cell
    }
}
