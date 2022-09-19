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

//   InfoBoxView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class InfoBoxView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var iconView = ImageView()
    private lazy var titleView = Label()
    private lazy var messageView = Label()

    func customize(
        _ theme: InfoBoxViewTheme
    ) {
        addContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension InfoBoxView {
    private func addContent(
        _ theme: InfoBoxViewTheme
    ) {
        addSubview(contentView)

        contentView.snp.makeConstraints {
            $0.setPaddings(
                theme.contentPaddings
            )
        }

        addIcon(theme)
        addTitle(theme)
        addMessage(theme)
    }

    private func addIcon(
        _ theme: InfoBoxViewTheme
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

    private func addTitle(
        _ theme: InfoBoxViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing
            $0.trailing <= 0
        }
    }

    private func addMessage(
        _ theme: InfoBoxViewTheme
    ) {
        messageView.customizeAppearance(theme.message)

        contentView.addSubview(messageView)
        messageView.contentEdgeInsets.top = theme.spacingBetweenTitleAndMessage
        messageView.fitToVerticalIntrinsicSize()
        messageView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == titleView
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}

extension InfoBoxView {
    func bindData(
        _ viewModel: InfoBoxViewModel?
    ) {
        guard let viewModel = viewModel else {
            return
        }

        if let infoBoxStyle = viewModel.style {
            customizeAppearance(infoBoxStyle.background)
            draw(corner: infoBoxStyle.corner)
        }

        iconView.image = viewModel.icon?.uiImage

        if let title = viewModel.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        if let message = viewModel.message {
            message.load(in: messageView)
        } else {
            messageView.text = nil
            messageView.attributedText = nil
        }
    }

    class func calculatePreferredSize(
        _ viewModel: InfoBoxViewModel?,
        for theme: InfoBoxViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width -
            theme.contentPaddings.trailing -
            theme.contentPaddings.leading
        let titleSize = viewModel.title?.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let messageSize = viewModel.message?.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let preferredHeight = theme.contentPaddings.top +
            theme.contentPaddings.bottom +
            theme.spacingBetweenTitleAndMessage +
            titleSize.height +
            messageSize.height
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}
