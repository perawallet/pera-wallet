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

//   SecondaryListItemValueView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class SecondaryListItemValueView:
    View,
    ViewModelBindable {
    private lazy var backgroundImageView = UIImageView()
    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var iconView = ImageView()
    private lazy var titleView = Label()

    func customize(
        _ theme: SecondaryListItemValueViewTheme
    ) {
        customizeAppearance(theme.view)
        
        addBackgroundImage(theme)
        addContent(theme)
    }

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func bindData(
        _ viewModel: SecondaryListItemValueViewModel?
    ) {
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
    }
}

extension SecondaryListItemValueView {
    private func addBackgroundImage(
        _ theme: SecondaryListItemValueViewTheme
    ) {
        backgroundImageView.customizeAppearance(theme.backgroundImage)

        addSubview(backgroundImageView)
        backgroundImageView.fitToVerticalIntrinsicSize()
        backgroundImageView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func addContent(
        _ theme: SecondaryListItemValueViewTheme
    ) {
        backgroundImageView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == theme.contentEdgeInsets.top
            $0.leading == theme.contentEdgeInsets.leading
            $0.bottom == theme.contentEdgeInsets.bottom
            $0.trailing == theme.contentEdgeInsets.trailing
        }

        addIcon(theme)
        addTitle(theme)
    }

    private func addIcon(
        _ theme: SecondaryListItemValueViewTheme
    ) {
        contentView.addSubview(iconView)

        iconView.contentEdgeInsets = theme.iconLayoutOffset
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addTitle(
        _ theme: SecondaryListItemValueViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.height >= iconView
            $0.top == 0
            $0.leading == iconView.snp.trailing
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}
