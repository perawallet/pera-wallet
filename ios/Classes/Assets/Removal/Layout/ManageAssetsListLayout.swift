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

//   ManageAssetsListLayout.swift

import Foundation
import UIKit
import MacaroonUIKit

final class ManageAssetsListLayout: NSObject {
    private lazy var theme = Theme()
    
    lazy var handlers = Handlers()
    
    private let dataSource: ManageAssetsListDataSource
    
    private var sizeCache: [String: CGSize] = [:]
    
    init(
        _ dataSource: ManageAssetsListDataSource
    ) {
        self.dataSource = dataSource
    }
}

extension ManageAssetsListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            insetForSectionAt section: Int
        ) -> UIEdgeInsets {
            let sectionIdentifiers = dataSource.snapshot().sectionIdentifiers

            guard let listSection = sectionIdentifiers[safe: section] else {
                return .zero
            }

            var insets =
            UIEdgeInsets(
                (0, theme.horizontalPaddings.leading, 0, theme.horizontalPaddings.trailing)
            )

            switch listSection {
            case .empty:
                return insets
            case .assets:
                insets.top = theme.topContentInset
                return insets
            }
        }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return CGSize((collectionView.bounds.width, 0))
        }
        
        switch itemIdentifier {
        case .asset(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAssetCellItem: item
            )
        case .empty(let item):
            return sizeForNoContent(
                collectionView,
                item: item
            )
        }
    }
    
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAssetCellItem item: AssetPreviewViewModel?
    ) -> CGSize {
        let sizeCacheIdentifier = AssetPreviewDeleteCell.reuseIdentifier
        
        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }
        
        let width = calculateContentWidth(for: listView)
        
        let sampleAssetPreview = AssetPreviewModel(
            icon: .algo,
            verifiedIcon: img("icon-verified-shield"),
            title: "title-unknown".localized,
            subtitle: "title-unknown".localized,
            primaryAccessory: "title-unknown".localized,
            secondaryAccessory: "title-unkown".localized
        )
        
        let sampleAssetItem = AssetPreviewViewModel(sampleAssetPreview)
        
        let newSize = AssetPreviewDeleteCell.calculatePreferredSize(
            sampleAssetItem,
            for: AssetPreviewDeleteCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
        
        sizeCache[sizeCacheIdentifier] = newSize
        
        return newSize
    }
    
    private func sizeForNoContent(
        _ listView: UICollectionView,
        item: AssetListSearchNoContentViewModel
    ) -> CGSize {
        let width = calculateContentWidth(for: listView)
        
        let newSize = NoContentCell.calculatePreferredSize(
            item,
            for: NoContentCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
        
        return newSize
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        handlers.willDisplay?(cell, indexPath)
    }
}

extension ManageAssetsListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return listView.bounds.width -
        listView.contentInset.horizontal -
        theme.horizontalPaddings.leading -
        theme.horizontalPaddings.trailing
    }
}

extension ManageAssetsListLayout {
    struct Handlers {
        var willDisplay: ((UICollectionViewCell, IndexPath) -> Void)?
    }
}
