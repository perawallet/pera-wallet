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

//   AnnouncementView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AnnouncementView:
    View,
    ViewModelBindable,
    UIInteractable,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .action: TargetActionInteraction(),
        .close: TargetActionInteraction()
    ]

    private lazy var stackView = VStackView()
    private lazy var titleView = UILabel()
    private lazy var subtitleView = UILabel()
    private lazy var closeButton = MacaroonUIKit.Button()
    private lazy var actionView = MacaroonUIKit.Button()
    private lazy var imageView = ImageView()
    
    func customize(
        _ theme: AnnouncementViewTheme
    ) {
        customizeAppearance(theme.background)
        draw(corner: theme.corner)

        addImageView(theme)
        addCloseButton(theme)
        addStackView(theme)
        addTitle(theme)
        addSubtitle(theme)
        addActionView(theme)
    }
    
    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}
    
    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
    
    func bindData(
        _ viewModel: AnnouncementViewModel?
    ) {
        if let title = viewModel?.title {
            titleView.showViewInStack()
            titleView.text = title
        } else {
            titleView.hideViewInStack()
        }

        if let subtitle = viewModel?.subtitle {
            subtitleView.showViewInStack()
            subtitleView.text = subtitle
        } else {
            subtitleView.hideViewInStack()
        }

        let actionTitle = viewModel?.ctaTitle
        let shouldDisplayAction = viewModel?.shouldDisplayAction ?? false

        if shouldDisplayAction {
            actionView.showViewInStack()
            actionView.setTitle(actionTitle!, for: .normal)
        } else {
            actionView.hideViewInStack()
        }
    }
    
    class func calculatePreferredSize(
        _ viewModel: AnnouncementViewModel?,
        for theme: AnnouncementViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }
        
        let width = size.width - theme.stackViewEdgeInset.leading - theme.stackViewEdgeInset.trailing
        let titleSize = viewModel.title?.boundingSize(
            attributes: .font(theme.title.font?.uiFont),
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let subtitleSize = viewModel.subtitle?.boundingSize(
            attributes: .font(theme.subtitle.font?.uiFont),
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        var preferredHeight =
            theme.stackViewEdgeInset.top

        if let size = titleSize {
            preferredHeight += size.height.ceil()
        }

        if let size = subtitleSize {
            preferredHeight += size.height.ceil() + theme.stackViewItemSpacing
        }

        let shouldDisplayAction = viewModel.shouldDisplayAction

        if shouldDisplayAction {
            preferredHeight += theme.stackViewButtonSpacing + theme.actionHeight
        }

        preferredHeight += theme.stackViewEdgeInset.bottom

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AnnouncementView {
    private func addImageView(
        _ theme: AnnouncementViewTheme
    ) {
        imageView.contentMode = .scaleAspectFill
        imageView.load(from: theme.backgroundImage)

        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
    }

    private func addCloseButton(
        _ theme: AnnouncementViewTheme
    ) {
        closeButton.customizeAppearance(theme.close)
        
        addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(theme.closeMargins.top)
            make.trailing.equalToSuperview().inset(theme.closeMargins.trailing)
            make.fitToSize(theme.closeSize)
        }

        startPublishing(
            event: .close,
            for: closeButton
        )
    }

    private func addStackView(
        _ theme: AnnouncementViewTheme
    ) {
        addSubview(stackView)
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.stackViewLayoutMargins.top,
            leading: theme.stackViewLayoutMargins.leading,
            bottom: theme.stackViewLayoutMargins.bottom,
            trailing: theme.stackViewLayoutMargins.trailing
        )
        stackView.spacing = theme.stackViewItemSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .top
        stackView.snp.makeConstraints {
            $0.top == theme.stackViewEdgeInset.top
            $0.leading == theme.stackViewEdgeInset.leading
            $0.trailing == theme.stackViewEdgeInset.trailing
            $0.bottom == theme.stackViewEdgeInset.bottom
        }
    }
    
    private func addTitle(
        _ theme: AnnouncementViewTheme
    ) {
        titleView.customizeAppearance(theme.title)
        
        stackView.addArrangedSubview(titleView)
    }
    
    private func addSubtitle(
        _ theme: AnnouncementViewTheme
    ) {
        subtitleView.customizeAppearance(theme.subtitle)
        
        stackView.addArrangedSubview(subtitleView)
        stackView.setCustomSpacing(theme.stackViewButtonSpacing, after: subtitleView)
    }

    private func addActionView(
        _ theme: AnnouncementViewTheme
    ) {
        actionView.customizeAppearance(theme.action)

        stackView.addArrangedSubview(actionView)
        actionView.snp.makeConstraints { make in
            make.height.equalTo(theme.actionHeight)
        }

        actionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)

        startPublishing(
            event: .action,
            for: actionView
        )
    }
}

extension AnnouncementView {
    enum Event {
        case action
        case close
    }
}
