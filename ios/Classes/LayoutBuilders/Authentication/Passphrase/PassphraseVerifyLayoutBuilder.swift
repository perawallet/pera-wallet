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
//  PassphraseVerifyLayoutBuilder.swift

import UIKit

class PassphraseVerifyLayoutBuilder: NSObject {

    private let layout = Layout<LayoutConstants>()

    private weak var dataSource: PassphraseVerifyDataSource?

    init(dataSource: PassphraseVerifyDataSource) {
        self.dataSource = dataSource
        super.init()
    }
}

extension PassphraseVerifyLayoutBuilder: UICollectionViewDelegateFlowLayout {
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
        return layout.current.headerSize
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return layout.current.sectionInset
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deselectOtherItemsInSection(of: collectionView, for: indexPath)
        dataSource?.validateSelection(in: collectionView)
    }
}

extension PassphraseVerifyLayoutBuilder {
    private func deselectOtherItemsInSection(of collectionView: UICollectionView, for indexPath: IndexPath) {
        collectionView.indexPathsForSelectedItems?.filter { $0.section == indexPath.section && $0.item != indexPath.item }.forEach {
            collectionView.deselectItem(at: $0, animated: false)
        }
    }
}

extension PassphraseVerifyLayoutBuilder {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let cellSize = CGSize(width: (UIScreen.main.bounds.width - (25 * 2) - (18 * 2)) / 3, height: 44.0)
        let headerSize = CGSize(width: UIScreen.main.bounds.width, height: 36.0)
        let sectionInset = UIEdgeInsets(top: 0.0, left: 24.0, bottom: 40.0, right: 24.0)
    }
}
