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

//   AccountSelectionListDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol AccountSelectionListDataSource: AnyObject {
    associatedtype SectionIdentifierType: Hashable
    associatedtype ItemIdentifierType: Hashable

    typealias DataSource = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>

    typealias CellProvider = DataSource.CellProvider
    typealias SupplementaryViewProvider = DataSource.SupplementaryViewProvider

    var supportedCells: [UICollectionViewCell.Type] { get }
    func getCellProvider() -> CellProvider

    var supportedSupplementaryViews: [UICollectionReusableView.Type] { get }
    func getSupplementaryViewProvider(_ dataSource: DataSource) -> SupplementaryViewProvider?
}

extension AccountSelectionListDataSource {
    func registerSupportedCells(_ listView: UICollectionView) {
        supportedCells.forEach(listView.register)

    }

    func registerSupportedSupplementaryViews(_ listView: UICollectionView) {
        supportedSupplementaryViews.forEach(listView.register(header:))
    }
}
