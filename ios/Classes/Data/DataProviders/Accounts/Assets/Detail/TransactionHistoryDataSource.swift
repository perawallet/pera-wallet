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
//  AccountTransactionHistoryDataSource.swift

import UIKit
import Magpie

class TransactionHistoryDataSource: NSObject, UICollectionViewDataSource {
    
    private var transactions = [TransactionItem]()
    private var account: Account
    private var assetDetail: AssetDetail?
    private var contacts = [Contact]()
    
    private let api: AlgorandAPI?

    private var csvTransactions = [Transaction]()

    private var transactionParams: TransactionParams?
    private var fetchRequest: EndpointOperatable?
    private var nextToken: String?
    var hasNext: Bool {
        return nextToken != nil
    }
    private let paginationRequestThreshold = 5
    
    var openFilterOptionsHandler: ((TransactionHistoryDataSource) -> Void)?
    var shareHistoryHandler: ((TransactionHistoryDataSource) -> Void)?
    
    init(api: AlgorandAPI?, account: Account, assetDetail: AssetDetail?) {
        self.api = api
        self.account = account
        self.assetDetail = assetDetail
        super.init()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < transactions.count {
            if let reward = transactions[indexPath.item] as? Reward {
                if let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RewardCell.reusableIdentifier,
                    for: indexPath
                ) as? RewardCell {
                    cell.contextView.bind(RewardViewModel(reward: reward))
                    return cell
                }
            } else if let transaction = transactions[indexPath.item] as? Transaction {
                return dequeueHistoryCell(in: collectionView, with: transaction, at: indexPath)
            } else if let transaction = transactions[indexPath.item] as? PendingTransaction {
                return dequeuePendingCell(in: collectionView, with: transaction, at: indexPath)
            }
        }
        fatalError("Index path is out of bounds")
    }
}

extension TransactionHistoryDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind != UICollectionView.elementKindSectionHeader {
            fatalError("Unexpected element kind")
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TransactionHistoryHeaderSupplementaryView.reusableIdentifier,
            for: indexPath
        ) as? TransactionHistoryHeaderSupplementaryView else {
            fatalError("Unexpected element kind")
        }
        
        headerView.delegate = self
        return headerView
    }
}

extension TransactionHistoryDataSource {
    private func dequeueHistoryCell(
        in collectionView: UICollectionView,
        with transaction: Transaction,
        at indexPath: IndexPath
    ) -> TransactionHistoryCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TransactionHistoryCell.reusableIdentifier,
            for: indexPath) as? TransactionHistoryCell else {
                fatalError("Index path is out of bounds")
        }
        
        if let assetTransaction = transaction.assetTransfer {
            if assetTransaction.receiverAddress == account.address {
                configure(cell, with: transaction, for: transaction.sender)
            } else {
                configure(cell, with: transaction, for: assetTransaction.receiverAddress)
            }
        } else if let payment = transaction.payment {
            if payment.receiver == account.address {
                configure(cell, with: transaction, for: transaction.sender)
            } else {
                configure(cell, with: transaction, for: transaction.payment?.receiver)
            }
        }
        
        return cell
    }
    
    private func configure(_ cell: TransactionHistoryCell, with transaction: Transaction, for address: String?) {
        if let contact = contacts.first(where: { contact -> Bool in
            contact.address == address
        }) {
            transaction.contact = contact
            let config = TransactionViewModelDependencies(
                account: account,
                assetDetail: assetDetail,
                transaction: transaction,
                contact: contact
            )
            TransactionHistoryViewModel().configure(cell.contextView, with: config)
        } else {
            let config = TransactionViewModelDependencies(account: account, assetDetail: assetDetail, transaction: transaction)
            TransactionHistoryViewModel().configure(cell.contextView, with: config)
        }
    }
    
    private func dequeuePendingCell(
        in collectionView: UICollectionView,
        with transaction: PendingTransaction,
        at indexPath: IndexPath
    ) -> PendingTransactionCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PendingTransactionCell.reusableIdentifier,
            for: indexPath) as? PendingTransactionCell else {
                fatalError("Index path is out of bounds")
        }
        
        let address = transaction.receiver == account.address ? transaction.sender : transaction.receiver
        configure(cell, with: transaction, for: address)
        return cell
    }
    
    private func configure(_ cell: PendingTransactionCell, with transaction: PendingTransaction, for address: String?) {
        if let contact = contacts.first(where: { contact -> Bool in
            contact.address == address
        }) {
            transaction.contact = contact
            let config = TransactionViewModelDependencies(
                account: account,
                assetDetail: assetDetail,
                transaction: transaction,
                contact: contact
            )
            TransactionHistoryViewModel().configurePending(cell.contextView, with: config)
        } else {
            let config = TransactionViewModelDependencies(account: account, assetDetail: assetDetail, transaction: transaction)
            TransactionHistoryViewModel().configurePending(cell.contextView, with: config)
        }
    }
}

extension TransactionHistoryDataSource {
    func loadData(
        for account: Account,
        withRefresh refresh: Bool,
        between dates: (Date?, Date?),
        isPaginated: Bool,
        then handler: @escaping ([TransactionItem]?, APIError?) -> Void
    ) {
        api?.getTransactionParams { response in
            switch response {
            case let .failure(apiError, _):
                handler(nil, apiError)
            case let .success(params):
                self.transactionParams = params
                self.fetchTransactions(for: account, between: dates, withRefresh: refresh, isPaginated: isPaginated, then: handler)
            }
        }
    }
}

extension TransactionHistoryDataSource {
    private func fetchTransactions(
        for account: Account,
        between dates: (Date?, Date?),
        withRefresh refresh: Bool,
        isPaginated: Bool,
        limit: Int = 15,
        then handler: @escaping ([TransactionItem]?, APIError?) -> Void
    ) {
        var assetId: String?
        if let id = assetDetail?.id {
            assetId = String(id)
        }
        
        let draft = TransactionFetchDraft(account: account, dates: dates, nextToken: nextToken, assetId: assetId, limit: limit)
        fetchRequest = api?.fetchTransactions(with: draft) { response in
            switch response {
            case let .failure(apiError, _):
                handler(nil, apiError)
            case let .success(transactions):
                if refresh {
                    self.transactions.removeAll()
                }
                
                transactions.transactions.forEach { transaction in
                    transaction.status = .completed
                }
                
                self.nextToken = transactions.nextToken
                
                if let rewardDisplayPreference = self.api?.session.rewardDisplayPreference,
                    rewardDisplayPreference == .allowed,
                    self.assetDetail == nil {
                    self.setRewards(from: transactions, for: account, isPaginated: isPaginated)
                } else {
                    let filteredTrnsactions = transactions.transactions.filter { transaction -> Bool in
                        if let assetDetail = self.assetDetail {
                            guard let assetId = transaction.assetTransfer?.assetId else {
                                return false
                            }
                            if transaction.isAssetCreationTransaction(for: account.address) {
                                return false
                            }
                            return assetId == assetDetail.id
                        } else {
                            if let assetTransfer = transaction.assetTransfer,
                                assetTransfer.receiverAddress == account.address,
                                assetTransfer.amount == 0 {
                                return true
                            }
                            return transaction.payment != nil
                        }
                    }
                    
                    if isPaginated {
                        self.transactions.append(contentsOf: filteredTrnsactions)
                    } else {
                        self.transactions = filteredTrnsactions
                    }
                }
                
                handler(self.transactions, nil)
            }
        }
    }
}

extension TransactionHistoryDataSource {
    private func setRewards(from transactions: TransactionList, for account: Account, isPaginated: Bool) {
        let filteredTransactions = transactions.transactions.filter { transaction -> Bool in
            if let assetTransfer = transaction.assetTransfer,
                assetTransfer.receiverAddress == account.address,
                assetTransfer.amount == 0 {
                return true
            }
            return transaction.payment != nil && assetDetail == nil
        }
        
        for transaction in filteredTransactions {
            self.transactions.append(transaction)
            if let rewards = transaction.getRewards(for: account.address),
               rewards > 0 {
                let reward = Reward(amount: UInt64(rewards), date: transaction.date)
                self.transactions.append(reward)
            }
        }
    }
}

extension TransactionHistoryDataSource {
    func fetchPendingTransactions(for account: Account, then handler: @escaping ([TransactionItem]?, APIError?) -> Void) {
        api?.fetchPendingTransactions(for: account.address) { response in
            switch response {
            case let .success(pendingTransactionList):
                self.filter(pendingTransactionList.pendingTransactions)
                handler(pendingTransactionList.pendingTransactions, nil)
            case let .failure(apiError, _):
                handler(nil, apiError)
            }
        }
    }
    
    private func filter(_ pendingTransactions: [PendingTransaction]) {
        let filteredTransactions = transactions.filter { ($0 as? PendingTransaction)?.signature != nil }
        if filteredTransactions.count == pendingTransactions.count {
            return
        }
        
        self.transactions = self.transactions.filter { item -> Bool in
            guard let transactionItem = item as? Transaction,
                transactionItem.status == .pending else {
                return true
            }
            
            let containsPendingTransaction = pendingTransactions.contains { pendingTransaction -> Bool in
                transactionItem.transactionSignature?.signature == pendingTransaction.signature
            }
            
            return !containsPendingTransaction
        }
        self.transactions.insert(contentsOf: pendingTransactions, at: 0)
    }
}

extension TransactionHistoryDataSource {
    func setupContacts() {
        contacts.removeAll()
        fetchContacts()
    }
    
    private func fetchContacts() {
        Contact.fetchAll(entity: Contact.entityName) { response in
            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Contact] else {
                    return
                }
                
                self.contacts.append(contentsOf: results)
            default:
                break
            }
        }
    }
    
    func transactionCount() -> Int {
        return transactions.count
    }
    
    func transaction(at indexPath: IndexPath) -> Transaction? {
        if indexPath.item >= 0 && indexPath.item < transactions.count {
            guard let transaction = transactions[indexPath.item] as? Transaction else {
                return nil
            }
            return transaction
        }
        
        return nil
    }
    
    func clear() {
        fetchRequest?.cancel()
        nextToken = nil
        transactions.removeAll()
    }
    
    var isEmpty: Bool {
        transactions.isEmpty
    }
    
    func shouldSendPaginatedRequest(at index: Int) -> Bool {
        if transactionCount() < paginationRequestThreshold {
            return index == transactionCount() - 1 && hasNext
        }
        
        return index == transactionCount() - paginationRequestThreshold && hasNext
    }
    
    func updateAssetDetail(_ assetDetail: AssetDetail?) {
        self.assetDetail = assetDetail
    }
}

extension TransactionHistoryDataSource: TransactionHistoryHeaderSupplementaryViewDelegate {
    func transactionHistoryHeaderSupplementaryViewDidOpenFilterOptions(
        _ transactionHistoryHeaderSupplementaryView: TransactionHistoryHeaderSupplementaryView
    ) {
        guard let openFilterOptionsHandler = openFilterOptionsHandler else {
            return
        }
        openFilterOptionsHandler(self)
    }
    
    func transactionHistoryHeaderSupplementaryViewDidShareHistory(
        _ transactionHistoryHeaderSupplementaryView: TransactionHistoryHeaderSupplementaryView
    ) {
        guard let shareHistoryHandler = shareHistoryHandler else {
            return
        }
        shareHistoryHandler(self)
    }
}

extension TransactionHistoryDataSource {
    func fetchAllTransactions(
        for account: Account,
        between dates: (Date?, Date?),
        nextToken token: String?,
        then handler: @escaping ([Transaction]?, APIError?) -> Void
    ) {
        var assetId: String?
        if let id = assetDetail?.id {
            assetId = String(id)
        }

        let draft = TransactionFetchDraft(account: account, dates: dates, nextToken: token, assetId: assetId, limit: nil)

        api?.fetchTransactions(with: draft) { response in
            switch response {
            case let .failure(apiError, _):
                handler(nil, apiError)
            case let .success(transactions):
                self.csvTransactions.append(contentsOf: transactions.transactions)

                if transactions.nextToken == nil {
                    let fetchedTransactions = self.csvTransactions
                    self.csvTransactions.removeAll()
                    handler(fetchedTransactions, nil)
                    return
                }

                self.fetchAllTransactions(for: account, between: dates, nextToken: transactions.nextToken, then: handler)
            }
        }
    }
}
