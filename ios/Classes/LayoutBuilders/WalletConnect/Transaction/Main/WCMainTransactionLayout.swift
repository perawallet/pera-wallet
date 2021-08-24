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
//   WCMainTransactionLayout.swift

import UIKit

class WCMainTransactionLayout: NSObject {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: WCMainTransactionLayoutDelegate?

    private weak var dataSource: WCMainTransactionDataSource?

    init(dataSource: WCMainTransactionDataSource) {
        self.dataSource = dataSource
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
            if transaction.transactionDetail?.isAppCallTransaction ?? false {
                return layout.current.appCallCellSize
            }

            if transaction.signerAccount == nil {
                return layout.current.anotherAccountCellSize
            }

            return layout.current.singleTransactionCellSize
        }

        return layout.current.multipleTransactionCellSize
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return layout.current.headerSize
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let transactions = dataSource?.transactions(at: indexPath.item) {
            delegate?.wcMainTransactionLayout(self, didSelect: transactions)
        }
    }
}

extension WCMainTransactionLayout {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let singleTransactionCellSize = CGSize(width: UIScreen.main.bounds.width - 40.0, height: 130.0)
        let multipleTransactionCellSize = CGSize(width: UIScreen.main.bounds.width - 40.0, height: 92.0)
        let appCallCellSize = CGSize(width: UIScreen.main.bounds.width - 40.0, height: 68.0)
        let anotherAccountCellSize = CGSize(width: UIScreen.main.bounds.width - 40.0, height: 96.0)
        let headerSize = CGSize(width: UIScreen.main.bounds.width, height: 164.0)
    }
}

protocol WCMainTransactionLayoutDelegate: AnyObject {
    func wcMainTransactionLayout(_ wcMainTransactionLayout: WCMainTransactionLayout, didSelect transactions: [WCTransaction])
}
