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

//   InnerTransactionListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class InnerTransactionListLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: InnerTransactionListDataSource

    private let sectionHorizontalInsets: LayoutHorizontalPaddings = (24, 24)

    private let currency: CurrencyProvider
    private let currencyFormatter: CurrencyFormatter

    init(
        listDataSource: InnerTransactionListDataSource,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        self.listDataSource = listDataSource
        self.currency = currency
        self.currencyFormatter = currencyFormatter

        super.init()
    }

    class func build() -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        return flowLayout
    }
}

extension InnerTransactionListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        var insets = UIEdgeInsets(
            (0, sectionHorizontalInsets.leading, 0, sectionHorizontalInsets.trailing)
        )

        switch listSection {
        case .transactions:
            insets.bottom = 8
            return insets
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return CGSize((collectionView.bounds.width, 0))
        }

        switch itemIdentifier {
        case .header(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForHeaderItem: item
            )
        case .algoTransaction,
             .assetTransaction,
             .assetConfigTransaction,
             .appCallTransaction,
             .keyRegTransaction:
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForInnerTransactionItem: CustomInnerTransactionPreviewViewModel(
                    currency: currency,
                    currencyFormatter: currencyFormatter
                )
            )
        }
    }
}

extension InnerTransactionListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForHeaderItem item: InnerTransactionListHeaderViewModel
    ) -> CGSize {
        let sizeCacheIdentifier = InnerTransactionListTitleSupplementaryCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let newSize = InnerTransactionListTitleSupplementaryCell.calculatePreferredSize(
            item,
            for: InnerTransactionListTitleSupplementaryCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForInnerTransactionItem item: InnerTransactionPreviewViewModel?
    ) -> CGSize {
        let sizeCacheIdentifier = InnerTransactionPreviewCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let newSize = InnerTransactionPreviewCell.calculatePreferredSize(
            item,
            for: InnerTransactionPreviewCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension InnerTransactionListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return listView.bounds.width -
        listView.contentInset.horizontal -
        sectionHorizontalInsets.leading -
        sectionHorizontalInsets.trailing
    }
}

extension InnerTransactionListLayout {
    private struct CustomInnerTransactionPreviewViewModel: InnerTransactionPreviewViewModel {
        var title: EditText?
        var amountViewModel: TransactionAmountViewModel?

        init(
            currency: CurrencyProvider,
            currencyFormatter: CurrencyFormatter
        ) {
            self.title = Self.getTitle("Title")
            self.amountViewModel = TransactionAmountViewModel(
                .positive(
                    amount: 100,
                    isAlgos: false,
                    fraction: 2,
                    assetSymbol: nil,
                    currencyValue: nil
                ),
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: false
            )
        }
    }
}
