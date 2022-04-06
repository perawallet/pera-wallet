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

//   InfoView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class InfoView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var iconView = ImageView()
    private lazy var messageView = Label()

    func customize(
        _ theme: InfoViewTheme
    ) {
        addBackground(theme)
        addContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: InfoViewModel?
    ) {
        iconView.image = viewModel?.icon?.uiImage
        messageView.editText = viewModel?.message
    }

    class func calculatePreferredSize(
        _ viewModel: InfoViewModel?,
        for theme: InfoViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width =
        size.width -
        theme.contentPaddings.trailing -
        theme.contentPaddings.leading
        let messageSize = viewModel.message.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let preferredHeight =
        theme.contentPaddings.top +
        theme.contentPaddings.bottom +
        messageSize.height
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension InfoView {
    private func  addBackground(
        _ theme: InfoViewTheme
    ) {
        customizeAppearance(theme.background)
        draw(corner: theme.corner)
    }

    private func addContent(
        _ theme: InfoViewTheme
    ) {
        addSubview(contentView)

        contentView.snp.makeConstraints {
            $0.setPaddings(
                theme.contentPaddings
            )
        }

        addIcon(theme)
        addMessage(theme)
    }

    private func addIcon(
        _ theme: InfoViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)

        contentView.addSubview(iconView)
        iconView.contentEdgeInsets = theme.iconContentEdgeInsets
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addMessage(
        _ theme: InfoViewTheme
    ) {
        messageView.customizeAppearance(theme.message)

        contentView.addSubview(messageView)
        messageView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing
            $0.trailing == 0
            $0.bottom == 0
        }
    }
}
