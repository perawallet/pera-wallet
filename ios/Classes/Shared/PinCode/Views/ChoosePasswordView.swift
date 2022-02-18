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
//  ChoosePasswordView.swift

import UIKit
import MacaroonUIKit
import Foundation

final class ChoosePasswordView: View {
    weak var delegate: ChoosePasswordViewDelegate?

    private(set) lazy var titleLabel = UILabel()
    private(set) lazy var passwordInputView = PasswordInputView()
    private(set) lazy var numpadView = NumpadView()
    
    func customize(_ theme: ChoosePasswordViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addTitleLabel(theme)
        addPasswordView(theme)
        addNumpadView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func linkInteractors() {
        numpadView.linkInteractors()
        numpadView.delegate = self
    }
}

extension ChoosePasswordView {
    private func addTitleLabel(_ theme: ChoosePasswordViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.topInset)
        }
    }
    
    private func addPasswordView(_ theme: ChoosePasswordViewTheme) {
        addSubview(passwordInputView)
        passwordInputView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.inputViewTopInset)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func addNumpadView(_ theme: ChoosePasswordViewTheme) {
        numpadView.customize(theme.numpadViewTheme)

        addSubview(numpadView)
        numpadView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(theme.numpadBottomInset + safeAreaBottom)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.lessThanOrEqualToSuperview()
        }
    }
}

extension ChoosePasswordView {
    func shake(
        then handler: @escaping EmptyHandler
    ) {
        passwordInputView.shake(then: handler)
    }

    func changeStateTo(
        _ state: PasswordInputCircleView.State
    ) {
        passwordInputView.changeStateTo(state)
    }

    func toggleDeleteButtonVisibility(
        for isHidden: Bool
    ) {
        numpadView.deleteButtonIsHidden = isHidden
    }
}

extension ChoosePasswordView: NumpadViewDelegate {
    func numpadView(_ numpadView: NumpadView, didSelect value: NumpadButton.NumpadKey) {
        delegate?.choosePasswordView(self, didSelect: value)
    }
}

protocol ChoosePasswordViewDelegate: AnyObject {
    func choosePasswordView(_ choosePasswordView: ChoosePasswordView, didSelect value: NumpadButton.NumpadKey)
}
