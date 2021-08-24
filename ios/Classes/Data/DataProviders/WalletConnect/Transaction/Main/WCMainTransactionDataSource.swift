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
//   WCMainTransactionDataSource.swift

import UIKit

class WCMainTransactionDataSource: NSObject {

    weak var delegate: WCMainTransactionDataSourceDelegate?

    private let walletConnector: WalletConnector
    private let transactionRequest: WalletConnectRequest
    let transactionOption: WCTransactionOption?
    private(set) var groupedTransactions: [Int64: [WCTransaction]] = [:]
    private let session: Session?

    init(
        transactions: [WCTransaction],
        transactionRequest: WalletConnectRequest,
        transactionOption: WCTransactionOption?,
        session: Session?,
        walletConnector: WalletConnector
    ) {
        self.walletConnector = walletConnector
        self.transactionRequest = transactionRequest
        self.transactionOption = transactionOption
        self.session = session
        super.init()
        groupTransactions(transactions)
    }

    private func groupTransactions(_ transactions: [WCTransaction]) {
        let transactionData = transactions.compactMap { $0.unparsedTransactionDetail }
        var error: NSError?
        let verifiedGroups = AlgorandSDK().findAndVerifyTransactionGroups(for: transactionData, error: &error)

        if error != nil {
            delegate?.wcMainTransactionDataSourceDidFailedGroupingValidation(self)
            return
        }

        guard let groups = verifiedGroups,
              groups.count == transactions.count else {
            delegate?.wcMainTransactionDataSourceDidFailedGroupingValidation(self)
            return
        }

        for (index, group) in groups.enumerated() {
            if groupedTransactions[group] == nil {
                groupedTransactions[group] = [transactions[index]]
            } else {
                groupedTransactions[group]?.append(transactions[index])
            }
        }
    }
}

extension WCMainTransactionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupedTransactions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let transactions = transactions(at: indexPath.item) else {
            fatalError("Unexpected index")
        }

        if transactions.count == 1 {
            return dequeueSingleTransactionCell(in: collectionView, at: indexPath)
        }

        return dequeueMultipleTransactionCell(in: collectionView, at: indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind != UICollectionView.elementKindSectionHeader {
            fatalError("Unexpected element kind")
        }

        return dequeueHeaderView(in: collectionView, at: indexPath)
    }
}

extension WCMainTransactionDataSource {
    private func dequeueSingleTransactionCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let transaction = transactions(at: indexPath.item)?.first else {
            fatalError("Unexpected index")
        }

        if transaction.transactionDetail?.isAppCallTransaction ?? false {
            return dequeueAppCallCell(in: collectionView, at: indexPath, for: transaction)
        }

        if transaction.signerAccount == nil {
            return dequeueUnsignableCell(in: collectionView, at: indexPath, for: transaction)
        }

        return dequeueSingleSignerCell(in: collectionView, at: indexPath, for: transaction)
    }

    private func dequeueAppCallCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        for transaction: WCTransaction
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WCAppCallTransactionItemCell.reusableIdentifier,
            for: indexPath
        ) as? WCAppCallTransactionItemCell else {
            fatalError("Unexpected cell type")
        }

        cell.bind(WCAppCallTransactionItemViewModel(transaction: transaction))
        return cell
    }

    private func dequeueUnsignableCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        for transaction: WCTransaction
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WCGroupAnotherAccountTransactionItemCell.reusableIdentifier,
            for: indexPath
        ) as? WCGroupAnotherAccountTransactionItemCell else {
            fatalError("Unexpected cell type")
        }

        cell.bind(
            WCGroupTransactionItemViewModel(
                transaction: transaction,
                account: nil,
                assetDetail: assetDetail(from: transaction)
            )
        )

        return cell
    }

    private func dequeueSingleSignerCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        for transaction: WCTransaction
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WCGroupTransactionItemCell.reusableIdentifier,
            for: indexPath
        ) as? WCGroupTransactionItemCell else {
            fatalError("Unexpected cell type")
        }

        cell.bind(
            WCGroupTransactionItemViewModel(
                transaction: transaction,
                account: session?.accounts.first(of: \.address, equalsTo: transaction.transactionDetail?.sender),
                assetDetail: assetDetail(from: transaction)
            )
        )

        return cell
    }

    private func dequeueMultipleTransactionCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WCMultipleTransactionItemCell.reusableIdentifier,
            for: indexPath
        ) as? WCMultipleTransactionItemCell else {
            fatalError("Unexpected cell type")
        }

        if let transactions = transactions(at: indexPath.item) {
            cell.bind(WCMultipleTransactionItemViewModel(transactions: transactions))
        }

        return cell
    }

    private func dequeueHeaderView(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: WCMainTransactionSupplementaryHeaderView.reusableIdentifier,
            for: indexPath
        ) as? WCMainTransactionSupplementaryHeaderView else {
            fatalError("Unexpected element kind")
        }

        if let session = walletConnector.allWalletConnectSessions.first(of: \.urlMeta.wcURL, equalsTo: transactionRequest.url) {
            headerView.bind(
                WCMainTransactionHeaderViewModel(
                    session: session,
                    text: transactionOption?.message,
                    transactionCount: groupedTransactions.count
                )
            )
        }

        headerView.delegate = self
        return headerView
    }
}

extension WCMainTransactionDataSource {
    func transactions(at index: Int) -> [WCTransaction]? {
        return groupedTransactions[Int64(index)]
    }

    private func assetDetail(from transaction: WCTransaction) -> AssetDetail? {
        guard let session = session,
              let assetId = transaction.transactionDetail?.assetId else {
            return nil
        }

        return session.assetDetails[assetId]
    }
}

extension WCMainTransactionDataSource: WCMainTransactionSupplementaryHeaderViewDelegate {
    func wcMainTransactionSupplementaryHeaderViewDidOpenLongMessageView(
        _ wcMainTransactionSupplementaryHeaderView: WCMainTransactionSupplementaryHeaderView
    ) {
        delegate?.wcMainTransactionDataSourceDidOpenLongDappMessageView(self)
    }
}

protocol WCMainTransactionDataSourceDelegate: AnyObject {
    func wcMainTransactionDataSourceDidFailedGroupingValidation(_ wcMainTransactionDataSource: WCMainTransactionDataSource)
    func wcMainTransactionDataSourceDidOpenLongDappMessageView(_ wcMainTransactionDataSource: WCMainTransactionDataSource)
}
