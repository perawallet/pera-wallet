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
//  EditAccountView.swift

import UIKit
import MacaroonUIKit

final class EditAccountView: View {
    weak var delegate: EditAccountViewDelegate?

    private(set) lazy var accountNameInputView = createAccountNameTextInput(
        placeholder: "account-name-setup-placeholder".localized,
        floatingPlaceholder: "account-name-setup-placeholder".localized
    )

    private lazy var doneButton = MacaroonUIKit.Button()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setListeners()
        linkInteractors()
    }

    func customize(_ theme: EditAccountViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addAccountNameInputView(theme)
        addDoneButton(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func linkInteractors() {
        accountNameInputView.delegate = self
    }

    func setListeners() {
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
    }
}

extension EditAccountView {
    @objc
    func didTapDoneButton() {
        delegate?.editAccountViewDidTapDoneButton(self)
    }
}

extension EditAccountView {
    private func addAccountNameInputView(_ theme: EditAccountViewTheme) {
        addSubview(accountNameInputView)
        accountNameInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalToSuperview().offset(theme.verticalPadding)
        }
    }

    private func addDoneButton(_ theme: EditAccountViewTheme) {
        doneButton.contentEdgeInsets = UIEdgeInsets(theme.doneButtonContentEdgeInsets)
        doneButton.draw(corner: theme.doneButtonCorner)
        doneButton.customizeAppearance(theme.doneButton)

        addSubview(doneButton)
        doneButton.fitToVerticalIntrinsicSize()
        doneButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.greaterThanOrEqualTo(accountNameInputView.snp.bottom).offset(theme.verticalPadding)
            $0.bottom.equalToSuperview().inset(theme.verticalPadding + safeAreaBottom)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
}

extension EditAccountView {
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

extension EditAccountView {
    func bindData(_ name: String?) {
        accountNameInputView.text = name
    }
}

extension EditAccountView {
    func beginEditing() {
        accountNameInputView.beginEditing()
    }

    func endEditing() {
        accountNameInputView.endEditing()
    }
}

extension EditAccountView: FloatingTextInputFieldViewDelegate {
    func floatingTextInputFieldViewShouldReturn(_ view: FloatingTextInputFieldView) -> Bool {
        guard let delegate = delegate else {
            return true
        }
        
        view.endEditing()
        delegate.editAccountViewDidTapDoneButton(self)
        return false
    }
}

protocol EditAccountViewDelegate: AnyObject {
    func editAccountViewDidTapDoneButton(_ editAccountView: EditAccountView)
}
