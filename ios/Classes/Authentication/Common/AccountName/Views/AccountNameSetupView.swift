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
//  AccountNameSetupView.swift

import UIKit
import MacaroonUIKit
import MacaroonForm

final class AccountNameSetupView: View {
    weak var delegate: AccountNameSetupViewDelegate?

    private(set) lazy var accountNameInputView = createAccountNameTextInput(
        placeholder: "account-name-setup-explanation".localized,
        floatingPlaceholder: "account-name-setup-placeholder".localized
    )
    private lazy var titleLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private(set) lazy var nextButton = Button()

    func customize(_ theme: AccountNameSetupViewTheme) {
        addTitle(theme)
        addDescriptionLabel(theme)
        addAccountNameInputView(theme)
        addFinishAccountCreationButton(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func linkInteractors() {
        accountNameInputView.delegate = self
    }
    
    func setListeners() {
        nextButton.addTarget(self, action: #selector(notifyDelegateToFinishAccountCreation), for: .touchUpInside)
    }

    func bindData(_ name: String?) {
        accountNameInputView.text = name
    }
}

extension AccountNameSetupView {
    @objc
    func notifyDelegateToFinishAccountCreation() {
        delegate?.accountNameSetupViewDidFinishAccountCreation(self)
    }
}

extension AccountNameSetupView {
    private func addTitle(_ theme: AccountNameSetupViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topInset)
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addDescriptionLabel(_ theme: AccountNameSetupViewTheme) {
        descriptionLabel.customizeAppearance(theme.description)

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.bottomInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addAccountNameInputView(_ theme: AccountNameSetupViewTheme) {
        addSubview(accountNameInputView)
        accountNameInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(theme.textInputVerticalInset)
        }
    }

    private func addFinishAccountCreationButton(_ theme: AccountNameSetupViewTheme) {
        nextButton.customize(theme.mainButtonTheme)
        nextButton.bindData(ButtonCommonViewModel(title: "account-name-setup-finish".localized))

        addSubview(nextButton)
        nextButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.greaterThanOrEqualTo(accountNameInputView.snp.bottom).offset(theme.bottomInset)
            $0.bottom.equalToSuperview().inset(theme.bottomInset + safeAreaBottom)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }
}

extension AccountNameSetupView {
    func createAccountNameTextInput(
        placeholder: String,
        floatingPlaceholder: String?
    ) -> FloatingTextInputFieldView {
        let view = FloatingTextInputFieldView()
        let textInputBaseStyle: TextInputStyle = [
            .font(Fonts.DMSans.regular.make(15)),
            .tintColor(Colors.Text.main),
            .textColor(Colors.Text.main),
            .clearButtonMode(.whileEditing),
            .returnKeyType(.done),
            .autocapitalizationType(.words),
            .textContentType(.name)
        ]

        let theme =
            FloatingTextInputFieldViewCommonTheme(
                textInput: textInputBaseStyle,
                placeholder: placeholder,
                floatingPlaceholder: floatingPlaceholder
            )
        view.customize(theme)
        view.snp.makeConstraints {
            $0.greaterThanHeight(48)
        }
        return view
    }
}

extension AccountNameSetupView {
    func beginEditing() {
        accountNameInputView.beginEditing()
    }
}

extension AccountNameSetupView: FloatingTextInputFieldViewDelegate {
    func floatingTextInputFieldViewShouldReturn(_ view: FloatingTextInputFieldView) -> Bool {
        view.endEditing()
        return true
    }
}

protocol AccountNameSetupViewDelegate: AnyObject {
    func accountNameSetupViewDidFinishAccountCreation(_ accountNameSetupView: AccountNameSetupView)
    func accountNameSetupViewDidChangeValue(_ accountNameSetupView: AccountNameSetupView)
}
