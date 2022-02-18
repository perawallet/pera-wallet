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
//   AssetSearchListLayout.swift

import Foundation
import UIKit

final class AssetSearchListLayout: NSObject {
    private lazy var theme = Theme()
    lazy var handlers = Handlers()

    private let dataController: AssetSearchDataController

    init(dataController: AssetSearchDataController) {
        self.dataController = dataController
    }
}

extension AssetSearchListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.assetItemSize)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard dataController.hasSection() else {
            return .zero
        }

        return CGSize(theme.listHeaderSize)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = AssetSearchSection(rawValue: indexPath.section),
              section == .assets else {
            return
        }

        handlers.didSelectIndex?(indexPath.item)
    }
}

extension AssetSearchListLayout {
    struct Handlers {
        var didSelectIndex: ((Int) -> Void)?
    }
}
