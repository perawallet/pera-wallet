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
//   WCMainTransactionDataSource.swift

import UIKit

class WCMainTransactionDataSource: NSObject {

    weak var delegate: WCMainTransactionDataSourceDelegate?

    private let walletConnector: WalletConnector
    private(set) var transactionRequest: WalletConnectRequest
    let transactionOption: WCTransactionOption?
    private(set) var groupedTransactions: [Int64: [WCTransaction]] = [:]
    private let sharedDataController: SharedDataController

    init(
        sharedDataController: SharedDataController,
        transactions: [WCTransaction],
        transactionRequest: WalletConnectRequest,
        transactionOption: WCTransactionOption?,
        walletConnector: WalletConnector
    ) {
        self.sharedDataController = sharedDataController
        self.walletConnector = walletConnector
        self.transactionRequest = transactionRequest
        self.transactionOption = transactionOption
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

extension WCMainTransactionDataSource {
    func rejectTransaction(reason: WCTransactionErrorResponse = .rejected(.user)) {
        walletConnector.rejectTransactionRequest(transactionRequest, with: reason)
    }

    func signTransactionRequest(signature: [Data?]) {
        walletConnector.signTransactionRequest(transactionRequest, with: signature)
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
}

extension WCMainTransactionDataSource {
    private func dequeueSingleTransactionCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let transaction = transactions(at: indexPath.item)?.first else {
            fatalError("Unexpected index")
        }

        let account: Account? = transaction.signerAccount

        if transaction.transactionDetail?.isAssetConfigTransaction ?? false {
            if account == nil {
                return dequeueUnsignableAssetConfigCell(in: collectionView, at: indexPath, for: transaction, with: account)
            }

            return dequeueAssetConfigCell(in: collectionView, at: indexPath, for: transaction, with: account)
        }

        if account == nil {
            return dequeueUnsignableCell(in: collectionView, at: indexPath, for: transaction, with: account)
        }

        return dequeueSingleSignerCell(in: collectionView, at: indexPath, for: transaction, with: account)
    }

    private func dequeueUnsignableAssetConfigCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        for transaction: WCTransaction,
        with account: Account?
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
                account: account,
                asset: asset(from: transaction)
            )
        )

        return cell
    }

    private func dequeueAssetConfigCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        for transaction: WCTransaction,
        with account: Account?
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
                account: account,
                asset: asset(from: transaction)
            )
        )

        return cell
    }

    private func dequeueUnsignableCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        for transaction: WCTransaction,
        with account: Account?
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
                account: account,
                asset: asset(from: transaction),
                currency: sharedDataController.currency.value
            )
        )

        return cell
    }

    private func dequeueSingleSignerCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        for transaction: WCTransaction,
        with account: Account?
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
                account: account,
                asset: asset(from: transaction),
                currency: sharedDataController.currency.value
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
}

extension WCMainTransactionDataSource {
    func transactions(at index: Int) -> [WCTransaction]? {
        return groupedTransactions[Int64(index)]
    }

    private func asset(from transaction: WCTransaction) -> Asset? {
        guard let assetId = transaction.transactionDetail?.currentAssetId,
              let assetDecoration = sharedDataController.assetDetailCollection[assetId] else {
            return nil
        }

        if assetDecoration.isCollectible {
            let asset = CollectibleAsset(asset: ALGAsset(id: assetId), decoration: assetDecoration)
            return asset
        }

        let asset = StandardAsset(asset: ALGAsset(id: assetId), decoration: assetDecoration)
        return asset
    }
}

protocol WCMainTransactionDataSourceDelegate: AnyObject {
    func wcMainTransactionDataSourceDidFailedGroupingValidation(_ wcMainTransactionDataSource: WCMainTransactionDataSource)
    func wcMainTransactionDataSourceDidOpenLongDappMessageView(_ wcMainTransactionDataSource: WCMainTransactionDataSource)
}
