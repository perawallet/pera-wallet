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

//   StandardAssetPreviewLoadingView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class StandardAssetPreviewLoadingView:
    MacaroonUIKit.View,
    ShimmerAnimationDisplaying {
    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var iconView = ShimmerView()
    private lazy var infoView = ShimmerView()
    private lazy var primaryValueView = ShimmerView()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        linkInteractors()
    }

    func customize(
        _ theme: StandardAssetPreviewLoadingViewTheme
    ) {
        addBackground(theme)
        addContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func linkInteractors() {
        isUserInteractionEnabled = false
    }
}

extension StandardAssetPreviewLoadingView {
    private func addBackground(
        _ theme: StandardAssetPreviewLoadingViewTheme
    ) {
        customizeAppearance(theme.background)
    }

    private func addContent(
        _ theme: StandardAssetPreviewLoadingViewTheme
    ) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == theme.contentEdgeInsets.top
            $0.leading == theme.contentEdgeInsets.leading
            $0.bottom == theme.contentEdgeInsets.bottom
            $0.trailing == theme.contentEdgeInsets.trailing
        }

        addIcon(theme)
        addInfo(theme)
        addPrimaryValue(theme)
    }

    private func addIcon(
        _ theme: StandardAssetPreviewLoadingViewTheme
    ) {
        iconView.draw(corner: theme.iconCorner)

        contentView.addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.centerX == 0
            $0.top == 0
        }
    }

    private func addInfo(
        _ theme: StandardAssetPreviewLoadingViewTheme
    ) {
        infoView.draw(corner: theme.corner)

        contentView.addSubview(infoView)
        infoView.snp.makeConstraints {
            $0.fitToSize(theme.infoSize)
            $0.centerX == 0
            $0.top == iconView.snp.bottom + theme.spacingBetweenIconAndInfo
        }
    }

    private func addPrimaryValue(
        _ theme: StandardAssetPreviewLoadingViewTheme
    ) {
        primaryValueView.draw(corner: theme.corner)

        contentView.addSubview(primaryValueView)
        primaryValueView.snp.makeConstraints {
            $0.fitToSize(theme.primaryValueSize)
            $0.centerX == 0
            $0.top == infoView.snp.bottom + theme.spacingBetweeenPrimaryValueAndInfo
            $0.bottom == 0
        }
    }
}
