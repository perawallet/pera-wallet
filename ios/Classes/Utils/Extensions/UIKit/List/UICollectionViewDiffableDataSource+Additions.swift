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

//   UICollectionViewDiffableDataSource+Additions.swift

import Foundation
import UIKit

extension UICollectionViewDiffableDataSource {
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>

    func reload(
        _ snapshot: Snapshot,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        if #available(iOS 15, *) {
            applySnapshotUsingReloadData(
                snapshot,
                completion: completion
            )
        } else {
            apply(
                snapshot,
                animatingDifferences: animatingDifferences,
                completion: completion
            )
        }
    }
}

extension NSDiffableDataSourceSnapshot {
    mutating func insertItem(
        _ item: ItemIdentifierType,
        to section: SectionIdentifierType,
        at index: Int
    ) {
        if let itemAtIndex = itemIdentifiers(inSection: section)[safe: index] {
            insertItems(
                [item],
                beforeItem: itemAtIndex
            )
        } else {
            appendItems(
                [item],
                toSection: section
            )
        }
    }
}
