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
//   WCGroupTransactionLayout.swift

import UIKit

class WCGroupTransactionLayout: NSObject {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: WCGroupTransactionLayoutDelegate?

    private weak var dataSource: WCGroupTransactionDataSource?

    init(dataSource: WCGroupTransactionDataSource) {
        self.dataSource = dataSource
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

        if transaction.transactionDetail?.isAppCallTransaction ?? false {
            return layout.current.appCallCellSize
        }

        if transaction.signerAccount == nil {
            return layout.current.anotherAccountCellSize
        }

        return layout.current.cellSize
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
        let appCallCellSize = CGSize(width: UIScreen.main.bounds.width - 40.0, height: 68.0)
        let anotherAccountCellSize = CGSize(width: UIScreen.main.bounds.width - 40.0, height: 96.0)
        let cellSize = CGSize(width: UIScreen.main.bounds.width - 40.0, height: 130.0)
        let headerSize = CGSize(width: UIScreen.main.bounds.width, height: 56.0)
    }
}

protocol WCGroupTransactionLayoutDelegate: AnyObject {
    func wcGroupTransactionLayout(_ wcGroupTransactionLayout: WCGroupTransactionLayout, didSelect transaction: WCTransaction)
}
