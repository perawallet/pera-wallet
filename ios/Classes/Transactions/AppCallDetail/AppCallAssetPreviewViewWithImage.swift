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

//   AppCallAssetPreviewViewWithImage.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AppCallAssetPreviewViewWithImage:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var iconView = PrimaryImageView()
    private lazy var contentView = AppCallAssetPreviewView()

    func customize(
        _ theme: AppCallAssetPreviewViewWithImageTheme
    ) {
        addIcon(theme)
        addContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: AppCallAssetPreviewWithImageViewModel?
    ) {
        iconView.bindData(viewModel?.icon)
        contentView.bindData(viewModel?.content)
    }

    func prepareForReuse() {
        iconView.prepareForReuse()
        contentView.prepareForReuse()
    }

    class func calculatePreferredSize(
        _ viewModel: AppCallAssetPreviewWithImageViewModel?,
        for theme: AppCallAssetPreviewViewWithImageTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width

        let iconWidth = theme.iconSize.w
        let iconHeight = theme.iconSize.h

        let contentHeight = AppCallAssetPreviewView.calculatePreferredSize(
            viewModel.content,
            for: theme.content,
            fittingIn: CGSize((width - iconWidth, .greatestFiniteMagnitude))
        ).height

        let preferredHeight = max(contentHeight, iconHeight)
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AppCallAssetPreviewViewWithImage {
    private func addIcon(
        _ theme: AppCallAssetPreviewViewWithImageTheme
    ) {
        iconView.customize(theme.icon)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.leading == 0
            $0.centerY == 0
            $0.fitToSize(theme.iconSize)
        }
    }

    private func addContent(
        _ theme: AppCallAssetPreviewViewWithImageTheme
    ) {
        contentView.customize(theme.content)

        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.spacingBetweenIconAndContent
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}
