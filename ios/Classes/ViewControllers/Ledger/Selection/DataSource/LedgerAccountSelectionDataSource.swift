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

typealias LedgerAccountCell = BaseCollectionViewCell<LedgerAccountCellView>

final class LedgerAccountSelectionDataSource:
    NSObject,
    SingleSelectionLedgerAccountCellDelegate,
    MultipleSelectionLedgerAccountCellDelegate {
    weak var delegate: LedgerAccountSelectionDataSourceDelegate?

    private var hasOngoingRekeying: Bool {
        return rekeyingAccount != nil
    }
    
    private let accountsFetchGroup = DispatchGroup()
    
    private let api: ALGAPI
    private let analytics: ALGAnalytics
    private let sharedDataController: SharedDataController
    private var accounts = [Account]()
    private let ledgerAccounts: [Account]
    private let isMultiSelect: Bool
    private let rekeyingAccount: Account?
    
    private var rekeyedAccounts: [String: [Account]] = [:]
    
    private lazy var rekeyingValidator = RekeyingValidator(
        session: api.session,
        sharedDataController: sharedDataController
    )
    
    init(
        api: ALGAPI,
        analytics: ALGAnalytics,
        sharedDataController: SharedDataController,
        accounts: [Account],
        rekeyingAccount: Account?,
        isMultiSelect: Bool
    ) {
        self.api = api
        self.analytics = analytics
        self.sharedDataController = sharedDataController
        self.ledgerAccounts = accounts
        self.rekeyingAccount = rekeyingAccount
        self.isMultiSelect = isMultiSelect
        super.init()
    }
}

extension LedgerAccountSelectionDataSource {
    func loadData() {
        for account in ledgerAccounts {
            account.authorization = .ledger

            if hasOngoingRekeying {
                filterAvailableAccountsForRekeying(account)
            } else {
                fetchRekeyedAccounts(of: account)
                accounts.append(account)
            }
        }
        
        accountsFetchGroup.notify(queue: .main) {
            self.delegate?.ledgerAccountSelectionDataSource(self, didFetch: self.accounts)
        }
    }
    
    private func filterAvailableAccountsForRekeying(_ account: Account) {
        guard let rekeyingAccount else { return }
        
        let validation = rekeyingValidator.validateRekeying(
            from: rekeyingAccount,
            to: account
        )

        /// <note>
        /// We're not displaying the same account in this list, we've a different flow for undoing the rekey.
        let isNotSameAccount = !account.isSameAccount(with: rekeyingAccount)

        if validation.isSuccess && isNotSameAccount {
            accounts.append(account)
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
                    rekeyedAccount.authorization = .unknownToLedgerRekeyed

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
                self.analytics.record(
                    .ledgerAccountSelectionScreenFetchingRekeyingAccountsFailed(
                        accountAddress: account.address,
                        network: self.api.network
                    )
                )

                self.delegate?.ledgerAccountSelectionDataSourceDidFailToFetch(self)
            }
            
            self.accountsFetchGroup.leave()
        }
    }

    private func authenticatedAccountOnTheSameLedgerDevice(_ rekeyedAccount: Account) -> Account? {
        return ledgerAccounts.first { $0.address == rekeyedAccount.address }
    }

    func getAuthAccount(of account: Account) -> Account? {
        return ledgerAccounts.first(matching: (\.address, account.authAddress))
    }
}

extension LedgerAccountSelectionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let account = accounts[safe: indexPath.item] else {
            fatalError("Index path is out of bounds")
        }

        return makeLedgerAccountCell(
            collectionView: collectionView,
            account: account,
            indexPath: indexPath
        )
    }

    private func makeLedgerAccountCell(
        collectionView: UICollectionView,
        account: Account,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        if isMultiSelect {
            return makeMultipleSelectionLedgerAccountCell(
                collectionView: collectionView,
                account: account,
                indexPath: indexPath
            )
        } else {
            return makeSingleSelectionLedgerAccountCell(
                collectionView: collectionView,
                account: account,
                indexPath: indexPath
            )
        }
    }

    private func makeMultipleSelectionLedgerAccountCell(
        collectionView: UICollectionView,
        account: Account,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeue(MultipleSelectionLedgerAccountCell.self, at: indexPath)
        cell.delegate = self
        let viewModel = LedgerAccountViewModel(account)
        cell.bind(viewModel)
        return cell
    }

    private func makeSingleSelectionLedgerAccountCell(
        collectionView: UICollectionView,
        account: Account,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeue(SingleSelectionLedgerAccountCell.self, at: indexPath)
        cell.delegate = self
        let viewModel = LedgerAccountViewModel(account)
        cell.bind(viewModel)
        return cell
    }
}

extension LedgerAccountSelectionDataSource {
    func singleSelectionLedgerAccountCellDidOpenMoreInfo(_ ledgerAccountCell: SingleSelectionLedgerAccountCell) {
        delegate?.ledgerAccountSelectionDataSource(self, didTapMoreInfoFor: ledgerAccountCell)
    }

    func multipleSelectionLedgerAccountCellDidOpenMoreInfo(_ ledgerAccountCell: MultipleSelectionLedgerAccountCell) {
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
            account.authorization.isLedger && account.address == address
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
