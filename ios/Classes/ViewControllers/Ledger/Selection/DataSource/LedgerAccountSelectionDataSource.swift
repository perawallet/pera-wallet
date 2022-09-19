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
//  LedgerAccountSelectionDataSource.swift

import UIKit

final class LedgerAccountSelectionDataSource: NSObject {
    weak var delegate: LedgerAccountSelectionDataSourceDelegate?
    
    private let accountsFetchGroup = DispatchGroup()
    
    private let api: ALGAPI
    private var accounts = [Account]()

    private let ledgerAccounts: [Account]
    private let isMultiSelect: Bool
    
    private var rekeyedAccounts: [String: [Account]] = [:]
    
    init(api: ALGAPI, accounts: [Account], isMultiSelect: Bool) {
        self.api = api
        self.ledgerAccounts = accounts
        self.isMultiSelect = isMultiSelect
        super.init()
    }
}

extension LedgerAccountSelectionDataSource {
    func loadData() {
        for account in ledgerAccounts {
            account.type = .ledger
            account.assets = account.nonDeletedAssets()
            accounts.append(account)
            fetchRekeyedAccounts(of: account)
        }
        
        accountsFetchGroup.notify(queue: .main) {
            self.delegate?.ledgerAccountSelectionDataSource(self, didFetch: self.accounts)
        }
    }
    
    private func fetchRekeyedAccounts(of account: Account) {
        accountsFetchGroup.enter()
        
        api.fetchRekeyedAccounts(account.address) {
            [weak self] response in
            guard let self = self else { return }
            switch response {
            case let .success(rekeyedAccountsResponse):
                let rekeyedAccounts = rekeyedAccountsResponse.accounts.filter { $0.authAddress != $0.address }
                self.rekeyedAccounts[account.address] = rekeyedAccounts
                rekeyedAccounts.forEach { rekeyedAccount in
                    rekeyedAccount.assets = rekeyedAccount.nonDeletedAssets()
                    rekeyedAccount.type = .rekeyed

                    /// <note> If a rekeyed account is already in the ledger accounts on the same ledger device, it should not be added to the list again.
                    if let ledgerAccount = self.authenticatedAccountOnTheSameLedgerDevice(rekeyedAccount) {
                        if let authAddress = ledgerAccount.authAddress,
                           let ledgerDetail = account.ledgerDetail {
                            ledgerAccount.addRekeyDetail(ledgerDetail, for: authAddress)
                        }
                    } else {
                        if let authAddress = rekeyedAccount.authAddress,
                           let ledgerDetail = account.ledgerDetail {
                            rekeyedAccount.addRekeyDetail(ledgerDetail, for: authAddress)
                        }
                        self.accounts.append(rekeyedAccount)
                    }
                }
            case .failure:
                self.delegate?.ledgerAccountSelectionDataSourceDidFailToFetch(self)
            }
            
            self.accountsFetchGroup.leave()
        }
    }

    private func authenticatedAccountOnTheSameLedgerDevice(_ rekeyedAccount: Account) -> Account? {
        return ledgerAccounts.first { $0.address == rekeyedAccount.address }
    }
}

extension LedgerAccountSelectionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let account = accounts[safe: indexPath.item] {
            let cell = collectionView.dequeue(LedgerAccountCell.self, at: indexPath)
            cell.delegate = self
            cell.bind(LedgerAccountViewModel(account))
            return cell
        }

        fatalError("Index path is out of bounds")
    }
}

extension LedgerAccountSelectionDataSource: LedgerAccountCellDelegate {
    func ledgerAccountCellDidOpenMoreInfo(_ ledgerAccountCell: LedgerAccountCell) {
        delegate?.ledgerAccountSelectionDataSource(self, didTapMoreInfoFor: ledgerAccountCell)
    }
}

extension LedgerAccountSelectionDataSource {
    func account(at index: Int) -> Account? {
        return accounts[safe: index]
    }
    
    func rekeyedAccounts(for account: String) -> [Account]? {
        return rekeyedAccounts[account]
    }
    
    func ledgerAccountIndex(for address: String) -> Int? {
        return accounts.firstIndex { account -> Bool in
            account.type == .ledger && account.address == address
        }
    }

    func getSelectedAccounts(_ indexes: [IndexPath]) -> [Account] {
        var selectedAccounts: [Account] = []
        indexes.forEach { indexPath in
            if let account = accounts[safe: indexPath.item] {
                selectedAccounts.append(account)
            }
        }

        return selectedAccounts
    }
}

protocol LedgerAccountSelectionDataSourceDelegate: AnyObject {
    func ledgerAccountSelectionDataSource(
        _ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource,
        didFetch accounts: [Account]
    )
    func ledgerAccountSelectionDataSourceDidFailToFetch(_ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource)
    func ledgerAccountSelectionDataSource(
        _ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource,
        didTapMoreInfoFor cell: LedgerAccountCell
    )
}
