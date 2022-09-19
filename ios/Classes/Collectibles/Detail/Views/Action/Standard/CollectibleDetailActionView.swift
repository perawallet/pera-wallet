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

//   CollectibleDetailActionView.swift

import UIKit
import MacaroonUIKit

final class CollectibleDetailActionView:
    View,
    ListReusable,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performSend: TargetActionInteraction(),
        .performShare: TargetActionInteraction()
    ]

    private lazy var labelStackView = VStackView()
    private lazy var titleLabel = Label()
    private lazy var subtitleLabel = Label()
    private lazy var buttonStackView = HStackView()
    private lazy var sendButton = MacaroonUIKit.Button(.imageAtLeft(spacing: 12))
    private lazy var shareButton = MacaroonUIKit.Button(.imageAtLeft(spacing: 12))
    private lazy var separator = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setListeners()
    }

    func customize(
        _ theme: CollectibleDetailActionViewTheme
    ) {
        addLabelStackView(theme)
        addButtonStackView(theme)
        addSeparator(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func setListeners() {
        startPublishing(
            event: .performSend,
            for: sendButton
        )

        startPublishing(
            event: .performShare,
            for: shareButton
        )
    }
}

extension CollectibleDetailActionView {
    private func addLabelStackView(_ theme: CollectibleDetailActionViewTheme) {
        labelStackView.distribution = .equalSpacing
        labelStackView.spacing = theme.subtitleTopOffset

        addSubview(labelStackView)
        labelStackView.snp.makeConstraints {
            $0.top == theme.topInset
            $0.leading.trailing == 0
        }

        titleLabel.customizeAppearance(theme.title)
        labelStackView.addArrangedSubview(titleLabel)
        titleLabel.fitToIntrinsicSize()

        subtitleLabel.customizeAppearance(theme.subtitle)
        labelStackView.addArrangedSubview(subtitleLabel)
        subtitleLabel.fitToIntrinsicSize()
    }

    private func addButtonStackView(_ theme: CollectibleDetailActionViewTheme) {
        addSubview(buttonStackView)

        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = theme.buttonSpacing

        buttonStackView.fitToIntrinsicSize()

        buttonStackView.snp.makeConstraints {
            $0.trailing == 0
            $0.top == labelStackView.snp.bottom + theme.buttonTopOffset
            $0.leading == 0
            $0.height.equalTo(theme.buttonHeight)
        }

        sendButton.customizeAppearance(theme.sendAction)
        sendButton.draw(corner: theme.actionCorner)
        sendButton.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)

        buttonStackView.addArrangedSubview(sendButton)

        shareButton.customizeAppearance(theme.shareAction)
        shareButton.draw(corner: theme.actionCorner)
        shareButton.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)

        buttonStackView.addArrangedSubview(shareButton)
    }

    private func addSeparator(_ theme: CollectibleDetailActionViewTheme) {
        separator.customizeAppearance(theme.separator)

        addSubview(separator)
        separator.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(theme.separatorHorizontalInset)
            $0.trailing.equalToSuperview().offset(-theme.separatorHorizontalInset)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(theme.separatorHeight)
            $0.top.equalTo(buttonStackView.snp.bottom).offset(theme.buttonBottomInset)
        }
    }
}

extension CollectibleDetailActionView {
    func bindData(_ viewModel: CollectibleDetailActionViewModel?) {
        guard let viewModel = viewModel else {
            return
        }

        titleLabel.isHidden = viewModel.title == nil
        titleLabel.editText = viewModel.title
        titleLabel.isHidden = viewModel.subtitle == nil
        subtitleLabel.editText = viewModel.subtitle
    }

    func hideSendAction() {
        sendButton.isHidden = true
    }

    class func calculatePreferredSize(
        _ viewModel: CollectibleDetailActionViewModel?,
        for theme: CollectibleDetailActionViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let titleSize = viewModel.title.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let subtitleSize = viewModel.subtitle.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let buttonHeight = theme.buttonHeight
        let verticalSpacing =
            theme.topInset +
            theme.subtitleTopOffset +
            theme.buttonTopOffset +
            theme.buttonBottomInset
        let contentHeight =
            titleSize.height +
            subtitleSize.height +
            buttonHeight +
            verticalSpacing

        return CGSize((size.width, min(contentHeight.ceil(), size.height)))
    }
}

extension CollectibleDetailActionView {
    enum Event {
        case performSend
        case performShare
    }
}
