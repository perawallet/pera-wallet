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
//   TransactionsListLayout.swift

import UIKit
import MacaroonUIKit

final class TransactionsListLayout: NSObject {
    private lazy var theme = Theme()

    private var sizeCache: [String: CGSize] = [:]

    private let draft: TransactionListing
    private weak var transactionsDataSource: TransactionsDataSource?

    init(draft: TransactionListing, transactionsDataSource: TransactionsDataSource?) {
        self.draft = draft
        self.transactionsDataSource = transactionsDataSource
        super.init()
    }
}

extension TransactionsListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = transactionsDataSource?.itemIdentifier(for: indexPath) else {
            return CGSize((collectionView.bounds.width, 0))
        }

        func cellSize() -> CGSize {
            switch itemIdentifier {
            case .filter:
                return CGSize(theme.transactionHistoryFilterCellSize)
            case .algoTransaction,
                 .assetTransaction,
                 .appCallTransaction,
                 .keyRegTransaction,
                 .assetConfigTransaction,
                 .pendingTransaction:
                return CGSize(theme.transactionHistoryCellSize)
            case .title:
                return CGSize(theme.transactionHistoryTitleCellSize)
            case .empty(let emptyState):
                switch emptyState {
                case .transactionHistoryLoading:
                    return CGSize(width: collectionView.bounds.width - 48, height: 500)
                case .noContent:
                    return listView(
                        collectionView,
                        layout: collectionViewLayout,
                        sizeForNoContent: TransactionHistoryNoContentViewModel()
                    )
                }
            case .nextList:
                return CGSize((collectionView.bounds.width, 100))
            }
        }

        return cellSize().nonNegativeSize
    }
}

extension TransactionsListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForNoContent item: TransactionHistoryNoContentViewModel
    ) -> CGSize {
        let calculatedNoContentSize = calculateSizeWithNoContentCell(
            listView,
            item
        )

        let calculatedSpaceSize = calculateSizeWithAvailableSpace(listView)

        let preferredSize = calculatedNoContentSize.height > calculatedSpaceSize.height
            ? calculatedNoContentSize
            : calculatedSpaceSize

        return preferredSize
    }

    private func calculateSizeWithNoContentCell(
        _ listView: UICollectionView,
        _ item: TransactionHistoryNoContentViewModel
    ) -> CGSize {

        let noContentType = transactionsDataSource?.noContentType ?? .centered

        switch noContentType {
        case .topAligned:
            return NoContentTopAlignedCell.calculatePreferredSize(
                item,
                for: NoContentTopAlignedCell.theme,
                fittingIn: CGSize((
                    listView.bounds.width,
                    .greatestFiniteMagnitude
                ))
            )
        case .centered:
            return NoContentCell.calculatePreferredSize(
                item,
                for: NoContentCell.theme,
                fittingIn: CGSize((
                    listView.bounds.width,
                    .greatestFiniteMagnitude
                ))
            )
        }
    }

    private func calculateSizeWithAvailableSpace(
        _ listView: UICollectionView
    ) -> CGSize {
        let calculatedSpaceHeight = listView.bounds.height -
        listView.adjustedContentInset.bottom -
        listView.contentInset.top -
        theme.transactionHistoryTitleCellSize.h
        return CGSize((
            listView.bounds.width,
            calculatedSpaceHeight
        ))
    }
}

extension TransactionsListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return listView.bounds.width - listView.contentInset.horizontal
    }
}
