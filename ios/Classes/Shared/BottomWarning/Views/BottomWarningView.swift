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
    weak var delegate: BottomWarningViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var imageView = UIImageView()
    private lazy var descriptionLabel = UILabel()
    private lazy var verticalStackView = UIStackView()
    private lazy var primaryActionButton = Button()
    private lazy var secondaryActionButton = Button()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setListeners()
    }

    func customize(_ theme: BottomWarningViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addImageView(theme)
        addTitleLabel(theme)
        addDescriptionLabel(theme)
        addVerticalStackView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func setListeners() {
        primaryActionButton.addTarget(self, action: #selector(notifyDelegateToHandlePrimaryActionButton), for: .touchUpInside)
        secondaryActionButton.addTarget(self, action: #selector(notifyDelegateToHandleSecondaryActionButton), for: .touchUpInside)
    }
}

extension BottomWarningView {
    private func addImageView(_ theme: BottomWarningViewTheme) {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(theme.topInset)
        }
    }

    private func addTitleLabel(_ theme: BottomWarningViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(theme.titleTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addDescriptionLabel(_ theme: BottomWarningViewTheme) {
        descriptionLabel.customizeAppearance(theme.description)

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.descriptionTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addVerticalStackView(_ theme: BottomWarningViewTheme) {
        addSubview(verticalStackView)
        verticalStackView.spacing = theme.buttonInset
        verticalStackView.axis = .vertical

        verticalStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(theme.verticalInset)
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.verticalInset).priority(.medium)
            $0.bottom.lessThanOrEqualToSuperview().inset(theme.bottomInset)
        }

        addPrimaryActionButton(theme)
        addSecondaryActionButton(theme)
    }

    private func addPrimaryActionButton(_ theme: BottomWarningViewTheme) {
        primaryActionButton.customize(theme.mainButtonTheme)

        primaryActionButton.fitToVerticalIntrinsicSize()
        verticalStackView.addArrangedSubview(primaryActionButton)
    }

    private func addSecondaryActionButton(_ theme: BottomWarningViewTheme) {
        secondaryActionButton.customize(theme.secondaryButtonTheme)

        secondaryActionButton.fitToVerticalIntrinsicSize()
        verticalStackView.addArrangedSubview(secondaryActionButton)
    }
}

extension BottomWarningView {
    func bindData(_ configurator: BottomWarningViewConfigurator?) {
        titleLabel.editText = configurator?.title

        if let description = configurator?.description {
            descriptionLabel.editText = description
        } else {
            descriptionLabel.removeFromSuperview()
        }

        imageView.image = configurator?.image
        primaryActionButton.bindData(ButtonCommonViewModel(title: configurator?.primaryActionButtonTitle))

        if let secondaryActionButtonTitle = configurator?.secondaryActionButtonTitle {
            secondaryActionButton.bindData(ButtonCommonViewModel(title: secondaryActionButtonTitle))
        } else {
            secondaryActionButton.isHidden = true
        }
    }
}

extension BottomWarningView {
    @objc
    private func notifyDelegateToHandlePrimaryActionButton() {
        delegate?.bottomWarningViewDidTapPrimaryActionButton(self)
    }

    @objc
    private func notifyDelegateToHandleSecondaryActionButton() {
        delegate?.bottomWarningViewDidTapSecondaryActionButton(self)
    }
}

protocol BottomWarningViewDelegate: AnyObject {
    func bottomWarningViewDidTapPrimaryActionButton(_ bottomWarningView: BottomWarningView)
    func bottomWarningViewDidTapSecondaryActionButton(_ bottomWarningView: BottomWarningView)
}
