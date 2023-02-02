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

//   CollectibleDetailNameCell.swift

import Foundation
import MacaroonUIKit
import UIKit

final class CollectibleDetailNameCell:
    CollectionCell<PrimaryTitleView>,
    ViewModelBindable {
    static let theme = CollectibleDetailNameViewTheme()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        contextView.customize(Self.theme)
    }

    class func calculatePreferredSize(
        _ viewModel: PrimaryTitleViewModel?,
        for theme: PrimaryTitleViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let primaryTitleSingleLineSize = viewModel.primaryTitle?.boundingSize(
            multiline: false,
            fittingSize: CGSize((.greatestFiniteMagnitude, .greatestFiniteMagnitude))
        ) ?? .zero

        var primaryTitleHeight: CGFloat

        if primaryTitleSingleLineSize.width.ceil() > width {
            primaryTitleHeight = primaryTitleSingleLineSize.height * 2
        } else {
            primaryTitleHeight = primaryTitleSingleLineSize.height
        }

        var secondaryTitleSize = viewModel.secondaryTitle?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero

        if secondaryTitleSize.height > 0 {
            secondaryTitleSize.height += theme.spacingBetweenPrimaryAndSecondaryTitles
        }

        let primaryTitleAccessorySize = viewModel.primaryTitleAccessory?.uiImage.size ?? .zero
        let maxPrimaryTitleSize = max(primaryTitleHeight, primaryTitleAccessorySize.height)
        let contentHeight = maxPrimaryTitleSize + secondaryTitleSize.height
        let minCalculatedHeight = min(contentHeight.ceil(), size.height)
        return CGSize((size.width, minCalculatedHeight))
    }
}
