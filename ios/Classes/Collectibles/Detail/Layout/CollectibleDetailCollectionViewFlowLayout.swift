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

//   CollectibleDetailCollectionViewFlowLayout.swift

import UIKit

final class CollectibleDetailCollectionViewFlowLayout: UICollectionViewFlowLayout {
    typealias SectionIdentifierProvider = (Int) -> CollectibleDetailSection?
    var sectionIdentifierProvider: SectionIdentifierProvider?

    private let theme: CollectibleDetailLayout.Theme

    init(
        _ theme: CollectibleDetailLayout.Theme
    ) {
        self.theme = theme
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)?.map { attribute in
            attribute.copy()
        } as? [UICollectionViewLayoutAttributes]

        /// <note> Filter attributes to compute only cell attributes & properties section
        let propertiesAttributes = attributes?.filter {
            let section = $0.indexPath.section
            let sectionIdentifier = sectionIdentifierProvider?(section)
            return sectionIdentifier == .properties && $0.representedElementCategory == .cell
        }

        guard let propertiesAttributes = propertiesAttributes,
              !propertiesAttributes.isEmpty else {
            return super.layoutAttributesForElements(in: rect)
        }

        /// <note> Group cell attributes by row (cells with same vertical center) and loop on those groups
        Dictionary(
            grouping: propertiesAttributes,
            by: { attributes in
                (attributes.center.y / 10).rounded(.up) * 10
            }
        )
        .values
        .forEach { attributes in
            /// <note> Set the initial left inset
            var leftInset =  theme.sectionHorizontalInsets.leading

            /// <note> Loop on cells to adjust each cell's origin and prepare leftInset for the next cell
            attributes.forEach { attribute in
                attribute.frame.origin.x = leftInset
                leftInset = attribute.frame.maxX + theme.propertiesCellSpacing
            }
        }

        return attributes
    }
}
