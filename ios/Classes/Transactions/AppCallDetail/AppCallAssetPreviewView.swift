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

//   AppCallAssetPreviewView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AppCallAssetPreviewView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var titleView = Label()
    private lazy var iconView = ImageView()
    private lazy var subtitleView = Label()

    func customize(
        _ theme: AppCallAssetPreviewViewTheme
    ) {
        addTitle(theme)
        addVerifiedIcon(theme)
        addSubtitle(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: AppCallAssetPreviewViewModel?
    ) {
        titleView.editText = viewModel?.title
        iconView.image = viewModel?.accessoryIcon?.uiImage
        subtitleView.editText = viewModel?.subtitle
    }

    func prepareForReuse() {
        titleView.editText = nil
        iconView.image = nil
        subtitleView.editText = nil
    }

    class func calculatePreferredSize(
        _ viewModel: AppCallAssetPreviewViewModel?,
        for theme: AppCallAssetPreviewViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let titleSize = viewModel.title.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let subtitleSize = viewModel.subtitle.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let accessoryIconSize = viewModel.accessoryIcon?.uiImage.size ?? .zero
        let contentHeight = max(titleSize.height, accessoryIconSize.height) + subtitleSize.height
        let preferredHeight = contentHeight
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AppCallAssetPreviewView {
    private func addTitle(
        _ theme: AppCallAssetPreviewViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addVerifiedIcon(
        _ theme: AppCallAssetPreviewViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.contentEdgeInsets = theme.iconContentEdgeInsets
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.leading == titleView.snp.trailing
            $0.trailing <= 0
            $0.centerY == titleView
        }
    }

    private func addSubtitle(
        _ theme: AppCallAssetPreviewViewTheme
    ) {
        subtitleView.customizeAppearance(theme.subtitle)

        addSubview(subtitleView)
        subtitleView.contentEdgeInsets.top = theme.spacingBetweenTitleAndSubtitle
        subtitleView.fitToVerticalIntrinsicSize()
        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}
