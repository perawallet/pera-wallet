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

//   TitleSeparatorView.swift

import MacaroonUIKit
import UIKit

final class TitleSeparatorView:
    View,
    ViewModelBindable {
    private lazy var leadingLineView = UIView()
    private lazy var titleView = UILabel()
    private lazy var trailingLineView = UIView()

    func customize(
        _ theme: TitleSeparatorViewTheme
    ) {
        addTitle(theme)
        addLeadingLine(theme)
        addTrailingLine(theme)
    }

    func prepareLayout(
        _ layoutSheet: LayoutSheet
    ) {}

    func customizeAppearance(
        _ styleSheet: ViewStyle
    ) {}

    func bindData(
        _ viewModel: TitleSeparatorViewModel?
    ) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.clearText()
        }
    }
}

extension TitleSeparatorView {
    private func addTitle(
        _ theme: TitleSeparatorViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.centerX == 0
            $0.bottom == 0
        }
    }

    private func addLeadingLine(
        _ theme: TitleSeparatorViewTheme
    ) {
        leadingLineView.customizeAppearance(theme.lineStyle)

        addSubview(leadingLineView)
        leadingLineView.fitToIntrinsicSize()
        leadingLineView.snp.makeConstraints {
            $0.centerY == titleView
            $0.fitToHeight(theme.lineHeight)
            $0.leading == 0
            $0.trailing == titleView.snp.leading - theme.linePaddings.leading
        }
    }

    private func addTrailingLine(
        _ theme: TitleSeparatorViewTheme
    ) {
        trailingLineView.customizeAppearance(theme.lineStyle)

        addSubview(trailingLineView)
        trailingLineView.fitToIntrinsicSize()
        trailingLineView.snp.makeConstraints {
            $0.centerY == titleView
            $0.fitToHeight(theme.lineHeight)
            $0.leading == titleView.snp.trailing + theme.linePaddings.leading
            $0.trailing == 0
        }
    }
}
