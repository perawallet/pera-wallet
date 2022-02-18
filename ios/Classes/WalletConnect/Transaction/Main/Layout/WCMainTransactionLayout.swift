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
//   WCMainTransactionLayout.swift

import UIKit

class WCMainTransactionLayout: NSObject {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: WCMainTransactionLayoutDelegate?

    private weak var dataSource: WCMainTransactionDataSource?

    private let sharedDataController: SharedDataController
    init(
        dataSource: WCMainTransactionDataSource,
        sharedDataController: SharedDataController
    ) {
        self.dataSource = dataSource
        self.sharedDataController = sharedDataController
        super.init()
    }
}

extension WCMainTransactionLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let transactions = dataSource?.transactions(at: indexPath.item) else {
            return .zero
        }

        if transactions.count == 1,
           let transaction = transactions.first {

            let viewModel = WCGroupTransactionItemViewModel(
                transaction: transaction,
                account: transaction.signerAccount,
                assetInformation: assetInformation(from: transaction),
                currency: sharedDataController.currency.value
            )

            return WCGroupTransactionItemViewModel.calculatePreferredSize(
                viewModel,
                fittingIn: CGSize(width: UIScreen.main.bounds.width - 40.0,
                                  height: .greatestFiniteMagnitude)
            )
        }

        return layout.current.multipleTransactionCellSize
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let transactions = dataSource?.transactions(at: indexPath.item) {
            delegate?.wcMainTransactionLayout(self, didSelect: transactions)
        }
    }
}

extension WCMainTransactionLayout {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let multipleTransactionCellSize = CGSize(width: UIScreen.main.bounds.width - 40.0, height: 132.0)
    }

    private func assetInformation(from transaction: WCTransaction) -> AssetInformation? {
        guard let assetId = transaction.transactionDetail?.currentAssetId else {
            return nil
        }

        return sharedDataController.assetDetailCollection[assetId]
    }
}

protocol WCMainTransactionLayoutDelegate: AnyObject {
    func wcMainTransactionLayout(_ wcMainTransactionLayout: WCMainTransactionLayout, didSelect transactions: [WCTransaction])
}
