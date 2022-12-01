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

//
//   ResultView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ResultView:
    View,
    ViewModelBindable {
    private lazy var iconView = ImageView()
    private lazy var titleView = Label()
    private lazy var bodyView = Label()

    func customize(
        _ theme: ResultViewTheme
    ) {
        addIcon(theme)
        addTitle(theme)
        addBody(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: ResultViewModel?
    ) {
        if let icon = viewModel?.icon?.uiImage {
            iconView.image = icon
        } else {
            iconView.removeFromSuperview()
        }

        titleView.editText = viewModel?.title
        bodyView.editText = viewModel?.body
    }

    class func calculatePreferredSize(
        _ viewModel: ResultViewModel?,
        for theme: ResultViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let iconSize = viewModel.icon?.uiImage.size ?? .zero
        let titleSize =
            viewModel.title.boundingSize(
                fittingSize: CGSize((size.width, .greatestFiniteMagnitude))
            )
        let bodySize =
            viewModel.body.boundingSize(
                fittingSize: CGSize((size.width, .greatestFiniteMagnitude))
            )
        var preferredHeight =
            iconSize.height +
            titleSize.height +
            bodySize.height

        if viewModel.icon != nil {
            preferredHeight += theme.spacingBetweenIconAndTitle
        }

        if viewModel.body != nil {
            preferredHeight += theme.spacingBetweenTitleAndBody
        }

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension ResultView {
    private func addIcon(
        _ theme: ResultViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addTitle(
        _ theme: ResultViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.contentEdgeInsets.top = theme.spacingBetweenIconAndTitle
        titleView.fitToVerticalIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == iconView.snp.bottom
            $0.top.equalToSuperview().priority(.low)
            $0.leading == theme.titleHorizontalMargins.leading
            $0.trailing == theme.titleHorizontalMargins.trailing
        }
    }

    private func addBody(
        _ theme: ResultViewTheme
    ) {
        bodyView.customizeAppearance(theme.body)

        bodyView.contentEdgeInsets.top = theme.spacingBetweenTitleAndBody
        addSubview(bodyView)
        bodyView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == theme.bodyHorizontalMargins.leading
            $0.bottom == 0
            $0.trailing == theme.bodyHorizontalMargins.trailing
        }
    }
}

extension ResultView {
    enum IconViewAlignment {
        case centered
        case leading(margin: LayoutMetric)
        case trailing(margin: LayoutMetric)
    }
}
