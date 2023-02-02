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

//   CollectibleDescriptionCell.swift

import Foundation
import MacaroonUIKit
import UIKit

final class CollectibleDescriptionCell:
    CollectionCell<CollectibleDescriptionView>,
    ViewModelBindable {
    weak var delegate: CollectibleDescriptionCellDelegate?

    override class var contextPaddings: LayoutPaddings {
        return theme.contextPaddings
    }

    static let theme = CollectibleDescriptionCellTheme()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contextView.customize(Self.theme.context)
        contextView.delegate = self
    }
}

extension CollectibleDescriptionCell: CollectibleDescriptionViewDelegate {
    func collectibleDescriptionViewDidTapURL(_ view: CollectibleDescriptionView, url: URL) {
        delegate?.collectibleDescriptionCellDidTapURL(self, url: url)
    }

    func collectibleDescriptionViewDidShowMore(_ view: CollectibleDescriptionView) {
        delegate?.collectibleDescriptionCellDidShowMore(self)
    }

    func collectibleDescriptionViewDidShowLess(_ view: CollectibleDescriptionView) {
        delegate?.collectibleDescriptionCellDidShowLess(self)
    }
}

protocol CollectibleDescriptionCellDelegate: AnyObject {
    func collectibleDescriptionCellDidTapURL(_ cell: CollectibleDescriptionCell, url: URL)
    func collectibleDescriptionCellDidShowMore(_ cell: CollectibleDescriptionCell)
    func collectibleDescriptionCellDidShowLess(_ cell: CollectibleDescriptionCell)
}
