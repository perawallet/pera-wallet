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

//   DiscoverSearchDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class DiscoverSearchDataSource: UICollectionViewDiffableDataSource<DiscoverSearchListSection, DiscoverSearchListItem> {

    init(
        collectionView: UICollectionView,
        dataController: DiscoverSearchDataController?
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .loading:
                return Self.listView(
                    collectionView,
                    cellForLoadingItemAt: indexPath
                )
            case .notFound:
                return Self.listView(
                    collectionView,
                    cellForNotFoundItemAt: indexPath
                )
            case .error(let errorItem):
                return Self.listView(
                    collectionView,
                    cellForErrorItem: errorItem,
                    at: indexPath
                )
            case .asset(let assetItem):
                let viewModel = dataController?.searchAssetListItemViewModel(for: assetItem.assetID)
                return Self.listView(
                    collectionView,
                    cellForAssetItemWith: viewModel,
                    at: indexPath
                )
            case .nextLoading:
                return Self.listView(
                    collectionView,
                    cellForNextLoadingItemAt: indexPath
                )
            case .nextError(let errorItem):
                return Self.listView(
                    collectionView,
                    cellForNextErrorItem: errorItem,
                    at: indexPath
                )
            }
        }

        prepareForUse(collectionView)
    }
}

extension DiscoverSearchDataSource {
    func isEmpty() -> Bool {
        return snapshot().sectionIdentifiers.contains(.noContent)
    }
}

extension DiscoverSearchDataSource {
    private func prepareForUse(_ listView: UICollectionView) {
        let cells = [
            DiscoverSearchListLoadingCell.self,
            DiscoverSearchListNotFoundCell.self,
            DiscoverErrorCell.self,
            DiscoverSearchAssetCell.self,
            DiscoverSearchNextListLoadingCell.self,
            DiscoverSearchNextListErrorCell.self
        ]
        cells.forEach {
            listView.register($0)
        }
    }
}

extension DiscoverSearchDataSource {
    private static func listView(
        _ listView: UICollectionView,
        cellForLoadingItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        return listView.dequeue(
            DiscoverSearchListLoadingCell.self,
            at: indexPath
        )
    }

    private static func listView(
        _ listView: UICollectionView,
        cellForNotFoundItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let viewModel = DiscoverSearchListNotFoundViewModel()

        let cell = listView.dequeue(
            DiscoverSearchListNotFoundCell.self,
            at: indexPath
        )
        cell.bindData(viewModel)
        return cell
    }

    private static func listView(
        _ listView: UICollectionView,
        cellForErrorItem item: DiscoverSearchErrorItem,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        let viewModel = DiscoverSearchListErrorViewModel(error: item)

        let cell = listView.dequeue(
            DiscoverErrorCell.self,
            at: indexPath
        )
        cell.bindData(viewModel)
        return cell
    }

    private static func listView(
        _ listView: UICollectionView,
        cellForAssetItemWith viewModel: DiscoverSearchAssetListItemViewModel?,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = listView.dequeue(
            DiscoverSearchAssetCell.self,
            at: indexPath
        )
        cell.bindData(viewModel)
        return cell
    }

    private static func listView(
        _ listView: UICollectionView,
        cellForNextLoadingItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        return listView.dequeue(
            DiscoverSearchNextListLoadingCell.self,
            at: indexPath
        )
    }

    private static func listView(
        _ listView: UICollectionView,
        cellForNextErrorItem item: DiscoverSearchErrorItem,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        let viewModel = DiscoverSearchNextListErrorViewModel(error: item)

        let cell = listView.dequeue(
            DiscoverSearchNextListErrorCell.self,
            at: indexPath
        )
        cell.bindData(viewModel)
        return cell
    }
}
