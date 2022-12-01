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

//   SwapInfoActionItemView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class SwapInfoActionItemView:
    View,
    ViewModelBindable,
    UIInteractable,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .didTapInfo: TargetActionInteraction(),
        .didTapAction: TargetActionInteraction()
    ]

    private lazy var titleView = Label()
    private lazy var infoActionView = MacaroonUIKit.Button()
    private lazy var detailView = Label()
    private lazy var detailActionView = MacaroonUIKit.Button()

    func customize(
        _ theme: SwapInfoActionItemViewTheme
    ) {
        addTitle(theme)
        addInfoAction(theme)
        addDetail(theme)
        addDetailAction(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: SwapInfoItemViewModel?
    ) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.clearText()
        }

        infoActionView.setImage(viewModel?.icon?.uiImage , for: .normal)

        if let detail = viewModel?.detail {
            detail.load(in: detailView)
        } else {
            detailView.clearText()
        }

        detailActionView.setImage(viewModel?.action?.uiImage , for: .normal)
    }
}

extension SwapInfoActionItemView {
    private func addTitle(
        _ theme: SwapInfoActionItemViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addInfoAction(
        _ theme: SwapInfoActionItemViewTheme
    ) {
        addSubview(infoActionView)
        infoActionView.fitToIntrinsicSize()
        infoActionView.contentEdgeInsets = theme.infoActionContentEdgeInsets
        infoActionView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == titleView.snp.trailing
        }

        startPublishing(
            event: .didTapInfo,
            for: infoActionView
        )
    }

    private func addDetail(
        _ theme: SwapInfoActionItemViewTheme
    ) {
        detailView.customizeAppearance(theme.detail)

        addSubview(detailView)
        detailView.fitToIntrinsicSize()
        detailView.snp.makeConstraints {
            $0.width <= self * theme.detailMaxWidthRatio
            $0.centerY == 0
            $0.top >= 0
            $0.leading >= infoActionView.snp.trailing + theme.minimumSpacingBetweenInfoActionAndDetail
            $0.bottom <= 0
        }
    }

    private func addDetailAction(
        _ theme: SwapInfoActionItemViewTheme
    ) {
        addSubview(detailActionView)
        detailActionView.fitToIntrinsicSize()
        detailActionView.contentEdgeInsets = theme.detailActionContentEdgeInsets
        detailActionView.snp.makeConstraints {
            $0.fitToSize(theme.detailActionSize)
            $0.centerY == 0
            $0.leading == detailView.snp.trailing
            $0.trailing == 0
        }

        startPublishing(
            event: .didTapAction,
            for: detailActionView
        )
    }
}

extension SwapInfoActionItemView {
    enum Event {
        case didTapInfo
        case didTapAction
    }
}
