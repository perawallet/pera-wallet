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
    lazy var handlers = Handlers()

    private var sizeCache: [String: CGSize] = [:]

    private let draft: TransactionListing
    private weak var transactionsDataSource: TransactionsDataSource?

    init(draft: TransactionListing, transactionsDataSource: TransactionsDataSource?) {
        self.draft = draft
        self.transactionsDataSource = transactionsDataSource
        super.init()
    }
}

extension TransactionsListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = transactionsDataSource?.itemIdentifier(for: indexPath) else {
            return CGSize((collectionView.bounds.width, 0))
        }

        switch itemIdentifier {
        case .algosInfo(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAlgosDetailInfo: item
            )
        case .assetInfo(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAssetDetailInfo: item
            )
        case .filter:
            return CGSize(theme.transactionHistoryFilterCellSize)
        case .transaction, .pending, .reward:
            return CGSize(theme.transactionHistoryCellSize)
        case .title:
            return CGSize(theme.transactionHistoryTitleCellSize)
        case .empty(let emptyState):
            switch emptyState {
            case .algoTransactionHistoryLoading:
                var theme = AlgoTransactionHistoryLoadingViewCommonTheme()
                theme.buyAlgoVisible = !draft.accountHandle.value.isWatchAccount()
                
                let cellHeight = AlgoTransactionHistoryLoadingCell.height(
                    for: theme
                )
                return CGSize(width: collectionView.bounds.width - 48, height: cellHeight)
            case .assetTransactionHistoryLoading:
                let cellHeight = AssetTransactionHistoryLoadingCell.height(
                    for: AssetTransactionHistoryLoadingViewCommonTheme()
                )
                return CGSize(width: collectionView.bounds.width - 48, height: cellHeight)
            case .transactionHistoryLoading:
                return CGSize(width: collectionView.bounds.width - 48, height: 500)
            default:
                let width = collectionView.bounds.width
                var height = collectionView.bounds.height -
                collectionView.adjustedContentInset.bottom -
                collectionView.contentInset.top -
                theme.transactionHistoryTitleCellSize.h
                if draft.type != .all {
                    let sizeCacheIdentifier = draft.type == .algos ?
                    AlgosDetailInfoViewCell.reuseIdentifier : AssetDetailInfoViewCell.reuseIdentifier
                    let cachedInfoSize = sizeCache[sizeCacheIdentifier]

                    if let cachedInfoSize = cachedInfoSize {
                        height -= cachedInfoSize.height
                    }
                }
                return CGSize((width, height))
            }

        case .nextList:
            return CGSize((collectionView.bounds.width, 100))
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        handlers.willDisplay?(cell, indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = transactionsDataSource?.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .nextList:
            let loadingCell = cell as! LoadingCell
            loadingCell.stopAnimating()
        case .empty(let emptyState):
            switch emptyState {
            case .loading:
                let loadingCell = cell as! LoadingCell
                loadingCell.stopAnimating()
            case .algoTransactionHistoryLoading:
                let loadingCell = cell as! AlgoTransactionHistoryLoadingCell
                loadingCell.stopAnimating()
            case .assetTransactionHistoryLoading:
                let loadingCell = cell as! AssetTransactionHistoryLoadingCell
                loadingCell.stopAnimating()
            case .transactionHistoryLoading:
                let loadingCell = cell as! TransactionHistoryLoadingCell
                loadingCell.stopAnimating()
            default:
                break
            }
        case .pending:
            let pendingTransactionCell = cell as! PendingTransactionCell
            pendingTransactionCell.stopAnimating()
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        handlers.didSelect?(indexPath)
    }
}

extension TransactionsListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAssetDetailInfo item: AssetDetailInfoViewModel
    ) -> CGSize {
        let sizeCacheIdentifier = AssetDetailInfoViewCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let size = AssetDetailInfoViewCell.calculatePreferredSize(
            item,
            for: AssetDetailInfoViewCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = size

        return size
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAlgosDetailInfo item: AlgosDetailInfoViewModel
    ) -> CGSize {
        let sizeCacheIdentifier = AlgosDetailInfoViewCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let size = AlgosDetailInfoViewCell.calculatePreferredSize(
            item,
            for: AlgosDetailInfoViewCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = size

        return size
    }
}

extension TransactionsListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return listView.bounds.width - listView.contentInset.horizontal
    }
}

extension TransactionsListLayout {
    struct Handlers {
        var willDisplay: ((UICollectionViewCell, IndexPath) -> Void)?
        var didSelect: ((IndexPath) -> Void)?
    }
}
