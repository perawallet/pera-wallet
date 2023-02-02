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

//   CollectibleGalleryUIActionsCell.swift

import UIKit
import MacaroonUIKit

final class CollectibleGalleryUIActionsCell: CollectionCell<CollectibleGalleryUIActionsView> {
    weak var delegate: CollectibleGalleryUIActionsCellDelegate?

    static let theme = CollectibleGalleryUIActionsViewTheme()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contextView.customize(Self.theme)

        contextView.delegate = self
    }

    static func calculatePreferredSize(
        for theme: CollectibleGalleryUIActionsViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        return ContextView.calculatePreferredSize(
            for: theme,
            fittingIn: size
        )
    }
}

extension CollectibleGalleryUIActionsCell {
    func beginEditing() {
        contextView.beginEditing()
    }

    func endEditing() {
        contextView.endEditing()
    }
}

extension CollectibleGalleryUIActionsCell {
    func setGridUIStyleSelected() {
        contextView.setGridUIStyleSelected()
    }

    func setListUIStyleSelected() {
        contextView.setListUIStyleSelected()
    }
}

extension CollectibleGalleryUIActionsCell: CollectibleGalleryUIActionsViewDelegate {
    func collectibleGalleryUIActionsViewDidSelectGridUIStyle(_ view: CollectibleGalleryUIActionsView) {
        delegate?.collectibleGalleryUIActionsViewDidSelectGridUIStyle(self)
    }

    func collectibleGalleryUIActionsViewDidSelectListUIStyle(_ view: CollectibleGalleryUIActionsView) {
        delegate?.collectibleGalleryUIActionsViewDidSelectListUIStyle(self)
    }

    func collectibleGalleryUIActionsViewDidEditSearchInput(_ view: CollectibleGalleryUIActionsView, input: String?) {
        delegate?.collectibleGalleryUIActionsViewDidEditSearchInput(self, input: input)
    }

    func collectibleGalleryUIActionsViewDidReturnSearchInput(_ view: CollectibleGalleryUIActionsView) {
        delegate?.collectibleGalleryUIActionsViewDidReturnSearchInput(self)
    }
}

protocol CollectibleGalleryUIActionsCellDelegate: AnyObject {
    func collectibleGalleryUIActionsViewDidSelectGridUIStyle(_ cell: CollectibleGalleryUIActionsCell)
    func collectibleGalleryUIActionsViewDidSelectListUIStyle(_ cell: CollectibleGalleryUIActionsCell)
    func collectibleGalleryUIActionsViewDidReturnSearchInput(_ cell: CollectibleGalleryUIActionsCell)
    func collectibleGalleryUIActionsViewDidEditSearchInput(_ cell: CollectibleGalleryUIActionsCell, input: String?)
}
