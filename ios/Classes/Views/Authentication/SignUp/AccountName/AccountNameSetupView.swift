// Copyright 2019 Algorand, Inc.

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

class AccountNameSetupView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AccountNameSetupViewDelegate?
    
    private(set) lazy var accountNameInputView: SingleLineInputField = {
        let accountNameInputView = SingleLineInputField()
        accountNameInputView.explanationLabel.text = "account-name-setup-explanation".localized
        accountNameInputView.placeholderText = "account-name-setup-placeholder".localized
        accountNameInputView.nextButtonMode = .submit
        accountNameInputView.inputTextField.autocorrectionType = .no
        return accountNameInputView
    }()

    private lazy var descriptionLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.secondary)
            .withLine(.contained)
            .withAlignment(.left)
            .withText("account-name-setup-description".localized)
    }()

    private(set) lazy var nextButton = MainButton(title: "account-name-setup-finish".localized)
    
    override func linkInteractors() {
        accountNameInputView.delegate = self
    }
    
    override func setListeners() {
        nextButton.addTarget(self, action: #selector(notifyDelegateToFinishAccountCreation), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupAccountNameInputViewLayout()
        setupDescriptionLabelLayout()
        setupNextButtonLayout()
    }
}

extension AccountNameSetupView {
    @objc
    func notifyDelegateToFinishAccountCreation() {
        delegate?.accountNameSetupViewDidFinishAccountCreation(self)
    }
}

extension AccountNameSetupView {
    private func setupAccountNameInputViewLayout() {
        addSubview(accountNameInputView)
        
        accountNameInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }

    private func setupDescriptionLabelLayout() {
        addSubview(descriptionLabel)

        descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(accountNameInputView.snp.bottom).offset(layout.current.verticalInset)
        }
    }

    private func setupNextButtonLayout() {
        addSubview(nextButton)
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(layout.current.buttonVerticalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.verticalInset + safeAreaBottom)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerX.equalToSuperview()
        }
    }
}

extension AccountNameSetupView {
    func beginEditing() {
        accountNameInputView.beginEditing()
    }
}

extension AccountNameSetupView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 20.0
        let buttonVerticalInset: CGFloat = 60.0
        let horizontalInset: CGFloat = 20.0
    }
}

extension AccountNameSetupView: InputViewDelegate {
    func inputViewDidChangeValue(inputView: BaseInputView) {
        delegate?.accountNameSetupViewDidChangeValue(self)
    }
}

protocol AccountNameSetupViewDelegate: AnyObject {
    func accountNameSetupViewDidFinishAccountCreation(_ accountNameSetupView: AccountNameSetupView)
    func accountNameSetupViewDidChangeValue(_ accountNameSetupView: AccountNameSetupView)
}
