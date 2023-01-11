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

//   WCConnectionAccountListLayout.swift

import UIKit

final class WCConnectionAccountListLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]
    
    private let listDataSource: WCConnectionAccountListDataSource
    
    init(listDataSource: WCConnectionAccountListDataSource) {
        self.listDataSource = listDataSource
        super.init()
    }
}

extension WCConnectionAccountListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let sizeCacheIdentifier = ExportAccountListAccountCell.reuseIdentifier
        
        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }
        
        let width = collectionView.bounds.width
        let exampleAccountListItem = CustomAccountListItem(
            address: "someAlgorandAddress",
            icon: "icon-standard-account".uiImage,
            title: "title-unknown".localized,
            subtitle: "title-plus-asset-singular-count".localized(params: "1")
        )
        
        let exampleAccountItem = AccountListItemViewModel(exampleAccountListItem)
        let newSize = ExportAccountListAccountCell.calculatePreferredSize(
            exampleAccountItem,
            for: ExportAccountListAccountCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}
