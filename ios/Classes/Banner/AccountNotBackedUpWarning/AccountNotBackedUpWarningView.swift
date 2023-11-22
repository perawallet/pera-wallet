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

//   AccountNotBackedUpWarningView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AccountNotBackedUpWarningView:
    View,
    ViewModelBindable,
    UIInteractable,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performBackup: TargetActionInteraction()
    ]

    private lazy var contentView = UIView()
    private lazy var contextView = UIView()
    private lazy var titleView = UILabel()
    private lazy var subtitleView = UILabel()
    private lazy var actionView = MacaroonUIKit.Button()
    private lazy var imageView = UIImageView()

    func customize(_ theme: AccountNotBackedUpWarningViewTheme) {
        customizeAppearance(theme.background)
        draw(corner: theme.corner)

        addContent(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet ) {}

    func bindData(_ viewModel: AccountNotBackedUpWarningViewModel?) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.clearText()
        }

        if let subtitle = viewModel?.subtitle {
            subtitle.load(in: subtitleView)
        } else {
            subtitleView.clearText()
        }

        imageView.image = viewModel?.image?.uiImage
        actionView.editTitle = viewModel?.action
    }

    class func calculatePreferredSize(
        _ viewModel: AccountNotBackedUpWarningViewModel?,
        for theme: AccountNotBackedUpWarningViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = 
            size.width -
            theme.contentPaddings.leading -
            theme.contentPaddings.trailing
        let titleSize = viewModel.title?.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let subtitleSize = viewModel.subtitle?.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let actionSize = viewModel.action?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let preferredHeight =
            theme.contentPaddings.top +
            titleSize.height +
            theme.spacingBetweenTitleAndSubtitle +
            subtitleSize.height +
            theme.spacingBetweenContextAndAction +
            theme.actionEdgeInsets.top +
            actionSize.height +
            theme.actionEdgeInsets.bottom + 
            theme.contentPaddings.bottom
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AccountNotBackedUpWarningView {
    private func addContent(_ theme: AccountNotBackedUpWarningViewTheme) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == theme.contentPaddings.top
            $0.leading == theme.contentPaddings.leading
            $0.trailing == theme.contentPaddings.trailing
            $0.bottom == theme.contentPaddings.bottom
        }

        addContext(theme)
        addImage(theme)
        addAction(theme)
    }

    private func addContext(_ theme: AccountNotBackedUpWarningViewTheme) {
        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
        }

        addTitle(theme)
        addSubtitle(theme)
    }

    private func addTitle(_ theme: AccountNotBackedUpWarningViewTheme) {
        titleView.customizeAppearance(theme.title)

        contextView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }
    
    private func addSubtitle(_ theme: AccountNotBackedUpWarningViewTheme) {
        subtitleView.customizeAppearance(theme.subtitle)

        contextView.addSubview(subtitleView)
        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndSubtitle
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addImage(_ theme: AccountNotBackedUpWarningViewTheme) {
        imageView.customizeAppearance(theme.image)

        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top == theme.imageTopMargin
            $0.leading >= contextView.snp.trailing + theme.spacingBetweenContextAndImage
            $0.trailing == 0
        }
    }

    private func addAction(_ theme: AccountNotBackedUpWarningViewTheme) {
        actionView.customizeAppearance(theme.action)
        actionView.draw(corner: theme.actionCorner)

        contentView.addSubview(actionView)
        actionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        actionView.fitToIntrinsicSize()
        actionView.snp.makeConstraints {
            $0.top == contextView.snp.bottom + theme.spacingBetweenContextAndAction
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }

        startPublishing(
            event: .performBackup,
            for: actionView
        )
    }
}

extension AccountNotBackedUpWarningView {
    enum Event {
        case performBackup
    }
}
