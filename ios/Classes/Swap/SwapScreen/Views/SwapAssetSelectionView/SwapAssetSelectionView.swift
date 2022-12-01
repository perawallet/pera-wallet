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

//   SwapAssetSelectionView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class SwapAssetSelectionView:
    View,
    ViewModelBindable {
    private lazy var titleView = UILabel()
    private lazy var verificationTierView = ImageView()
    private lazy var accessoryView = ImageView()

    func customize(
        _ theme: SwapAssetSelectionViewTheme
    ) {
        addBackground(theme)
        addTitle(theme)
        addVerificationTier(theme)
        addAccessory(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: SwapAssetSelectionViewModel?
    ) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.clearText()
        }

        verificationTierView.image = viewModel?.verificationTier?.uiImage
        accessoryView.image = viewModel?.accessory?.uiImage
    }
}

extension SwapAssetSelectionView {
    private func addBackground(
        _ theme: SwapAssetSelectionViewTheme
    ) {
        customizeAppearance(theme.background)
        draw(corner: theme.corner)
    }

    private func addTitle(
        _ theme: SwapAssetSelectionViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == theme.contentPaddings.top
            $0.leading == theme.contentPaddings.leading
            $0.bottom == theme.contentPaddings.bottom
        }
    }

    private func addVerificationTier(
        _ theme: SwapAssetSelectionViewTheme
    ) {
        verificationTierView.customizeAppearance(theme.verificationTier)

        addSubview(verificationTierView)
        verificationTierView.contentEdgeInsets = theme.verificationTierContentEdgeInsets
        verificationTierView.fitToIntrinsicSize()
        verificationTierView.snp.makeConstraints {
            $0.centerY == titleView
            $0.leading == titleView.snp.trailing
        }
    }

    private func addAccessory(
        _ theme: SwapAssetSelectionViewTheme
    ) {
        accessoryView.customizeAppearance(theme.accessory)

        addSubview(accessoryView)
        accessoryView.contentEdgeInsets = theme.accessoryContentEdgeInsets
        accessoryView.fitToIntrinsicSize()
        accessoryView.snp.makeConstraints {
            $0.centerY == titleView
            $0.leading == verificationTierView.snp.trailing
            $0.trailing == theme.contentPaddings.trailing
        }
    }
}
