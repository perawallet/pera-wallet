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

//   CollectibleExternalSourceView.swift

import UIKit
import MacaroonUIKit

final class CollectibleExternalSourceView:
    View,
    ListReusable,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performAction: TargetActionInteraction()
    ]

    private lazy var iconView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var actionButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setListeners()
    }

    func customize(
        _ theme: CollectibleExternalSourceViewTheme
    ) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addIconView(theme)
        addActionButton(theme)
        addTitleLabel(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func setListeners() {
        startPublishing(
            event: .performAction,
            for: actionButton
        )
    }
}

extension CollectibleExternalSourceView {
    private func addIconView(_ theme: CollectibleExternalSourceViewTheme) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(theme.verticalInset)
            $0.leading.equalToSuperview()
            $0.size.equalTo(CGSize(theme.iconSize))
        }
    }

    private func addActionButton(_ theme: CollectibleExternalSourceViewTheme) {
        addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.size.equalTo(CGSize(theme.actionSize))
        }
    }

    private func addTitleLabel(_ theme: CollectibleExternalSourceViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(theme.verticalInset)
            $0.leading.equalTo(iconView.snp.trailing).offset(theme.titleHorizontalPadding)
            $0.trailing.equalTo(actionButton.snp.leading).offset(-theme.titleHorizontalPadding)
        }
    }
}

extension CollectibleExternalSourceView {
    func bindData(_ viewModel: CollectibleExternalSourceViewModel?) {
        iconView.image = viewModel?.icon?.uiImage
        titleLabel.editText = viewModel?.title
        actionButton.setImage(viewModel?.action?.uiImage, for: .normal)
    }

    class func calculatePreferredSize(
        _ viewModel: CollectibleExternalSourceViewModel?,
        for theme: CollectibleExternalSourceViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let iconSize = theme.iconSize
        let verticalInset = theme.verticalInset * 2
        let titleSize = viewModel.title.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let contentHeight = max(titleSize.height, iconSize.h) + verticalInset
        return CGSize((size.width, min(contentHeight.ceil(), size.height)))
    }
}

extension CollectibleExternalSourceView {
    enum Event {
        case performAction
    }
}
