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
//   WCGroupTransactionDataSource.swift

import UIKit

class WCGroupTransactionDataSource: NSObject {

    private let session: Session?
    private let transactions: [WCTransaction]
    private let walletConnector: WalletConnector

    init(session: Session?, transactions: [WCTransaction], walletConnector: WalletConnector) {
        self.session = session
        self.transactions = transactions
        self.walletConnector = walletConnector
        super.init()
    }
}

extension WCGroupTransactionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let transaction = transaction(at: indexPath.item) else {
            fatalError("Unexpected transaction")
        }

        if transaction.transactionDetail?.isAppCallTransaction ?? false {
            return dequeueAppCallCell(in: collectionView, at: indexPath, for: transaction)
        }

        if transaction.transactionDetail?.isAssetConfigTransaction ?? false {
            if transaction.signerAccount == nil {
                return dequeueUnsignableAssetConfigCell(in: collectionView, at: indexPath, for: transaction)
            }

            return dequeueAssetConfigCell(in: collectionView, at: indexPath, for: transaction)
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

    private func dequeueUnsignableAssetConfigCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        for transaction: WCTransaction
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WCAssetConfigAnotherAccountTransactionItemCell.reusableIdentifier,
            for: indexPath
        ) as? WCAssetConfigAnotherAccountTransactionItemCell else {
            fatalError("Unexpected cell type")
        }

        cell.bind(
            WCAssetConfigTransactionItemViewModel(
                transaction: transaction,
                account: session?.accounts.first(of: \.address, equalsTo: transaction.transactionDetail?.sender),
                assetDetail: assetDetail(from: transaction)
            )
        )

        return cell
    }

    private func dequeueAssetConfigCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        for transaction: WCTransaction
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WCAssetConfigTransactionItemCell.reusableIdentifier,
            for: indexPath
        ) as? WCAssetConfigTransactionItemCell else {
            fatalError("Unexpected cell type")
        }

        cell.bind(
            WCAssetConfigTransactionItemViewModel(
                transaction: transaction,
                account: session?.accounts.first(of: \.address, equalsTo: transaction.transactionDetail?.sender),
                assetDetail: assetDetail(from: transaction)
            )
        )

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
            withReuseIdentifier: WCGroupTransactionSupplementaryHeaderView.reusableIdentifier,
            for: indexPath
        ) as? WCGroupTransactionSupplementaryHeaderView else {
            fatalError("Unexpected element kind")
        }

        headerView.bind(WCGroupTransactionHeaderViewModel(transactions: transactions))
        return headerView
    }
}

extension WCGroupTransactionDataSource {
    func transaction(at index: Int) -> WCTransaction? {
        return transactions[safe: index]
    }

    private func assetDetail(from transaction: WCTransaction) -> AssetDetail? {
        guard let session = session,
              let assetId = transaction.transactionDetail?.assetId ??
                transaction.transactionDetail?.assetId ?? transaction.transactionDetail?.assetIdBeingConfigured else {
            return nil
        }

        return session.assetDetails[assetId]
    }
}
