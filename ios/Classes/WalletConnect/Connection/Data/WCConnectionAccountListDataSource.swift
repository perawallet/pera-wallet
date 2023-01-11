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

//   WCConnectionAccountListDataSource.swift

import UIKit

final class WCConnectionAccountListDataSource:
    UICollectionViewDiffableDataSource<WCConnectionAccountListSectionIdentifier, WCConnectionAccountListItemIdentifier> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<WCConnectionAccountListSectionIdentifier, WCConnectionAccountListItemIdentifier>
    
    init(_ collectionView: UICollectionView) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .account(let item):
                let cell = collectionView.dequeue(
                    ExportAccountListAccountCell.self,
                    at: indexPath
                )
                cell.bindData(item.viewModel)
                return cell
            }
        }
        
        collectionView.register(ExportAccountListAccountCell.self)
    }
}
