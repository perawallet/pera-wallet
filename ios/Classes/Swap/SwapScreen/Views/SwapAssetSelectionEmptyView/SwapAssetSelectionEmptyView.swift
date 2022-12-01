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

//   SwapAssetSelectionEmptyView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class SwapAssetSelectionEmptyView:
    View,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .didSelectAsset: TargetActionInteraction()
    ]

    private lazy var titleView = Label()
    private lazy var iconView = UIImageView()
    private lazy var emptyAssetView = MacaroonUIKit.Button(.imageAtRight(spacing: theme.buttonIconSpacing))

    private let theme: SwapAssetSelectionEmptyViewTheme

    init(theme: SwapAssetSelectionEmptyViewTheme) {
        self.theme = theme
        super.init(frame: .zero)
    }

    func customize() {
        addTitle()
        addIcon()
        addEmptyAsset()
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: SwapAssetSelectionEmptyViewModel?
    ) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.clearText()
        }
    }
}

extension SwapAssetSelectionEmptyView {
    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.contentEdgeInsets.bottom = theme.spacingBetweenTitleAndIcon
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addIcon() {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addEmptyAsset() {
        emptyAssetView.customizeAppearance(theme.emptyAsset)

        addSubview(emptyAssetView)
        emptyAssetView.fitToIntrinsicSize()
        emptyAssetView.snp.makeConstraints {
            $0.centerY == iconView
            $0.leading == iconView.snp.trailing + theme.emptyAssetLeadingInset
            $0.bottom <= 0
        }

        startPublishing(
            event: .didSelectAsset,
            for: emptyAssetView
        )
    }
}

extension SwapAssetSelectionEmptyView {
    enum Event {
        case didSelectAsset
    }
}
