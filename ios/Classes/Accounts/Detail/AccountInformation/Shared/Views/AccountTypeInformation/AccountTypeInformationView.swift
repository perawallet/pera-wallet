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

//   AccountTypeInformationView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AccountTypeInformationView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performHyperlinkAction: UIBlockInteraction()
    ]

    private lazy var titleView = UILabel()
    private lazy var typeIconView = UIImageView()
    private lazy var typeTitleView = UILabel()
    private lazy var typeFootnoteView = Label()
    private lazy var typeDescriptionView = ALGActiveLabel()

    func customize(_ theme: AccountTypeInformationViewTheme) {
        addTitle(theme)
        addTypeIcon(theme)
        addTypeTitle(theme)
        addTypeFootnote(theme)
        addTypeDescription(theme)
    }

    func bindData(_ viewModel: AccountTypeInformationViewModel?) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        if let typeIcon = viewModel?.typeIcon?.uiImage {
            typeIconView.image = typeIcon
        } else {
            typeIconView.image = nil
        }

        if let typeTitle = viewModel?.typeTitle {
            typeTitle.load(in: typeTitleView)
        } else {
            typeTitleView.text = nil
            typeTitleView.attributedText = nil
        }

        if let typeFootnote = viewModel?.typeFootnote {
            typeFootnote.load(in: typeFootnoteView)
        } else {
            typeFootnoteView.text = nil
            typeFootnoteView.attributedText = nil
        }

        if let typeDescription = viewModel?.typeDescription {
            if let highlightedText = typeDescription.highlightedText {
                let hyperlink: ALGActiveType = .word(highlightedText.text)
                typeDescriptionView.attachHyperlink(
                    hyperlink,
                    to: typeDescription.text,
                    attributes: highlightedText.attributes
                ) {
                    [unowned self] in
                    let interaction = self.uiInteractions[.performHyperlinkAction]
                    interaction?.publish()
                }
                return
            }

            typeDescription.text.load(in: typeDescriptionView)
        } else {
            typeDescriptionView.text = nil
            typeDescriptionView.attributedText = nil
        }
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension AccountTypeInformationView {
    private func addTitle(_ theme: AccountTypeInformationViewTheme) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addTypeIcon(_ theme: AccountTypeInformationViewTheme) {
        addSubview(typeIconView)
        typeIconView.fitToIntrinsicSize()
        typeIconView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTypeIconAndTitle
            $0.leading == 0
            $0.fitToSize(theme.typeIconSize)
        }
    }

    private func addTypeTitle(_ theme: AccountTypeInformationViewTheme) {
        typeTitleView.customizeAppearance(theme.typeTitle)

        addSubview(typeTitleView)
        typeTitleView.snp.makeConstraints {
            $0.centerY == typeIconView
            $0.leading == typeIconView.snp.trailing + theme.spacingBetweenTypeIconAndTypeTitle
            $0.trailing == 0
        }
    }

    private func addTypeFootnote(_ theme: AccountTypeInformationViewTheme) {
        typeFootnoteView.customizeAppearance(theme.typeFootnote)

        addSubview(typeFootnoteView)
        typeFootnoteView.contentEdgeInsets.top = theme.spacingBetweenTypeTitleAndTypeFoonote
        typeFootnoteView.snp.makeConstraints {
            $0.top == typeIconView.snp.bottom
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addTypeDescription(_ theme: AccountTypeInformationViewTheme) {
        typeDescriptionView.customizeAppearance(theme.typeDescription)

        addSubview(typeDescriptionView)
        typeDescriptionView.snp.makeConstraints {
            $0.top == typeFootnoteView.snp.bottom + theme.spacingBetweenTypeFoonoteAndTypeDescription
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}

extension AccountTypeInformationView {
    enum Event {
        case performHyperlinkAction
    }
}
