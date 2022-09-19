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

//   CollectibleDetailOptedInActionView.swift

import UIKit
import MacaroonUIKit

final class CollectibleDetailOptedInActionView:
    View,
    ListReusable,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performOptOut: TargetActionInteraction(),
        .performCopy: UIBlockInteraction(),
        .performShareQR: UIBlockInteraction()
    ]

    private lazy var labelStackView = VStackView()
    private lazy var titleLabel = Label()
    private lazy var subtitleLabel = Label()
    private lazy var optOutButton = MacaroonUIKit.Button(.imageAtLeft(spacing: 12))
    private lazy var optedInTitleLabel = Label()
    private lazy var accountShareView = AccountShareView()
    private lazy var separator = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setListeners()
    }

    func customize(
        _ theme: CollectibleDetailOptedInActionViewTheme
    ) {
        addLabelStackView(theme)
        addOptOutButton(theme)
        addOptedInTitleLabel(theme)
        addAccountShareView(theme)
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
            event: .performOptOut,
            for: optOutButton
        )

        accountShareView.startObserving(event: .performCopy) {
            [weak self] in
            guard let self = self else { return }

            let interaction = self.uiInteractions[.performCopy]
            interaction?.publish()
        }

        accountShareView.startObserving(event: .performShareQR) {
            [weak self] in
            guard let self = self else { return }

            let interaction = self.uiInteractions[.performShareQR]
            interaction?.publish()
        }
    }
}

extension CollectibleDetailOptedInActionView {
    private func addLabelStackView(_ theme: CollectibleDetailOptedInActionViewTheme) {
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

    private func addOptOutButton(_ theme: CollectibleDetailOptedInActionViewTheme) {
        optOutButton.customizeAppearance(theme.optOut)
        optOutButton.draw(corner: theme.actionCorner)
        optOutButton.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)

        addSubview(optOutButton)
        optOutButton.snp.makeConstraints {
            $0.top == labelStackView.snp.bottom + theme.buttonTopInset
            $0.leading.trailing == 0
            $0.height.equalTo(theme.buttonHeight)
        }
    }

    private func addOptedInTitleLabel(_ theme: CollectibleDetailOptedInActionViewTheme) {
        optedInTitleLabel.customizeAppearance(theme.optedInTitle)

        addSubview(optedInTitleLabel)
        optedInTitleLabel.snp.makeConstraints {
            $0.trailing == 0
            $0.top == optOutButton.snp.bottom + theme.buttonBottomInset
            $0.leading == 0
        }
    }

    private func addAccountShareView(_ theme: CollectibleDetailOptedInActionViewTheme) {
        accountShareView.customize(AccountShareViewTheme())

        addSubview(accountShareView)
        accountShareView.snp.makeConstraints {
            $0.trailing == 0
            $0.top == optedInTitleLabel.snp.bottom + theme.accountShareTopInset
            $0.leading == 0
        }
    }

    private func addSeparator(_ theme: CollectibleDetailOptedInActionViewTheme) {
        separator.customizeAppearance(theme.separator)

        addSubview(separator)
        separator.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(theme.separatorHorizontalInset)
            $0.trailing.equalToSuperview().offset(-theme.separatorHorizontalInset)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(theme.separatorHeight)
            $0.top.equalTo(accountShareView.snp.bottom).offset(theme.accountShareBottomInset)
        }
    }
}

extension CollectibleDetailOptedInActionView {
    func bindData(_ viewModel: CollectibleDetailOptedInActionViewModel?) {
        guard let viewModel = viewModel else {
            return
        }

        titleLabel.isHidden = viewModel.title == nil
        titleLabel.editText = viewModel.title
        titleLabel.isHidden = viewModel.subtitle == nil
        subtitleLabel.editText = viewModel.subtitle
        accountShareView.bindData(viewModel.shareViewModel)
    }

    class func calculatePreferredSize(
        _ viewModel: CollectibleDetailOptedInActionViewModel?,
        for theme: CollectibleDetailOptedInActionViewTheme,
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
        let optedInTitleHeight = theme.optedInTitleHeight
        let accountShareHeight = theme.accountShareHeight
        let separatorHeight = theme.separatorHeight

        let verticalSpacing =
            theme.topInset +
            theme.subtitleTopOffset +
            theme.buttonTopInset +
            theme.buttonBottomInset +
            theme.accountShareTopInset +
            theme.accountShareBottomInset

        let contentHeight =
            titleSize.height +
            subtitleSize.height +
            buttonHeight +
            optedInTitleHeight +
            accountShareHeight +
            separatorHeight +
            verticalSpacing

        return CGSize((size.width, min(contentHeight.ceil(), size.height)))
    }
}

extension CollectibleDetailOptedInActionView {
    enum Event {
        case performOptOut
        case performCopy
        case performShareQR
    }
}
