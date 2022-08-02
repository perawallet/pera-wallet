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

//   TitleSupplementaryView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class TitleView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var titleView = UILabel()

    func customize(
        _ theme: TitleViewTheme
    ) {
        addTitle(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: TitleViewModel?
    ) {
        if let titleStyle = viewModel?.titleStyle {
            titleView.customizeAppearance(titleStyle)
        }

        titleView.editText = viewModel?.title
    }

    class func calculatePreferredSize(
        _ viewModel: TitleViewModel?,
        for theme: TitleViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width =
        size.width -
        theme.paddings.leading -
        theme.paddings.trailing
        let titleSize = viewModel.title.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let preferredHeight =
        titleSize.height +
        theme.paddings.top +
        theme.paddings.bottom
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension TitleView {
    private func addTitle(
        _ theme: TitleViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.setPaddings(theme.paddings)
        }
    }
}
