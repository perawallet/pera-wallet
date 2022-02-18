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
//  WelcomeView.swift

import UIKit
import MacaroonUIKit
import Foundation

final class WelcomeView: View {
    weak var delegate: WelcomeViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var stackView = UIStackView()
    private lazy var termsAndConditionsTextView = UITextView()
    private lazy var addAccountView = AccountTypeView()
    private lazy var recoverAccountView = AccountTypeView()

    func customize(_ theme: WelcomeViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addTitle(theme)
        addTermsAndConditionsTextView(theme)
        addStackView(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func setListeners() {
        addAccountView.addTarget(self, action: #selector(notifyDelegateToAddAccount), for: .touchUpInside)
        recoverAccountView.addTarget(self, action: #selector(notifyDelegateToRecoverAccount), for: .touchUpInside)
    }

    func linkInteractors() {
        termsAndConditionsTextView.delegate = self
    }
}

extension WelcomeView {
    @objc
    private func notifyDelegateToAddAccount() {
        delegate?.welcomeViewDidSelectAdd(self)
    }

    @objc
    private func notifyDelegateToRecoverAccount() {
        delegate?.welcomeViewDidSelectRecover(self)
    }
}

extension WelcomeView {
    private func addTitle(_ theme: WelcomeViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.topInset)
        }
    }

    private func addTermsAndConditionsTextView(_ theme: WelcomeViewTheme) {
        termsAndConditionsTextView.isEditable = false
        termsAndConditionsTextView.isScrollEnabled = false
        termsAndConditionsTextView.dataDetectorTypes = .link
        termsAndConditionsTextView.textContainerInset = .zero
        termsAndConditionsTextView.backgroundColor = .clear
        termsAndConditionsTextView.linkTextAttributes = theme.termsOfConditionsLinkAttributes.asSystemAttributes()
        termsAndConditionsTextView.bindHTML(
            "introduction-title-terms-and-services".localized,
            attributes: theme.termsOfConditionsAttributes.asSystemAttributes()
        )

        addSubview(termsAndConditionsTextView)
        termsAndConditionsTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.verticalInset)
            $0.centerX.equalToSuperview()
        }
    }

    private func addStackView(_ theme: WelcomeViewTheme) {
        stackView.axis = .vertical

        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.trailing.centerY.equalToSuperview()
            $0.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(theme.verticalInset)
            $0.bottom.lessThanOrEqualTo(termsAndConditionsTextView.snp.top).offset(-theme.verticalInset)
        }

        addAccountView.customize(theme.accountTypeViewTheme)
        stackView.addArrangedSubview(addAccountView)
        recoverAccountView.customize(theme.accountTypeViewTheme)
        stackView.addArrangedSubview(recoverAccountView)
    }
}

extension WelcomeView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        delegate?.welcomeView(self, didOpen: URL)
        return false
    }
}

extension WelcomeView {
    func bindAddAccountView(_ viewModel: AccountTypeViewModel) {
        addAccountView.bindData(viewModel)
    }

    func bindRecoverAccountView(_ viewModel: AccountTypeViewModel) {
        recoverAccountView.bindData(viewModel)
    }
}

protocol WelcomeViewDelegate: AnyObject {
    func welcomeViewDidSelectAdd(_ welcomeView: WelcomeView)
    func welcomeViewDidSelectRecover(_ welcomeView: WelcomeView)
    func welcomeView(_ welcomeView: WelcomeView, didOpen url: URL)
}
