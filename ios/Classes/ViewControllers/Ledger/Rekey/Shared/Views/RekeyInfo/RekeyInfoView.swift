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

//
//   RekeyInfoView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class RekeyInfoView:
    View,
    ViewModelBindable {
    private lazy var titleView = UILabel()
    private lazy var sourceAccountItemCanvasView = UIView()
    private lazy var sourceAccountItemView = AccountListItemView()
    private lazy var arrowImageView = ImageView()
    private lazy var authAccountItemCanvasView = UIView()
    private lazy var authAccountItemView = AccountListItemView()

    func customize(_ theme: RekeyInfoViewTheme) {
        addTitle(theme)
        addSourceAccountItem(theme)
        addArrowImage(theme)
        addAuthAccountItem(theme)
    }

    func bindData(_ viewModel: RekeyInfoViewModel?) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.attributedText = nil
            titleView.text = nil
        }

        sourceAccountItemView.bindData(viewModel?.sourceAccountItem)
        authAccountItemView.bindData(viewModel?.authAccountItem)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension RekeyInfoView {
    private func addTitle(_ theme: RekeyInfoViewTheme) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addSourceAccountItem(_ theme: RekeyInfoViewTheme) {
        addSubview(sourceAccountItemCanvasView)
        sourceAccountItemCanvasView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndContent
            $0.leading == 0
            $0.trailing == 0
            $0.greaterThanHeight(theme.accountItemMinHeight)
        }

        sourceAccountItemView.customize(theme.accountItem)

        sourceAccountItemCanvasView.addSubview(sourceAccountItemView)
        sourceAccountItemView.snp.makeConstraints {
            $0.top == theme.accountItemContentPaddings.top
            $0.leading == theme.accountItemContentPaddings.leading
            $0.trailing == theme.accountItemContentPaddings.trailing
            $0.bottom == theme.accountItemContentPaddings.bottom
        }
    }

    private func addArrowImage(_ theme: RekeyInfoViewTheme) {
        arrowImageView.customizeAppearance(theme.arrowImage)

        arrowImageView.contentEdgeInsets = theme.arrowImageLayoutOffset
        addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints {
            $0.top == sourceAccountItemCanvasView.snp.bottom
            $0.leading == 0
        }
    }

    private func addAuthAccountItem(_ theme: RekeyInfoViewTheme) {
        addSubview(authAccountItemCanvasView)
        authAccountItemCanvasView.snp.makeConstraints {
            $0.top == arrowImageView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
            $0.greaterThanHeight(theme.accountItemMinHeight)
        }

        authAccountItemView.customize(theme.accountItem)

        authAccountItemCanvasView.addSubview(authAccountItemView)
        authAccountItemView.snp.makeConstraints {
            $0.top == theme.accountItemContentPaddings.top
            $0.leading == theme.accountItemContentPaddings.leading
            $0.trailing == theme.accountItemContentPaddings.trailing
            $0.bottom == theme.accountItemContentPaddings.bottom
        }
    }
}
