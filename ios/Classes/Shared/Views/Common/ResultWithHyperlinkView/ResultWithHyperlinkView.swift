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

//   ResultWithHyperlinkView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ResultWithHyperlinkView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performHyperlinkAction: UIBlockInteraction()
    ]

    private lazy var iconView = ImageView()
    private lazy var titleView = Label()
    private lazy var bodyView = ALGActiveLabel()

    func customize(
        _ theme: ResultWithHyperlinkViewTheme
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
        _ viewModel: ResultWithHyperlinkViewModel?
    ) {
        if let icon = viewModel?.icon?.uiImage {
            iconView.image = icon
        } else {
            iconView.removeFromSuperview()
        }

        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        if let body = viewModel?.body {
            if let highlightedText = body.highlightedText {
                let hyperlink: ALGActiveType = .word(highlightedText.text)
                bodyView.attachHyperlink(
                    hyperlink,
                    to: body.text,
                    attributes: highlightedText.attributes
                ) {
                    [unowned self] in
                    let interaction = self.uiInteractions[.performHyperlinkAction]
                    interaction?.publish()
                }
                return
            }

            body.text.load(in: bodyView)
        } else {
            bodyView.text = nil
            bodyView.attributedText = nil
        }
    }

    class func calculatePreferredSize(
        _ viewModel: ResultWithHyperlinkViewModel?,
        for theme: ResultWithHyperlinkViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let iconSize = theme.iconSize ?? (viewModel.icon?.uiImage.size ?? .zero)
        let titleSize =
            viewModel.title?.boundingSize(
                multiline: true,
                fittingSize: CGSize((size.width, .greatestFiniteMagnitude))
            ) ?? .zero
        let bodySize =
            viewModel.body?.text.boundingSize(
                multiline: true,
                fittingSize: CGSize((size.width, .greatestFiniteMagnitude))
            ) ?? .zero
        var preferredHeight =
            iconSize.height +
            titleSize.height +
            theme.bodyTopMargin +
            bodySize.height

        if viewModel.icon != nil {
            preferredHeight += theme.titleTopMargin
        }

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension ResultWithHyperlinkView {
    private func addIcon(
        _ theme: ResultWithHyperlinkViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0

            if let iconSize = theme.iconSize {
                $0.fitToSize((iconSize.width, iconSize.height))
            }
        }
    }

    private func addTitle(
        _ theme: ResultWithHyperlinkViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == iconView.snp.bottom + theme.titleTopMargin
            $0.top.equalToSuperview().priority(.low)

            $0.setPaddings((.noMetric, 0, .noMetric, 0))
        }
    }

    private func addBody(
        _ theme: ResultWithHyperlinkViewTheme
    ) {
        bodyView.customizeAppearance(theme.body)

        addSubview(bodyView)
        bodyView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.bodyTopMargin

            $0.setPaddings((.noMetric, 0, 0, 0))
        }
    }
}

extension ResultWithHyperlinkView {
    enum Event {
        case performHyperlinkAction
    }
}
