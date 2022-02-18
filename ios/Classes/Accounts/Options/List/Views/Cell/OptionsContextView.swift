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
//  OptionsContextView.swift

import UIKit
import MacaroonUIKit

final class OptionsContextView: View {
    private lazy var iconImageView = UIImageView()
    private lazy var verticalStackView = UIStackView()
    private lazy var optionTitleLabel = UILabel()
    private lazy var optionSubtitleLabel = UILabel()

    func customize(_ theme: OptionsContextViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addIconImageView(theme)
        addVerticalStackView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension OptionsContextView {
    private func addIconImageView(_ theme: OptionsContextViewTheme) {
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addVerticalStackView(_ theme: OptionsContextViewTheme) {
        verticalStackView.axis = .vertical
        verticalStackView.spacing = theme.verticalStackViewSpacing

        addSubview(verticalStackView)
        verticalStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.labelLeftInset)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
        }

        addOptionTitleLabel(theme)
        addOptionSubtitleLabel(theme)
    }

    private func addOptionTitleLabel(_ theme: OptionsContextViewTheme) {
        optionTitleLabel.customizeAppearance(theme.titleLabel)

        verticalStackView.addArrangedSubview(optionTitleLabel)
    }

    private func addOptionSubtitleLabel(_ theme: OptionsContextViewTheme) {
        optionSubtitleLabel.customizeAppearance(theme.subtitleLabel)

        verticalStackView.addArrangedSubview(optionSubtitleLabel)
    }
}

extension OptionsContextView {
    func bind(_ viewModel: OptionsViewModel) {
        iconImageView.image = viewModel.image
        optionTitleLabel.text = viewModel.title
        optionTitleLabel.textColor = viewModel.titleColor

        if let subtitle = viewModel.subtitle {
            optionSubtitleLabel.text = subtitle
        } else {
            optionSubtitleLabel.isHidden = true
        }
    }

    func bind(_ viewModel: AccountRecoverOptionsViewModel) {
        iconImageView.image = viewModel.image
        optionTitleLabel.text = viewModel.title
    }
}
