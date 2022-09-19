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

//   OptOutAssetListItemView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class OptOutAssetListItemView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var contentView = PrimaryListItemView()

    func customize(
        _ theme: OptOutAssetListItemViewTheme
    ) {
        addContent(theme)
    }

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func bindData(
        _ viewModel: OptOutAssetListItemViewModel?
    ) {
        contentView.bindData(viewModel?.content)
    }

    func prepareForReuse() {
        contentView.prepareForReuse()
    }

    class func calculatePreferredSize(
        _ viewModel: OptOutAssetListItemViewModel?,
        for theme: OptOutAssetListItemViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let contentSize = PrimaryListItemView.calculatePreferredSize(
            viewModel.content,
            for: theme.content,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
        let preferredHeight = contentSize.height
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension OptOutAssetListItemView {
    private func addContent(
        _ theme: OptOutAssetListItemViewTheme
    ) {
        contentView.customize(theme.content)

        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges == 0
        }
    }
}
