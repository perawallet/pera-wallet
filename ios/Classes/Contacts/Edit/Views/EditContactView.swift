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
//   EditContactView.swift

import UIKit
import MacaroonUIKit

final class EditContactView: View {
    weak var delegate: EditContactViewDelegate?

    private(set) lazy var badgedImageView = BadgedImageView()
    private(set) lazy var nameInputView = createAccountNameTextInput(
        placeholder: "contacts-input-name-placeholder".localized,
        floatingPlaceholder: "contacts-input-name-placeholder".localized.capitalized
    )
    private(set) lazy var addressInputView = createAddressTextInput(
        placeholder: "contact-input-address-placeholder".localized,
        floatingPlaceholder: "contact-input-address-placeholder".localized.capitalized
    )
    private lazy var qrButton = Button()
    private(set) lazy var deleteContactButton = Button()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setListeners()
    }

    func customize(_ theme: EditContactViewTheme) {
        addBadgedImageView(theme)
        addNameInputView(theme)
        addAddressInputView(theme)
        addQrButton(theme)
        addDeleteContactButton(theme)
    }

    func prepareLayout(_ layoutSheet: EditContactViewTheme) {}

    func customizeAppearance(_ styleSheet: EditContactViewTheme) {}

    func setListeners() {
        qrButton.addTarget(self, action: #selector(notifyDelegateToOpenQrScanner), for: .touchUpInside)
        badgedImageView.addTarget(self, action: #selector(didDelegateToAddImage), for: .touchUpInside)
        deleteContactButton.addTarget(self, action: #selector(notifyDelegateToDeleteContact), for: .touchUpInside)
    }
}

extension EditContactView {
    @objc
    private func didDelegateToAddImage() {
        delegate?.editContactViewDidTapAddImageButton(self)
    }

    @objc
    private func notifyDelegateToDeleteContact() {
        delegate?.editContactViewDidTapDeleteButton(self)
    }

    @objc
    func notifyDelegateToOpenQrScanner() {
        delegate?.editContactViewDidTapQRCodeButton(self)
    }
}

extension EditContactView {
    private func addBadgedImageView(_ theme: EditContactViewTheme) {
        badgedImageView.customize(BadgedImageViewTheme())

        addSubview(badgedImageView)
        badgedImageView.snp.makeConstraints {
            $0.centerX == 0
            $0.top.equalToSuperview().inset(theme.badgedImageViewTopPadding)
        }
    }

    private func addNameInputView(_ theme: EditContactViewTheme) {
        addSubview(nameInputView)
        nameInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(badgedImageView.snp.bottom).offset(theme.inputTopPadding)
        }
    }

    private func addAddressInputView(_ theme: EditContactViewTheme) {
        addSubview(addressInputView)
        addressInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(nameInputView.snp.bottom).offset(theme.inputSpacing)
        }
    }

    private func addQrButton(_ theme: EditContactViewTheme) {
        qrButton.customizeAppearance(theme.qrButton)

        addressInputView.addRightAccessoryItem(qrButton)
    }

    private func addDeleteContactButton(_ theme: EditContactViewTheme) {
        deleteContactButton.draw(corner: theme.deleteButtonCorner)
        deleteContactButton.customizeAppearance(theme.deleteButton)

        addSubview(deleteContactButton)
        deleteContactButton.snp.makeConstraints {
            $0.top.equalTo(addressInputView.snp.bottom).offset(theme.topPadding)
            $0.centerX.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview().inset(theme.bottomPadding + safeAreaBottom)
            $0.fitToSize(theme.deleteButtonSize)
        }
    }
}

extension EditContactView {
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

extension EditContactView: ViewModelBindable {
    func bindData(_ viewModel: EditContactViewModel?) {
        badgedImageView.bindData(image: viewModel?.image, badgeImage: viewModel?.badgeImage)
        nameInputView.text = viewModel?.name
        addressInputView.text = viewModel?.address
    }
}

extension EditContactView: FloatingTextInputFieldViewDelegate {
    func floatingTextInputFieldViewShouldReturn(_ view: FloatingTextInputFieldView) -> Bool {
        guard let delegate = delegate else {
            return true
        }

        return delegate.editContactViewInputFieldViewShouldReturn(self, inputFieldView: view)
    }
}

extension EditContactView: MultilineTextInputFieldViewDelegate {
    func multilineTextInputFieldViewDidReturn(_ view: MultilineTextInputFieldView) {
        view.endEditing()
    }
}

protocol EditContactViewDelegate: AnyObject {
    func editContactViewDidTapDeleteButton(_ editContactView: EditContactView)
    func editContactViewDidTapAddImageButton(_ editContactView: EditContactView)
    func editContactViewDidTapQRCodeButton(_ editContactView: EditContactView)
    func editContactViewInputFieldViewShouldReturn(
        _ editContactView: EditContactView,
        inputFieldView: FloatingTextInputFieldView
    ) -> Bool
}
