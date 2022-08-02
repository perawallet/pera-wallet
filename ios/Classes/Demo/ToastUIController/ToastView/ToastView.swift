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

//   ToastView.swift

import Foundation
import MacaroonToastUIKit
import MacaroonUIKit
import UIKit

final class ToastView:
    View,
    ViewModelBindable {
    private lazy var titleView: Label = .init()
    private lazy var bodyView: Label = .init()

    private var contentPaddings: UIEdgeInsets?
    private var bodyPaddings: UIEdgeInsets?

    func customize(
        _ theme: ToastViewTheme
    ) {
        contentPaddings = theme.contentPaddings
        bodyPaddings = theme.bodyPaddings

        addBackground(theme)
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
        _ viewModel: ToastViewModel?
    ) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.mc_text = nil
            titleView.attributedText = nil
        }

        if let body = viewModel?.body {
            body.load(in: bodyView)
        } else {
            bodyView.mc_text = nil
            bodyView.mc_attributedText = nil
        }
    }

    override func sizeThatFits(
        _ size: CGSize
    ) -> CGSize {
        let someContentPaddings = contentPaddings ?? .zero
        let titleMaxWidth = size.width - someContentPaddings.horizontal
        let titleMaxHeight = size.height - someContentPaddings.vertical
        let titleMaxSize = CGSize(width: titleMaxWidth, height: titleMaxHeight)
        let titleSize = titleView.sizeThatFits(titleMaxSize)
        let bodySize = bodyView.sizeThatFits(titleMaxSize)
        let width = min(
            max(titleSize.width, bodySize.width) + someContentPaddings.horizontal,
            size.width
        )
        let height = min(
            titleSize.height + bodySize.height + someContentPaddings.vertical,
            size.height
        )
        return CGSize(width: width, height: height)
    }
}

extension ToastView {
    private func addBackground(
        _ theme: ToastViewTheme
    ) {
        customizeAppearance(theme.background)
    }

    private func addTitle(
        _ theme: ToastViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == theme.contentPaddings.top
            $0.leading >= theme.contentPaddings.left
            $0.trailing <= theme.contentPaddings.right
            $0.centerX == 0
        }
    }

    private func addBody(
        _ theme: ToastViewTheme
    ) {
        bodyView.customizeAppearance(theme.body)

        addSubview(bodyView)
        bodyView.fitToIntrinsicSize()
        bodyView.contentEdgeInsets = (
            theme.bodyPaddings.top,
            theme.bodyPaddings.left,
            theme.bodyPaddings.bottom,
            theme.bodyPaddings.right
        )
        bodyView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading >= theme.contentPaddings.left
            $0.bottom == theme.contentPaddings.bottom
            $0.trailing <= theme.contentPaddings.right
            $0.centerX == 0
        }
    }
}
