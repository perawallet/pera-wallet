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

//   CollectionViewSwitchableFlowLayout.swift

import Foundation
import UIKit

class CollectionViewSwitchableFlowLayout: UICollectionViewFlowLayout {
    /// <note>
    /// Dynamically setting layout on UICollectionView causes inexplicable contentOffset change
    /// <src>
    /// https://stackoverflow.com/questions/13780138/dynamically-setting-layout-on-uicollectionview-causes-inexplicable-contentoffset
    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint
    ) -> CGPoint {
        guard let collectionView else {
            return proposedContentOffset
        }

        let currentContentOffset = collectionView.contentOffset
        let shouldPreventUnintentionalJumping = currentContentOffset.y < proposedContentOffset.y
        return shouldPreventUnintentionalJumping ? currentContentOffset : proposedContentOffset
    }
}
