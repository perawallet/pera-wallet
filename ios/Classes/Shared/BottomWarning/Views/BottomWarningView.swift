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

//
//  BottomWarningView.swift

import UIKit
import MacaroonUIKit

final class BottomWarningView: View {
    lazy var handlers = Handlers()

    private lazy var titleLabel = Label()
    private lazy var imageView = ImageView()
    private lazy var descriptionLabel = ALGActiveLabel()
    private lazy var verticalStackView = MacaroonUIKit.VStackView()
    private lazy var primaryActionButton = MacaroonUIKit.Button()
    private lazy var secondaryActionButton = MacaroonUIKit.Button()

    override init(
        frame: CGRect
    ) {
        super.init(
            frame: frame
        )

        setListeners()
    }

    func customize(
        _ theme: BottomWarningViewTheme
    ) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addImageView(theme)
        addTitleLabel(theme)
        addDescriptionLabel(theme)
        addVerticalStackView(theme)
    }

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func setListeners() {
        primaryActionButton.addTouch(target: self, action: #selector(didTapPrimaryAction))
        secondaryActionButton.addTouch(target: self, action: #selector(didTapSecondaryAction))
    }
}

extension BottomWarningView {
    private func addImageView(
        _ theme: BottomWarningViewTheme
    ) {
        imageView.customizeAppearance(theme.image)

        addSubview(imageView)
        imageView.contentEdgeInsets = theme.imageContentInsets
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(theme.topInset)
        }
    }

    private func addTitleLabel(
        _ theme: BottomWarningViewTheme
    ) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addDescriptionLabel(
        _ theme: BottomWarningViewTheme
    ) {
        descriptionLabel.customizeAppearance(theme.description)

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.descriptionTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addVerticalStackView(
        _ theme: BottomWarningViewTheme
    ) {
        addSubview(verticalStackView)
        verticalStackView.spacing = theme.buttonInset

        verticalStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(theme.verticalInset)
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.verticalInset).priority(.medium)
            $0.bottom.lessThanOrEqualToSuperview().inset(theme.bottomInset)
        }

        addPrimaryActionButton(theme)
        addSecondaryActionButton(theme)
    }

    private func addPrimaryActionButton(
        _ theme: BottomWarningViewTheme
    ) {
        primaryActionButton.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)
        primaryActionButton.draw(corner: theme.actionCorner)
        primaryActionButton.customizeAppearance(theme.primaryAction)

        primaryActionButton.fitToVerticalIntrinsicSize()
        verticalStackView.addArrangedSubview(primaryActionButton)
    }

    private func addSecondaryActionButton(
        _ theme: BottomWarningViewTheme
    ) {
        secondaryActionButton.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)
        secondaryActionButton.draw(corner: theme.actionCorner)
        secondaryActionButton.customizeAppearance(theme.secondaryAction)

        secondaryActionButton.fitToVerticalIntrinsicSize()
        verticalStackView.addArrangedSubview(secondaryActionButton)
    }
}

extension BottomWarningView {
    func bindData(
        _ configurator: BottomWarningViewConfigurator?
    ) {
        guard let configurator = configurator else {
            return
        }

        imageView.image = configurator.image
        titleLabel.editText = configurator.title

        if let description = configurator.description {
            switch description {
            case .plain:
                descriptionLabel.editText = configurator.descriptionText
            case .custom(_, let markedWordWithHandler):
                customizeDescriptionLabel(
                    configurator,
                    for: markedWordWithHandler
                )
            }
        } else {
            descriptionLabel.removeFromSuperview()
        }

        primaryActionButton.isHidden = configurator.primaryActionButtonTitle == nil
        primaryActionButton.setEditTitle(
            configurator.primaryActionButtonTitle,
            for: .normal
        )

        secondaryActionButton.setEditTitle(
            configurator.secondaryActionButtonTitle,
            for: .normal
        )
    }

    private func customizeDescriptionLabel(
        _ configurator: BottomWarningViewConfigurator,
        for markedWordWithHandler: BottomWarningViewConfigurator.BottomWarningDescription.MarkedWordWithHandler
    ) {
        /// <ref>
        ///  https://github.com/optonaut/ActiveLabel.swift#batched-customization
        /// <note>
        /// It is recommended to use the customize(block:) method to customize it. The reason is that ActiveLabel is reacting to each property that you set. So if you set 3 properties, the textContainer is refreshed 3 times.
        descriptionLabel.customize { label in
            label.editText = configurator.descriptionText

            /// <note>
            /// Regex that looks for `hyperlink.word`
            let customPatternType = ALGActiveType.custom(
                pattern: "\\s\(markedWordWithHandler.word)\\b"
            ).mapped

            label.enabledTypes.append(customPatternType)

            label.configureLinkAttribute = { (_, _, _) in
                return configurator.getLinkAttributes()
            }

            label.handleCustomTap(for: customPatternType) { _ in
                markedWordWithHandler.handler()
            }
        }
    }
}

extension BottomWarningView {
    @objc
    private func didTapPrimaryAction() {
        handlers.didTapPrimaryActionButton?()
    }

    @objc
    private func didTapSecondaryAction() {
        handlers.didTapSecondaryActionButton?()
    }
}

extension BottomWarningView {
    struct Handlers {
        var didTapPrimaryActionButton: EmptyHandler?
        var didTapSecondaryActionButton: EmptyHandler?
    }
}
