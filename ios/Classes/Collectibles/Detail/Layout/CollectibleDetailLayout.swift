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

//   CollectibleDetailLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class CollectibleDetailLayout: NSObject {
    private let theme = Theme()
    
    private let dataSource: CollectibleDetailDataSource

    init(
        dataSource: CollectibleDetailDataSource
    ) {
        self.dataSource = dataSource
        super.init()
    }

    class func build() -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        return flowLayout
    }
}

extension CollectibleDetailLayout {
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
            (0, theme.sectionHorizontalInsets.leading, 0, theme.sectionHorizontalInsets.trailing)
        )

        switch listSection {
        case .loading:
            insets.bottom = 8
            insets.left = 0
            insets.right = 0
            return insets
        case .media:
            insets.top = theme.mediaTopPadding
            insets.bottom = 0
            insets.left = 0
            insets.right = 0
            return insets
        case .action:
            insets.top = 0
            insets.bottom = theme.actionBottomPadding
            return insets
        case .description:
            insets.top = theme.descriptionTopPadding
            insets.bottom = theme.descriptionBottomPadding
            return insets
        case .properties:
            insets.top = theme.propertiesTopPadding
            insets.bottom = theme.propertiesBottomPadding
            return insets
        case .external:
            insets.top = theme.externalTopPadding
            insets.bottom = theme.externalBottomPadding
            return insets
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        let sectionIdentifiers = dataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        switch listSection {
        case .properties:
            return theme.propertiesCellSpacing
        default:
            return 0
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        let sectionIdentifiers = dataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        switch listSection {
        case .properties:
            return theme.propertiesCellSpacing
        default:
            return 0
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
        case .loading:
            return sizeForLoadingItem(
                collectionView,
                layout: collectionViewLayout
            )
        case .media(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForMediaItem: item
            )
        case .error(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForErrorItem: item
            )
        case .action(let item),
                .watchAccountAction(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForActionItem: item
            )
        case .optedInAction(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForOptedInActionItem: item
            )
        case .description(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForDescriptionItem: item
            )
        case .information(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForInformationItem: item
            )
        case .properties(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForPropertyItem: item
            )
        case .external(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForExternalSourceItem: item
            )
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let sectionIdentifiers = dataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        switch listSection {
        case .media,
                .action,
                .loading:
            return .zero
        case .description,
                .properties,
                .external:
            let width = calculateContentWidth(collectionView)
            return CGSize((width, theme.headerHeight))
        }
    }
}

extension CollectibleDetailLayout {
    private func sizeForLoadingItem(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout
    ) -> CGSize {
        let width = listView.bounds.width
        let height =
        listView.bounds.height -
        listView.safeAreaTop -
        listView.safeAreaBottom
        return CGSize((width, height))
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForMediaItem item: CollectibleAsset
    ) -> CGSize {
        let width = listView.bounds.width
        return CGSize(width: width.float(), height: width.float() - theme.mediaInset * 2)
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForErrorItem item: CollectibleMediaErrorViewModel
    ) -> CGSize {
        let width = calculateContentWidth(listView)

        return CollectibleMediaErrorCell.calculatePreferredSize(
            item,
            for: CollectibleMediaErrorCell.theme,
            fittingIn: CGSize(width: width.float(), height: .greatestFiniteMagnitude)
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForActionItem item: CollectibleDetailActionViewModel
    ) -> CGSize {
        let width = calculateContentWidth(listView)

        return CollectibleDetailActionCell.calculatePreferredSize(
            item,
            for: CollectibleDetailActionCell.theme,
            fittingIn: CGSize(width: width.float(), height: .greatestFiniteMagnitude)
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForOptedInActionItem item: CollectibleDetailOptedInActionViewModel
    ) -> CGSize {
        let width = calculateContentWidth(listView)

        return CollectibleDetailOptedInActionCell.calculatePreferredSize(
            item,
            for: CollectibleDetailOptedInActionCell.theme,
            fittingIn: CGSize(width: width.float(), height: .greatestFiniteMagnitude)
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForDescriptionItem item: CollectibleDescriptionViewModel
    ) -> CGSize {
        let width = calculateContentWidth(listView)

        return CollectibleDescriptionCell.calculatePreferredSize(
            item,
            for: CollectibleDescriptionCell.theme,
            fittingIn: CGSize(width: width.float(), height: .greatestFiniteMagnitude)
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForInformationItem item: CollectibleTransactionInformation
    ) -> CGSize {
        let width = calculateContentWidth(listView)

        return CollectibleDetailInformationCell.calculatePreferredSize(
            CollectibleTransactionInfoViewModel(item),
            for: CollectibleDetailInformationCell.theme,
            fittingIn: CGSize(width: width.float(), height: .greatestFiniteMagnitude)
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForPropertyItem item: CollectiblePropertyViewModel
    ) -> CGSize {
        return CollectiblePropertyCell.calculatePreferredSize(
            item,
            for: CollectiblePropertyCell.theme,
            fittingIn: CGSize(width: CGFloat.greatestFiniteMagnitude, height: theme.propertyHeight)
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForExternalSourceItem item: CollectibleExternalSourceViewModel
    ) -> CGSize {
        let width = calculateContentWidth(listView)

        return CollectibleExternalSourceCell.calculatePreferredSize(
            item,
            for: CollectibleExternalSourceCell.theme,
            fittingIn: CGSize(width: width.float(), height: .greatestFiniteMagnitude)
        )
    }
}

extension CollectibleDetailLayout {
    private func calculateContentWidth(
        _ listView: UICollectionView
    ) -> LayoutMetric {
        return
            listView.bounds.width -
            listView.contentInset.horizontal -
            theme.sectionHorizontalInsets.leading -
            theme.sectionHorizontalInsets.trailing
    }
}
