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
//   LedgerAccountVerificationView.swift

import UIKit
import MacaroonUIKit

final class LedgerAccountVerificationView: View {
    private lazy var verticalStackView = UIStackView()
    private lazy var imageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var accountVerificationsStackView = UIStackView()

    func customize(_ theme: LedgerAccountVerificationViewTheme) {
        addVerticalStackView(theme)
        addAccountVerificationsStackView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension LedgerAccountVerificationView {
    private func addVerticalStackView(_ theme: LedgerAccountVerificationViewTheme) {
        addSubview(verticalStackView)
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .center
        verticalStackView.spacing = theme.verticalStackViewSpacing
        verticalStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(theme.verticalStackViewTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }

        addImageView(theme)
        addTitleLabel(theme)
        addDescriptionLabel(theme)
    }

    private func addImageView(_ theme: LedgerAccountVerificationViewTheme) {
        imageView.customizeAppearance(theme.image)

        verticalStackView.addArrangedSubview(imageView)
        verticalStackView.setCustomSpacing(theme.titleLabelTopPadding, after: imageView)
    }

    private func addTitleLabel(_ theme: LedgerAccountVerificationViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        verticalStackView.addArrangedSubview(titleLabel)
    }

    private func addDescriptionLabel(_ theme: LedgerAccountVerificationViewTheme) {
        descriptionLabel.customizeAppearance(theme.description)

        verticalStackView.addArrangedSubview(descriptionLabel)
    }

    private func addAccountVerificationsStackView(_ theme: LedgerAccountVerificationViewTheme) {
        accountVerificationsStackView.distribution = .fillEqually
        accountVerificationsStackView.spacing = theme.accountVerificationsStackViewVerticalPadding
        accountVerificationsStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        accountVerificationsStackView.axis = .vertical

        addSubview(accountVerificationsStackView)
        accountVerificationsStackView.snp.makeConstraints {
            $0.top.equalTo(verticalStackView.snp.bottom).offset(theme.accountVerificationListTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.bottom.equalToSuperview()
        }
    }
}

extension LedgerAccountVerificationView {
    func addArrangedSubview(_ statusView: LedgerAccountVerificationStatusView) {
        accountVerificationsStackView.addArrangedSubview(statusView)
    }

    var isStackViewEmpty: Bool {
        return accountVerificationsStackView.arrangedSubviews.isEmpty
    }

    var statusViews: [UIView] {
        return accountVerificationsStackView.arrangedSubviews
    }
}
