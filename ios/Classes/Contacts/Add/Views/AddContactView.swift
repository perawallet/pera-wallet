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
//  AddContactView.swift

import UIKit
import MacaroonUIKit

final class AddContactView: View {
    weak var delegate: AddContactViewDelegate?

    private(set) lazy var badgedImageView = BadgedImageView()
    private lazy var addPhotoLabel = UILabel()
    private(set) lazy var nameInputView = createAccountNameTextInput(
        placeholder: "contacts-input-name-placeholder".localized,
        floatingPlaceholder: "contacts-input-name-placeholder".localized.capitalized
    )
    private(set) lazy var addressInputView = createAddressTextInput(
        placeholder: "contact-input-address-placeholder".localized,
        floatingPlaceholder: "contact-input-address-placeholder".localized.capitalized
    )
    private lazy var qrButton = Button()
    private(set) lazy var addContactButton = Button()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setListeners()
    }

    func customize(_ theme: AddContactViewTheme) {
        addBadgedImageView(theme)
        addPhotoLabel(theme)
        addNameInputView(theme)
        addAddressInputView(theme)
        addQrButton(theme)
        addAddButton(theme)
    }

    func prepareLayout(_ layoutSheet: AddContactViewTheme) {}

    func customizeAppearance(_ styleSheet: AddContactViewTheme) {}

    func setListeners() {
        qrButton.addTarget(self, action: #selector(notifyDelegateToOpenQrScanner), for: .touchUpInside)
        badgedImageView.addTarget(self, action: #selector(didDelegateToAddImage), for: .touchUpInside)
        addContactButton.addTarget(self, action: #selector(notifyDelegateToAddContact), for: .touchUpInside)
    }
}

extension AddContactView {
    @objc
    private func didDelegateToAddImage() {
        delegate?.addContactViewDidTapAddImageButton(self)
    }

    @objc
    private func notifyDelegateToAddContact() {
        delegate?.addContactViewDidTapAddContactButton(self)
    }

    @objc
    func notifyDelegateToOpenQrScanner() {
        delegate?.addContactViewDidTapQRCodeButton(self)
    }
}

extension AddContactView {
    private func addBadgedImageView(_ theme: AddContactViewTheme) {
        badgedImageView.customize(BadgedImageViewTheme())

        addSubview(badgedImageView)
        badgedImageView.snp.makeConstraints {
            $0.centerX == 0
            $0.top.equalToSuperview().inset(theme.badgedImageViewTopPadding)
        }
    }

    private func addPhotoLabel(_ theme: AddContactViewTheme) {
        addPhotoLabel.customizeAppearance(theme.photoLabel)

        addSubview(addPhotoLabel)
        addPhotoLabel.snp.makeConstraints {
            $0.top.equalTo(badgedImageView.snp.bottom).offset(theme.addPhotoLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addNameInputView(_ theme: AddContactViewTheme) {
        addSubview(nameInputView)
        nameInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(addPhotoLabel.snp.bottom).offset(theme.inputTopPadding)
        }
    }

    private func addAddressInputView(_ theme: AddContactViewTheme) {
        addSubview(addressInputView)
        addressInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(nameInputView.snp.bottom).offset(theme.inputSpacing)
        }
    }

    private func addQrButton(_ theme: AddContactViewTheme) {
        qrButton.customizeAppearance(theme.qrButton)
        
        addressInputView.addRightAccessoryItem(qrButton)
    }
    
    private func addAddButton(_ theme: AddContactViewTheme) {
        addContactButton.customize(theme.addContactButtonViewTheme)
        addContactButton.bindData(ButtonCommonViewModel(title: "contacts-add".localized))

        addSubview(addContactButton)
        addContactButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(addressInputView.snp.bottom).offset(theme.topPadding)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(theme.bottomPadding + safeAreaBottom)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
}

extension AddContactView {
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
            .returnKeyType(.next)
        ]

        let theme =
            FloatingTextInputFieldViewCommonTheme(
                textInput: textInputBaseStyle,
                placeholder: placeholder,
                floatingPlaceholder: floatingPlaceholder
            )
        view.delegate = self
        view.customize(theme)
        view.snp.makeConstraints {
            $0.greaterThanHeight(48)
        }
        return view
    }
    
    func createAddressTextInput(
        placeholder: String,
        floatingPlaceholder: String?
    ) -> MultilineTextInputFieldView {
        let view = MultilineTextInputFieldView()
        let textInputBaseStyle: TextInputStyle = [
            .font(Fonts.DMSans.regular.make(15)),
            .tintColor(Colors.Text.main),
            .textColor(Colors.Text.main),
            .returnKeyType(.done)
        ]

        let theme =
            MultilineTextInputFieldViewCommonTheme(
                textInput: textInputBaseStyle,
                placeholder: placeholder,
                floatingPlaceholder: floatingPlaceholder
            )
        view.delegate = self
        view.customize(theme)
        view.snp.makeConstraints {
            $0.greaterThanHeight(48)
        }
        return view
    }
}

extension AddContactView: FloatingTextInputFieldViewDelegate {
    func floatingTextInputFieldViewShouldReturn(_ view: FloatingTextInputFieldView) -> Bool {
        guard let delegate = delegate else {
            return true
        }

        return delegate.addContactViewInputFieldViewShouldReturn(self, inputFieldView: view)
    }
}

extension AddContactView: MultilineTextInputFieldViewDelegate {
    func multilineTextInputFieldViewDidReturn(_ view: MultilineTextInputFieldView) {
        view.endEditing()
    }
}

protocol AddContactViewDelegate: AnyObject {
    func addContactViewDidTapAddContactButton(_ addContactView: AddContactView)
    func addContactViewDidTapAddImageButton(_ addContactView: AddContactView)
    func addContactViewDidTapQRCodeButton(_ addContactView: AddContactView)
    func addContactViewInputFieldViewShouldReturn(
        _ addContactView: AddContactView,
        inputFieldView: FloatingTextInputFieldView
    ) -> Bool
}
