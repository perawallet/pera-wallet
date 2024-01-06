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

//   AlgorandSecureBackupFileView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AlgorandSecureBackupFileView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performClickAction: GestureInteraction(),
        .performClickContent: GestureInteraction(),
    ]

    private lazy var iconBackgroundView = TripleShadowView()
    private lazy var iconView = UIImageView()
    private lazy var titleView = UILabel()
    private lazy var subtitleView = UILabel()
    private lazy var actionView = UIButton()

    func customize(_ theme: AlgorandSecureBackupFileViewTheme) {
        draw(corner: theme.corner)

        addBackground(theme)
        addIcon(theme)
        addContent(theme)

        startPublishing(
            event: .performClickContent,
            for: self
        )

        startPublishing(
            event: .performClickAction,
            for: actionView
        )
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: AlgorandSecureBackupFileViewModel?) {
        updateIconPosition(viewModel)

        if let style = viewModel?.imageStyle {
            iconView.customizeAppearance(style)
        } else {
            iconView.customizeAppearance([])
        }

        let image = viewModel?.image
        image?.load(in: iconView)

        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        if let subtitle = viewModel?.subtitle {
            subtitle.load(in: subtitleView)
        } else {
            subtitleView.text = nil
            subtitleView.attributedText = nil
        }

        let isActionVisible = viewModel?.isActionVisible ?? false
        actionView.isHidden = !isActionVisible

        if let style = viewModel?.actionTheme {
            actionView.customizeAppearance(style)
        } else {
            actionView.customizeAppearance(NoStyleSheet())
        }
    }

    private func updateIconPosition(_ viewModel: AlgorandSecureBackupFileViewModel?) {
        let theme = AlgorandSecureBackupFileViewTheme()
        let isEmptyState = viewModel?.isEmptyState ?? true

        iconBackgroundView.snp.updateConstraints { make in
            let topInset = isEmptyState ? theme.iconTopInset : theme.iconAlignedTopInset
            make.top == topInset
        }
    }
}

extension AlgorandSecureBackupFileView {
    private func addBackground(_ theme: AlgorandSecureBackupFileViewTheme) {
        customizeAppearance(theme.background)
    }

    private func addIcon(_ theme: AlgorandSecureBackupFileViewTheme) {
        addIconBackground(theme)

        iconBackgroundView.addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.center == 0
            $0.fitToSize(theme.iconSize)
        }
    }

    private func addIconBackground(_ theme: AlgorandSecureBackupFileViewTheme) {
        iconBackgroundView.drawAppearance(shadow: theme.iconFirstShadow)
        iconBackgroundView.drawAppearance(secondShadow: theme.iconSecondShadow)
        iconBackgroundView.drawAppearance(thirdShadow: theme.iconThirdShadow)

        addSubview(iconBackgroundView)
        iconBackgroundView.snp.makeConstraints {
            $0.top == theme.iconTopInset
            $0.centerX == 0
            $0.fitToSize(theme.iconBackgroundSize)
        }
    }

    private func addContent(_ theme: AlgorandSecureBackupFileViewTheme) {
        addTitle(theme)
        addSubtitle(theme)
        addAction(theme)
    }

    private func addTitle(_ theme: AlgorandSecureBackupFileViewTheme) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == iconBackgroundView.snp.bottom + theme.spacingBetweenIconAndTitle
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addSubtitle(_ theme: AlgorandSecureBackupFileViewTheme) {
        subtitleView.customizeAppearance(theme.subtitle)

        addSubview(subtitleView)
        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndSubtitle
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addAction(_ theme: AlgorandSecureBackupFileViewTheme) {
        actionView.customizeAppearance(theme.action)

        addSubview(actionView)
        actionView.snp.makeConstraints {
            $0.bottom == theme.actionBottomInset
            $0.centerX == 0
        }
    }
}

extension AlgorandSecureBackupFileView {
    enum Event {
        case performClickContent
        case performClickAction
    }
}
