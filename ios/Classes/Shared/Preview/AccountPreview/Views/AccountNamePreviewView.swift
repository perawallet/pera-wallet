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

//   AccountNamePreviewView.swift

import UIKit
import MacaroonUIKit

final class AccountNamePreviewView:
    View,
    ViewModelBindable {
    private lazy var titleView = Label()
    private lazy var subtitleView = Label()

    func customize(
        _ theme: AccountNamePreviewViewTheme
    ) {
        addTitle(theme)
        addSubtitle(theme)
    }

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    class func calculatePreferredSize(
        _ viewModel: AccountNamePreviewViewModel?,
        for theme: AccountNamePreviewViewTheme,
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
        let preferredHeight =
        theme.titleContentEdgeInsets.top +
        theme.titleContentEdgeInsets.bottom +
        titleSize.height +
        theme.subtitleContentEdgeInsets.top +
        theme.subtitleContentEdgeInsets.bottom +
        subtitleSize.height
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }

    func bindData(
        _ viewModel: AccountNamePreviewViewModel?
    ) {
        titleView.editText = viewModel?.title
        subtitleView.editText = viewModel?.subtitle
    }
}

extension AccountNamePreviewView {
    private func addTitle(
        _ theme: AccountNamePreviewViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)

        titleView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        titleView.contentEdgeInsets = theme.titleContentEdgeInsets
        titleView.snp.makeConstraints {
            $0.setPaddings(
                (0, 0, .noMetric, 0)
            )
        }
    }

    private func addSubtitle(
        _ theme: AccountNamePreviewViewTheme
    ) {
        subtitleView.customizeAppearance(theme.subtitle)

        addSubview(subtitleView)

        subtitleView.fitToVerticalIntrinsicSize(
            hugging: .required,
            compression: .defaultHigh
        )
        subtitleView.contentEdgeInsets = theme.subtitleContentEdgeInsets
        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.setPaddings(
                (.noMetric, 0, 0, 0)
            )
        }
    }
}
