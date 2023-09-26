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

//   OptInAssetListItemView.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

final class OptInAssetListItemView:
    UIView,
    ViewComposable,
    ViewModelBindable,
    ListReusable {
    private lazy var iconView = URLImageView()
    private lazy var titleView = PrimaryTitleView()

    func customize(_ theme: OptInAssetListItemViewTheme) {
        addIcon(theme)
        addTitle(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: OptInAssetListItemViewModel?) {
        iconView.load(from: viewModel?.icon)
        titleView.bindData(viewModel?.title)
    }

    static func calculatePreferredSize(
        _ viewModel: OptInAssetListItemViewModel?,
        for theme: OptInAssetListItemViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let iconSize = theme.iconSize
        let titleWidth =
            width -
            iconSize.w -
            theme.spacingBetweenIconAndTitle
        let titleMaxSize = CGSize(width: titleWidth, height: .greatestFiniteMagnitude)
        let titleSize = PrimaryTitleView.calculatePreferredSize(
            viewModel.title,
            for: theme.title,
            fittingIn: titleMaxSize
        )
        let preferredHeight = max(iconSize.h, titleSize.height)
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }

    func prepareForReuse() {
        iconView.prepareForReuse()
        titleView.prepareForReuse()
    }
}

extension OptInAssetListItemView {
    private func addIcon(_ theme: OptInAssetListItemViewTheme) {
        iconView.build(theme.icon)

        addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.leading == 0
            $0.centerY == 0
        }
    }

    private func addTitle(_ theme: OptInAssetListItemViewTheme) {
        titleView.customize(theme.title)

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.height >= iconView
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.spacingBetweenIconAndTitle
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}
