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
//  LedgerAccountSelectionListLayout.swift

import UIKit

class LedgerAccountSelectionListLayout: NSObject {
    
    weak var delegate: LedgerAccountSelectionListLayoutDelegate?
    
    private weak var dataSource: LedgerAccountSelectionDataSource?
    private let isMultiSelect: Bool
    
    init(dataSource: LedgerAccountSelectionDataSource, isMultiSelect: Bool) {
        self.dataSource = dataSource
        self.isMultiSelect = isMultiSelect
        super.init()
    }
}

extension LedgerAccountSelectionListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        var height: CGFloat = 0.0
        let headerHeight: CGFloat = 64.0
        let algosHeight: CGFloat = 52.0
        let assetCountHeight: CGFloat = 44.0
        height += headerHeight + algosHeight
        
        if let account = dataSource?.account(at: indexPath.item),
           !account.assets.isNilOrEmpty {
            height += assetCountHeight
        }
        
        return CGSize(width: UIScreen.main.bounds.width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return LedgerAccountSelectionHeaderSupplementaryView.calculatePreferredSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.ledgerAccountSelectionListLayout(self, didSelectItemAt: indexPath)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? LedgerAccountCell,
              let account = dataSource?.account(at: indexPath.item) else {
            return
        }
        
        cell.contextView.state = .selected
        cell.bind(LedgerAccountNameViewModel(account: account, isMultiSelect: isMultiSelect, isSelected: true))
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        delegate?.ledgerAccountSelectionListLayout(self, didDeselectItemAt: indexPath)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? LedgerAccountCell,
              let account = dataSource?.account(at: indexPath.item) else {
            return
        }
        
        cell.contextView.state = .unselected
        cell.bind(LedgerAccountNameViewModel(account: account, isMultiSelect: isMultiSelect, isSelected: false))
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
