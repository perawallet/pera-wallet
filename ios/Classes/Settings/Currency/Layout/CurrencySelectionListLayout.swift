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

//   CurrencySelectionListLayout.swift

import Foundation
import UIKit
import MacaroonUIKit

final class CurrencySelectionListLayout: NSObject {
    private lazy var theme = Theme()
    
    lazy var handlers = Handlers()
    
    private let dataSource: CurrencySelectionListDataSource
    
    init(
        _ dataSource: CurrencySelectionListDataSource
    ) {
        self.dataSource = dataSource
    }
}

extension CurrencySelectionListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return CGSize((collectionView.bounds.width, 0))
        }
        
        switch itemIdentifier {
        case .currency:
            return CGSize(theme.cellSize)
        case .error:
            let width = calculateContentWidth(for: collectionView)

            let height =
            collectionView.bounds.height -
            collectionView.safeAreaTop -
            collectionView.safeAreaBottom
            
            return CGSize((width, height))
        case .empty(let item):
            switch item {
            case let .noContent(noContentItem):
                let width = calculateContentWidth(for: collectionView)

                let newSize = NoContentCell.calculatePreferredSize(
                    noContentItem,
                    for: NoContentCell.theme,
                    fittingIn: CGSize((width, .greatestFiniteMagnitude))
                )

                return newSize
            case .loading:
                let width = calculateContentWidth(for: collectionView)

                let newSize = CurrencySelectionLoadingView.calculatePreferredSize(
                    for: CurrencySelectionLoadingViewTheme(),
                    fittingIn: CGSize((width, .greatestFiniteMagnitude))
                )

                return newSize
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch itemIdentifier {
        case .error:
            handlers.didTapReload?(cell)
        case let .empty(item):
            switch item {
            case .loading:
                if let loadingCell = cell as? CurrencySelectionLoadingViewCell {
                    loadingCell.startAnimating()
                    return
                }
            default:
                return
            }
        default:
            return
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if let loadingCell = cell as? CurrencySelectionLoadingViewCell {
            loadingCell.stopAnimating()
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch itemIdentifier {
        case .currency:
            handlers.didSelectCurrency?(indexPath)
        default:
            return
        }
    }
}

extension CurrencySelectionListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return listView.bounds.width -
        listView.contentInset.horizontal -
        theme.horizontalPaddings.leading -
        theme.horizontalPaddings.trailing
    }
}

extension CurrencySelectionListLayout {
    struct Handlers {
        var didSelectCurrency: ((IndexPath) -> Void)?
        var didTapReload: ((UICollectionViewCell) -> Void)?
    }
}
