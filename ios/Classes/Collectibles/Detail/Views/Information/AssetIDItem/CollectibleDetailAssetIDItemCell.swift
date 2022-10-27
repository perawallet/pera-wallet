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

//   CollectibleDetailAssetIDItemCell.swift

import UIKit
import MacaroonUIKit

final class CollectibleDetailAssetIDItemCell:
    CollectionCell<SecondaryListItemView>,
    ViewModelBindable,
    UIInteractable {
    override static var contextPaddings: LayoutPaddings {
        return theme.contextEdgeInsets
    }

    static let theme = CollectibleDetailAssetIDItemCellTheme()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contextView.customize(Self.theme.context)

        separatorStyle = .single(Self.theme.separator)
    }

    public static func calculatePreferredSize(
        _ viewModel: SecondaryListItemViewModel?,
        for layoutSheet: LayoutSheet,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let contextWidth =
        width -
        contextPaddings.leading -
        contextPaddings.trailing

        let maxContextSize = CGSize((contextWidth, .greatestFiniteMagnitude))

        let titleSize = viewModel.title?.boundingSize(
            multiline: false,
            fittingSize: maxContextSize
        ) ?? .zero
        let accessoryTitleSize = viewModel.accessory?.title?.boundingSize(
            multiline: false,
            fittingSize: maxContextSize
        ) ?? .zero

        let contextSize = max(titleSize.height, accessoryTitleSize.height)

        let preferredHeight =
        contextPaddings.top +
        contextSize +
        contextPaddings.bottom
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}
