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
//  LedgerAccountSelectionListLayout.swift

import UIKit

final class LedgerAccountSelectionListLayout: NSObject {
    weak var delegate: LedgerAccountSelectionListLayoutDelegate?
    
    private weak var dataSource: LedgerAccountSelectionDataSource?
    private let theme: LedgerAccountSelectionViewController.Theme

    init(theme: LedgerAccountSelectionViewController.Theme, dataSource: LedgerAccountSelectionDataSource) {
        self.dataSource = dataSource
        self.theme = theme
        super.init()
    }
}

extension LedgerAccountSelectionListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return  CGSize(theme.cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.ledgerAccountSelectionListLayout(self, didSelectItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        delegate?.ledgerAccountSelectionListLayout(self, didDeselectItemAt: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
            collectionView.deselectItem(at: indexPath, animated: false)
            collectionView.delegate?.collectionView?(collectionView, didDeselectItemAt: indexPath)
            return false
        }
        return true
    }
}

protocol LedgerAccountSelectionListLayoutDelegate: AnyObject {
    func ledgerAccountSelectionListLayout(
        _ ledgerAccountSelectionListLayout: LedgerAccountSelectionListLayout,
        didSelectItemAt indexPath: IndexPath
    )
    func ledgerAccountSelectionListLayout(
        _ ledgerAccountSelectionListLayout: LedgerAccountSelectionListLayout,
        didDeselectItemAt indexPath: IndexPath
    )
}
