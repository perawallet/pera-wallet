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

//   SwapSummaryAccountView.swift

import MacaroonUIKit
import UIKit

final class SwapSummaryAccountView:
    View,
    ViewModelBindable {
    private lazy var titleView = UILabel()
    private lazy var iconView = ImageView()
    private lazy var detailView = UILabel()

    func customize(
        _ theme: SwapSummaryAccountViewTheme
    ) {
        addIcon(theme)
        addDetail(theme)
        addTitle(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: SwapSummaryAccountViewModel?
    ) {
        iconView.image = viewModel?.icon?.uiImage
        viewModel?.accountName?.load(in: detailView)
    }
}

extension SwapSummaryAccountView {
    private func addIcon(
        _ theme: SwapSummaryAccountViewTheme
    ) {
        addSubview(iconView)

        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.centerY == 0
            $0.leading == theme.iconLeadingInset
        }
    }

    private func addDetail(
        _ theme: SwapSummaryAccountViewTheme
    ) {
        detailView.customizeAppearance(theme.detail)

        addSubview(detailView)
        detailView.fitToIntrinsicSize()
        detailView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.detailLeadingInset
            $0.bottom == 0
            $0.trailing <= 0
        }
    }

    private func addTitle(
        _ theme: SwapSummaryAccountViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == 0
            $0.trailing == iconView.snp.leading - theme.minimumSpacingBetweenTitleAndIcon
        }
    }
}
