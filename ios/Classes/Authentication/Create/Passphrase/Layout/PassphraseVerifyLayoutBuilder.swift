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
//  PassphraseVerifyLayoutBuilder.swift

import UIKit
import MacaroonUIKit

final class PassphraseVerifyLayoutBuilder: NSObject {
    private let theme: PassphraseVerifyViewController.Theme
    private weak var dataSource: PassphraseVerifyDataSource?

    init(dataSource: PassphraseVerifyDataSource, theme: PassphraseVerifyViewController.Theme) {
        self.dataSource = dataSource
        self.theme = theme
        super.init()
    }
}

extension PassphraseVerifyLayoutBuilder: UICollectionViewDelegateFlowLayout {
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
        return CGSize(theme.headerSize)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(theme.sectionInset)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deselectOtherItemsInSection(of: collectionView, for: indexPath)
        dataSource?.notifyDelegateForSelectedItems(in: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        dataSource?.notifyDelegateForSelectedItems(in: collectionView)
    }
}

extension PassphraseVerifyLayoutBuilder {
    private func deselectOtherItemsInSection(of collectionView: UICollectionView, for indexPath: IndexPath) {
        collectionView.indexPathsForSelectedItems?
            .filter {
                $0.section == indexPath.section && $0.item != indexPath.item
            }
            .forEach {
                collectionView.deselectItem(at: $0, animated: false)
            }
    }
}
