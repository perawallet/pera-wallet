// Copyright 2019 Algorand, Inc.

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

class NotificationFilterListLayout: NSObject {

    private let layout = Layout<LayoutConstants>()

    private weak var dataSource: NotificationFilterDataSource?

    init(dataSource: NotificationFilterDataSource) {
        self.dataSource = dataSource
        super.init()
    }
}

extension NotificationFilterListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return layout.current.cellSize
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if section == 0 || dataSource?.isEmpty ?? false {
            return .zero
        }

        return layout.current.headerSize
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        if section == 0 {
            return layout.current.sectionInset
        }
        
        return .zero
    }
}

extension NotificationFilterListLayout {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let cellSize = CGSize(width: UIScreen.main.bounds.width, height: 72.0)
        let headerSize = CGSize(width: UIScreen.main.bounds.width, height: 60.0)
        let sectionInset = UIEdgeInsets(top: 12.0, left: 0, bottom: 0, right: 0)
    }
}
