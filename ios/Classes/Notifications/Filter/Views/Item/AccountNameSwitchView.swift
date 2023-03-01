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
//  AccountNameSwitchView.swift

import UIKit
import MacaroonUIKit

final class AccountNameSwitchView: View {
    weak var delegate: AccountNameSwitchViewDelegate?

    private lazy var accountNameView = ImageWithTitleView()
    private lazy var toggleView = Toggle()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setListeners()
    }

    func customize(_ theme: AccountNameSwitchViewTheme) {
        addToggleView(theme)
        addAccountNameView(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func setListeners() {
       toggleView.addTarget(self, action: #selector(notifyDelegateToToggleValueChanged), for: .touchUpInside)
   }
}

extension AccountNameSwitchView {
    @objc
    private func notifyDelegateToToggleValueChanged() {
        delegate?.accountNameSwitchView(self, didChangeToggleValue: toggleView.isOn)
    }
}

extension AccountNameSwitchView {
    private func addToggleView(_ theme: AccountNameSwitchViewTheme) {
        toggleView.customize(theme.toggle)

        addSubview(toggleView)
        toggleView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.centerY.equalToSuperview()
        }
    }

    private func addAccountNameView(_ theme: AccountNameSwitchViewTheme) {
        accountNameView.customize(SwitchAccountNameViewTheme())
        
        addSubview(accountNameView)
        accountNameView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(toggleView.snp.leading).offset(-theme.horizontalPadding)
        }
    }
}

extension AccountNameSwitchView: ViewModelBindable {
    func bindData(_ viewModel: AccountNameSwitchViewModel?) {
        accountNameView.bindData(viewModel?.accountNameViewModel)
        toggleView.setOn(viewModel?.isSelected ?? false, animated: true)
    }
}

protocol AccountNameSwitchViewDelegate: AnyObject {
    func accountNameSwitchView(_ accountNameSwitchView: AccountNameSwitchView, didChangeToggleValue value: Bool)
}
