// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCMainArbitraryDataLayout.swift

import UIKit

final class WCMainArbitraryDataLayout: NSObject {
    weak var delegate: WCMainArbitraryDataLayoutDelegate?

    private weak var dataSource: WCMainArbitraryDataDataSource?

    private let sharedDataController: SharedDataController
    private let currencyFormatter: CurrencyFormatter

    init(
        dataSource: WCMainArbitraryDataDataSource,
        sharedDataController: SharedDataController,
        currencyFormatter: CurrencyFormatter
    ) {
        self.dataSource = dataSource
        self.sharedDataController = sharedDataController
        self.currencyFormatter = currencyFormatter

        super.init()
    }
}

extension WCMainArbitraryDataLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let data = dataSource?.data(at: indexPath.item) else {
            return .zero
        }

        let viewModel = WCGroupTransactionItemViewModel(
            account: data.requestedSigner.account,
            currencyFormatter: currencyFormatter
        )
        let size = CGSize(
            width: UIScreen.main.bounds.width - 40.0,
            height: .greatestFiniteMagnitude
        )
        return WCGroupTransactionItemViewModel.calculatePreferredSize(
            viewModel,
            fittingIn: size
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let data = dataSource?.data(at: indexPath.item) else {
            return
        }

        delegate?.wcMainArbitraryDataLayout(self, didSelect: data)
    }
}

protocol WCMainArbitraryDataLayoutDelegate: AnyObject {
    func wcMainArbitraryDataLayout(
        _ wcMainArbitraryDataLayout: WCMainArbitraryDataLayout,
        didSelect data: WCArbitraryData
    )
}
