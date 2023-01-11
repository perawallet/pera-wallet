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
//  NotificationFilterListLayout.swift

import UIKit
import MacaroonUIKit

final class NotificationFilterListLayout: NSObject {
    private let theme = Theme()

    private weak var dataSource: NotificationFilterDataSource?

    init(dataSource: NotificationFilterDataSource) {
        self.dataSource = dataSource
        super.init()
    }

    class func build() -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        return flowLayout
    }
}

extension NotificationFilterListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.cellSize)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if section == 0 || dataSource?.isEmpty ?? false {
            return .zero
        }

        return CGSize(theme.headerSize)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if let pushNotificationsLoadingCell = cell as? TitledToggleLoadingCell {
            pushNotificationsLoadingCell.startAnimating()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if let pushNotificationsLoadingCell = cell as? TitledToggleLoadingCell {
            pushNotificationsLoadingCell.stopAnimating()
        }
    }
}

extension NotificationFilterListLayout {
    private struct Theme: LayoutSheet, StyleSheet {
        let cellSize: LayoutSize
        let headerSize: LayoutSize

        init(_ family: LayoutFamily) {
            cellSize = (UIScreen.main.bounds.width, 64)
            headerSize = (UIScreen.main.bounds.width, 64)
        }
    }
}
