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

//   CollectibleDescriptionView.swift

import UIKit
import MacaroonUIKit

final class CollectibleDescriptionView:
    View,
    ListReusable,
    ViewModelBindable {
    private lazy var descriptionLabel = UILabel()

    func customize(
        _ theme: CollectibleDescriptionViewTheme
    ) {
        addDescription(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension CollectibleDescriptionView {
    private func addDescription(
        _ theme: CollectibleDescriptionViewTheme
    ) {
        descriptionLabel.customizeAppearance(theme.description)

        addSubview(descriptionLabel)
        descriptionLabel.fitToVerticalIntrinsicSize()
        descriptionLabel.snp.makeConstraints {
            $0.setPaddings(theme.paddings)
        }
    }
}

extension CollectibleDescriptionView {
    class func calculatePreferredSize(
        _ viewModel: CollectibleDescriptionViewModel?,
        for theme: CollectibleDescriptionViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let descriptionSize = viewModel.description.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let preferredHeight =
            descriptionSize.height +
            theme.paddings.bottom
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }

    func bindData(_ viewModel: CollectibleDescriptionViewModel?) {
        descriptionLabel.editText = viewModel?.description
    }
}
