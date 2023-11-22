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
//   WCGroupTransactionLayout.swift

import UIKit

final class WCGroupTransactionLayout: NSObject {
    private let layout = Layout<LayoutConstants>()

    weak var delegate: WCGroupTransactionLayoutDelegate?

    private weak var dataSource: WCGroupTransactionDataSource?

    private let sharedDataController: SharedDataController
    private let currencyFormatter: CurrencyFormatter

    init(
        dataSource: WCGroupTransactionDataSource,
        sharedDataController: SharedDataController,
        currencyFormatter: CurrencyFormatter
    ) {
        self.dataSource = dataSource
        self.sharedDataController = sharedDataController
        self.currencyFormatter = currencyFormatter

        super.init()
    }
}

extension WCGroupTransactionLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let transaction = dataSource?.transaction(at: indexPath.item) else {
            return .zero
        }

        let viewModel = WCGroupTransactionItemViewModel(
            transaction: transaction,
            account: transaction.requestedSigner.account,
            asset: asset(from: transaction),
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
        
        return WCGroupTransactionItemViewModel.calculatePreferredSize(
            viewModel,
            fittingIn: CGSize(width: UIScreen.main.bounds.width - 40.0,
                              height: .greatestFiniteMagnitude)
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 28,
            left: 0,
            bottom: 8,
            right: 0
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return layout.current.headerSize
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let transaction = dataSource?.transaction(at: indexPath.item) {
            delegate?.wcGroupTransactionLayout(self, didSelect: transaction)
        }
    }
}

extension WCGroupTransactionLayout {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let headerSize = CGSize(width: UIScreen.main.bounds.width, height: 100.0)
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

protocol WCGroupTransactionLayoutDelegate: AnyObject {
    func wcGroupTransactionLayout(_ wcGroupTransactionLayout: WCGroupTransactionLayout, didSelect transaction: WCTransaction)
}
