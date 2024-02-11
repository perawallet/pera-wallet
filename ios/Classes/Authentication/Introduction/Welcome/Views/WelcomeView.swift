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

final class WelcomeView:
    View,
    ViewModelBindable {
    weak var delegate: WelcomeViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var stackView = UIStackView()
    private lazy var termsAndConditionsTextView = UITextView()
    private lazy var createAccountView = AccountTypeView()
    private lazy var importAccountView = AccountTypeView()
    private lazy var watchAccountView = AccountTypeView()

    func customize(_ theme: WelcomeViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addTitle(theme)
        addTermsAndConditionsTextView(theme)
        addStackView(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func setListeners() {
        createAccountView.addTarget(
            self,
            action: #selector(notifyDelegateToCreateAccount),
            for: .touchUpInside
        )

        importAccountView.addTarget(
            self,
            action: #selector(notifyDelegateToImportAccount),
            for: .touchUpInside
        )
        
        watchAccountView.addTarget(
            self,
            action: #selector(notifyDelegateToWatchAccount),
            for: .touchUpInside
        )
    }

    func linkInteractors() {
        termsAndConditionsTextView.delegate = self
    }

    func bindData(_ viewModel: WelcomeViewModel?) {
        titleLabel.text = viewModel?.title
        createAccountView.bindData(viewModel?.createAccountViewModel)
        importAccountView.bindData(viewModel?.importAccountViewModel)
        watchAccountView.bindData(viewModel?.watchAccountViewModel)
    }
}

extension WelcomeView {
    @objc
    private func notifyDelegateToCreateAccount() {
        delegate?.welcomeViewDidSelectCreate(self)
    }

    @objc
    private func notifyDelegateToImportAccount() {
        delegate?.welcomeViewDidSelectImport(self)
    }
    
    @objc
    private func notifyDelegateToWatchAccount() {
        delegate?.welcomeViewDidSelectWatch(self)
    }
}

extension WelcomeView {
    private func addTitle(_ theme: WelcomeViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
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
            "introduction-title-terms-and-services".localized(params: AlgorandWeb.termsAndServices.rawValue, AlgorandWeb.privacyPolicy.rawValue),
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

        createAccountView.customize(theme.accountTypeViewTheme)
        stackView.addArrangedSubview(createAccountView)
        importAccountView.customize(theme.accountTypeViewTheme)
        stackView.addArrangedSubview(importAccountView)
        watchAccountView.customize(theme.accountTypeViewTheme)
        stackView.addArrangedSubview(watchAccountView)
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

protocol WelcomeViewDelegate: AnyObject {
    func welcomeViewDidSelectCreate(_ welcomeView: WelcomeView)
    func welcomeViewDidSelectImport(_ welcomeView: WelcomeView)
    func welcomeViewDidSelectWatch(_ welcomeView: WelcomeView)
    func welcomeView(_ welcomeView: WelcomeView, didOpen url: URL)
}
