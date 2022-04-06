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

//   TopAlignedCollectionViewFlowLayout.swift

import UIKit

final class TopAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)?.map { attribute in
            attribute.copy()
        } as? [UICollectionViewLayoutAttributes]

        attributes?
            .reduce([CGFloat: (CGFloat, [UICollectionViewLayoutAttributes])]()) { partialResult, layoutAttributes in
                if layoutAttributes.representedElementCategory != .cell {
                    return partialResult
                }

                let dictionaryToMerge = [
                    ceil(layoutAttributes.center.y): (layoutAttributes.frame.origin.y, [layoutAttributes])
                ]

                return partialResult
                    .merging(dictionaryToMerge) { current, new in
                        (min(current.0, new.0), current.1 + new.1)
                    }
            }
            .values
            .forEach { minY, lines in
                lines.forEach { line in
                    line.frame = line.frame.offsetBy(
                        dx: 0,
                        dy: minY - line.frame.origin.y
                    )
                }
            }

        return attributes
    }
}
