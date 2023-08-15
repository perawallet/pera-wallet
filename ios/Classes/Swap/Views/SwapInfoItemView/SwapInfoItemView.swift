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

//   SwapInfoItemView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class SwapInfoItemView:
    View,
    ViewModelBindable,
    UIInteractable,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .didTapInfo: TargetActionInteraction()
    ]

    private lazy var titleView = Label()
    private lazy var infoActionView = MacaroonUIKit.Button()
    private lazy var detailView = Label()

    func customize(
        _ theme: SwapInfoItemViewTheme
    ) {
        addTitle(theme)
        addInfoAction(theme)
        addDetail(theme)
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

        if let iconTintColor = viewModel?.iconTintColor?.uiColor {
            let infoIcon = viewModel?.icon?.uiImage.withRenderingMode(.alwaysTemplate)
            infoActionView.setImage(infoIcon, for: .normal)
            infoActionView.tintColor = iconTintColor
        } else {
            let infoIcon = viewModel?.icon?.uiImage
            infoActionView.setImage(infoIcon, for: .normal)
            infoActionView.tintColor = nil
        }

        if let detail = viewModel?.detail {
            detail.load(in: detailView)
        } else {
            detailView.clearText()
        }
    }
}

extension SwapInfoItemView {
    private func addTitle(
        _ theme: SwapInfoItemViewTheme
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
        _ theme: SwapInfoItemViewTheme
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
        _ theme: SwapInfoItemViewTheme
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
            $0.trailing == 0
        }
    }
}

extension SwapInfoItemView {
    enum Event {
        case didTapInfo
    }
}
