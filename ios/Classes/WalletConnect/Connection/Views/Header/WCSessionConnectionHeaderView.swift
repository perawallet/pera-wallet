// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCSessionConnectionHeaderView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class WCSessionConnectionHeaderView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var titleView = UILabel()

    func customize(_ theme: WCSessionConnectionHeaderViewTheme) {
        addContent(theme)
    }

    static func calculatePreferredSize(
        _ viewModel: WCSessionConnectionHeaderViewModel?,
        for theme: WCSessionConnectionHeaderViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let maxContextSize = CGSize((width, .greatestFiniteMagnitude))
        let preferredHeight = viewModel.title?.boundingSize(
            multiline: false,
            fittingSize: maxContextSize
        ).height ?? .zero
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) { }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) { }

    func bindData(_ viewModel: WCSessionConnectionHeaderViewModel?) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.clearText()
        }
    }

    func prepareForReuse() {
        titleView.clearText()
    }
}

extension WCSessionConnectionHeaderView {
    private func addContent(_ theme: WCSessionConnectionHeaderViewTheme) {
        let leadingLineView = UIView()
        leadingLineView.customizeAppearance(theme.dividerLine)

        addSubview(leadingLineView)
        leadingLineView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == 0
            $0.greaterThanWidth(theme.dividerLineMinWidth)
            $0.fitToHeight(theme.dividerLineHeight)
        }

        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == 0
            $0.leading == leadingLineView.snp.trailing + theme.spacingBetweenDividerTitleAndLine
            $0.bottom == 0
        }

        let trailingLineView = UIView()
        trailingLineView.customizeAppearance(theme.dividerLine)

        addSubview(trailingLineView)
        trailingLineView.snp.makeConstraints {
            $0.centerY == 0
            $0.trailing == 0
            $0.leading == titleView.snp.trailing + theme.spacingBetweenDividerTitleAndLine
            $0.greaterThanWidth(theme.dividerLineMinWidth)
            $0.fitToHeight(theme.dividerLineHeight)
        }
    }
}
