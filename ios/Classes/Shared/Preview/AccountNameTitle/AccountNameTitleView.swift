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

//   AccountNameTitleView.swift

import UIKit
import MacaroonUIKit

final class AccountNameTitleView:
    View,
    ViewModelBindable {
    private lazy var titleView = Label()
    private lazy var iconAndSubtitleContentView = UIView()
    private lazy var iconView = MacaroonUIKit.ImageView()
    private lazy var subtitleView = Label()

    func customize(_ theme: AccountNameTitleViewTheme) {
        addTitle(theme)
        addIconAndSubtitleContent(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func bindData(_ viewModel: AccountNameTitleViewModel?) {
        if let icon = viewModel?.icon {
            iconView.customizeAppearance(icon)
        } else {
            iconView.resetAppearance()
        }

        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        if let subtitle = viewModel?.subtitle {
            subtitle.load(in: subtitleView)
        } else {
            subtitleView.text = nil
            subtitleView.attributedText = nil
        }
    }
}

extension AccountNameTitleView {
    private func addTitle(_ theme: AccountNameTitleViewTheme) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .defaultLow
        )
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addIconAndSubtitleContent(_ theme: AccountNameTitleViewTheme) {
        addSubview(iconAndSubtitleContentView)
        iconAndSubtitleContentView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == titleView.snp.bottom
            $0.leading >= 0
            $0.bottom == 0
            $0.trailing <= 0
        }

        addIcon(theme)
        addSubtitle(theme)
    }

    private func addIcon(_ theme: AccountNameTitleViewTheme) {
        iconAndSubtitleContentView.addSubview(iconView)
        iconView.contentEdgeInsets.x = theme.spacingBetweenIconAndSubtitle
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.centerY == 0
            $0.top >= 0
            $0.leading == 0
            $0.bottom <= 0
        }
    }

    private func addSubtitle(_ theme: AccountNameTitleViewTheme) {
        subtitleView.customizeAppearance(theme.subtitle)

        iconAndSubtitleContentView.addSubview(subtitleView)
        subtitleView.fitToVerticalIntrinsicSize()
        subtitleView.contentEdgeInsets.top = theme.spacingBetweenTitleAndSubtitle
        subtitleView.snp.makeConstraints {
            $0.height >= iconView
            $0.top == 0
            $0.leading == iconView.snp.trailing
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}
