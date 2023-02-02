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

final class TopAlignedCollectionViewFlowLayout: CollectionViewSwitchableFlowLayout {
    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)?.map { attribute in
            attribute.copy()
        } as? [UICollectionViewLayoutAttributes]
        
        if let attributes = attributes {
            var previousCenterY: CGFloat = 0
            var sameLineElements = [UICollectionViewLayoutAttributes]()
            
            for attribute in attributes where attribute.representedElementCategory == .cell {
                let frame = attribute.frame
                let centerY = frame.midY

                if abs(centerY - previousCenterY) > 1 {
                    previousCenterY = centerY
                    alignToTopForSameLineElements(sameLineElements: sameLineElements)
                    sameLineElements.removeAll()
                }
                sameLineElements.append(attribute)
            }
            
            alignToTopForSameLineElements(sameLineElements: sameLineElements)
            
            return attributes
        }
        
        return attributes
    }

    private func alignToTopForSameLineElements(sameLineElements: [UICollectionViewLayoutAttributes]) {
        if sameLineElements.count < 1 {
            return
        }
        
        let elementsSortedByHeight = sameLineElements.sorted { (
            firstElement: UICollectionViewLayoutAttributes, secondElement: UICollectionViewLayoutAttributes
        ) -> Bool in
            let firstElementHeight = firstElement.frame.size.height
            let secondElementHeight = secondElement.frame.size.height
            
            return (firstElementHeight - secondElementHeight) <= 0
        }
        
        if let tallest = elementsSortedByHeight.last {
            for element in sameLineElements {
                element.frame = element.frame.offsetBy(
                    dx: 0,
                    dy: tallest.frame.origin.y - element.frame.origin.y
                )
            }
        }
    }
}
