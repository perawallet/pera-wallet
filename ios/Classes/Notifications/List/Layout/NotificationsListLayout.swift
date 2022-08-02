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

//   NotificationsListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class NotificationsListLayout: NSObject {

    lazy var handlers = Handlers()

    private let listDataSource: NotificationsDataSource

    init(
        listDataSource: NotificationsDataSource
    ) {
        self.listDataSource = listDataSource

        super.init()
    }
}

extension NotificationsListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return CGSize((collectionView.bounds.width, 0))
        }

        switch itemIdentifier {
        case .loading:
            let width = collectionView.bounds.width - 48
            return CGSize((width, 104))
        case .notification(let viewModel):
            return NotificationCell.calculatePreferredSize(viewModel, with: NotificationViewTheme())
        case .noContent:
            let width = collectionView.bounds.width
            let height =
            collectionView.bounds.height -
            collectionView.contentInset.vertical -
            collectionView.safeAreaTop -
            collectionView.safeAreaBottom
            return CGSize((width, height))
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handlers.didSelectNotificationAt?(indexPath)
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
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .loading:
            let loadingCell = cell as? NotificationLoadingCell
            loadingCell?.stopAnimating()
        default:
            break
        }
    }
}

extension NotificationsListLayout {
    struct Handlers {
        var didSelectNotificationAt: ((IndexPath) -> Void)?
        var willDisplay: ((UICollectionViewCell, IndexPath) -> Void)?
    }
}
