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
    private static let theme = Theme()
    
    private let dataSource: CollectibleDetailDataSource
    private let collectibleDescriptionProvider: () -> CollectibleDescriptionViewModel?

    init(
        dataSource: CollectibleDetailDataSource,
        collectibleDescriptionProvider: @escaping () -> CollectibleDescriptionViewModel?
    ) {
        self.dataSource = dataSource
        self.collectibleDescriptionProvider = collectibleDescriptionProvider
        super.init()
    }

    class func build() -> CollectibleDetailCollectionViewFlowLayout {
        let flowLayout = CollectibleDetailCollectionViewFlowLayout(Self.theme)
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
            (0, Self.theme.sectionHorizontalInsets.leading, 0, Self.theme.sectionHorizontalInsets.trailing)
        )

        switch listSection {
        case .loading:
            insets.left = 0
            insets.right = 0
            return insets
        case .name:
            insets.top = Self.theme.nameTopPadding
            insets.left = 0
            insets.right = 0
            return insets
        case .accountInformation:
            insets.top = Self.theme.accountInformationTopPadding
            insets.left = 0
            insets.right = 0
            return insets
        case .media:
            insets.top = Self.theme.mediaTopPadding
            insets.bottom = Self.theme.mediaBottomPadding
            insets.left = 0
            insets.right = 0
            return insets
        case .action:
            insets.top = 0
            insets.bottom = Self.theme.actionBottomPadding
            return insets
        case .description:
            insets.top = Self.theme.descriptionTopPadding
            insets.bottom = Self.theme.descriptionBottomPadding
            return insets
        case .properties:
            insets.top = Self.theme.propertiesTopPadding
            insets.bottom = Self.theme.propertiesBottomPadding
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
            return Self.theme.propertiesCellSpacing
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
            return Self.theme.propertiesCellSpacing
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
        case .name(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForNameItem: item
            )
        case .accountInformation(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAccountInformationItem: item
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
        case .sendAction:
            return sizeForSendActionItem(
                collectionView,
                layout: collectionViewLayout
            )
        case .optOutAction:
            return sizeForOptedInActionItem(
                collectionView,
                layout: collectionViewLayout
            )
        case .description:
            let descriptionItem = collectibleDescriptionProvider()
            if let descriptionItem {
                return listView(
                    collectionView,
                    layout: collectionViewLayout,
                    sizeForDescriptionItem: descriptionItem
                )
            }
            return .zero
        case .information(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForInformationItem: item
            )
        case .creatorAccount(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForCreatorAccountItem: item
            )
        case .assetID(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAssetIDItem: item
            )
        case .properties(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForPropertyItem: item
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
        case .name,
             .accountInformation,
             .media,
             .action,
             .loading:
            return .zero
        case .description,
             .properties:
            let width = calculateContentWidth(collectionView)
            return CGSize((width, Self.theme.headerHeight))
        }
    }
}

extension CollectibleDetailLayout {
    private func sizeForLoadingItem(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout
    ) -> CGSize {
        let width = listView.bounds.width

        return CollectibleDetailLoadingView.calculatePreferredSize(
            for: CollectibleDetailLoadingView.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForNameItem item: CollectibleDetailNameItemIdentifier
    ) -> CGSize {
        let width = calculateContentWidth(listView)

        return CollectibleDetailNameCell.calculatePreferredSize(
            item.viewModel,
            for: CollectibleDetailNameCell.theme,
            fittingIn:  CGSize((width, .greatestFiniteMagnitude))
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountInformationItem item: CollectibleDetailAccountInformationItemIdentifier
    ) -> CGSize {
        let width = calculateContentWidth(listView)

        return CollectibleDetailAccountInformationCell.calculatePreferredSize(
            item.viewModel,
            for: CollectibleDetailAccountInformationCell.theme,
            fittingIn:  CGSize((width, .greatestFiniteMagnitude))
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForMediaItem item: CollectibleAsset
    ) -> CGSize {
        let width = listView.bounds.width

        return CollectibleMediaPreviewViewController.calculatePreferredSize(
            item,
            fittingIn: CGSize((width.float(), .greatestFiniteMagnitude))
        )
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

    private func sizeForSendActionItem(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout
    ) -> CGSize {
        let width = calculateContentWidth(listView)

        return CollectibleDetailSendActionCell.calculatePreferredSize(
            for: CollectibleDetailSendActionCell.theme,
            fittingIn: CGSize(width: width.float(), height: .greatestFiniteMagnitude)
        )
    }

    private func sizeForOptedInActionItem(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout
    ) -> CGSize {
        let width = calculateContentWidth(listView)

        return CollectibleDetailOptOutActionCell.calculatePreferredSize(
            for: CollectibleDetailOptOutActionCell.theme,
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
        sizeForCreatorAccountItem item: CollectibleDetailCreatorAccountItemIdentifier
    ) -> CGSize {
        let width = calculateContentWidth(listView)

        return CollectibleDetailCreatorAccountItemCell.calculatePreferredSize(
            item.viewModel,
            for: CollectibleDetailCreatorAccountItemCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAssetIDItem item: CollectibleDetailAssetIDItemIdentifier
    ) -> CGSize {
        let width = calculateContentWidth(listView)

        return CollectibleDetailAssetIDItemCell.calculatePreferredSize(
            item.viewModel,
            for: CollectibleDetailAssetIDItemCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForPropertyItem item: CollectiblePropertyViewModel
    ) -> CGSize {
        let width = calculateContentWidth(listView)
        return CollectiblePropertyCell.calculatePreferredSize(
            item,
            for: CollectiblePropertyCell.theme,
            fittingIn: CGSize((width, Self.theme.propertyHeight))
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
            Self.theme.sectionHorizontalInsets.leading -
            Self.theme.sectionHorizontalInsets.trailing
    }
}
