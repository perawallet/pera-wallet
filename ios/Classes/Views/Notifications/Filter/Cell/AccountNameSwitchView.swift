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
//  AccountNameSwitchView.swift

import UIKit

class AccountNameSwitchView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: AccountNameSwitchViewDelegate?

    private lazy var accountNameView = AccountNameView()

    private lazy var toggleView = Toggle()

    private lazy var separatorView = LineSeparatorView()

    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }

    override func setListeners() {
        toggleView.addTarget(self, action: #selector(notifyDelegateToToggleValueChanged), for: .touchUpInside)
    }

    override func prepareLayout() {
        setupToggleViewLayout()
        setupAccountNameViewLayout()
        setupSeparatorViewLayout()
    }
}

extension AccountNameSwitchView {
    @objc
    private func notifyDelegateToToggleValueChanged() {
        delegate?.accountNameSwitchView(self, didChangeToggleValue: toggleView.isOn)
    }
}

extension AccountNameSwitchView {
    private func setupToggleViewLayout() {
        addSubview(toggleView)

        toggleView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }

    private func setupAccountNameViewLayout() {
        addSubview(accountNameView)

        accountNameView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(toggleView.snp.leading).offset(-layout.current.horizontalInset)
        }
    }

    private func setupSeparatorViewLayout() {
        addSubview(separatorView)

        separatorView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
}

extension AccountNameSwitchView {
    func bind(_ viewModel: AccountNameSwitchViewModel) {
        accountNameView.bind(viewModel.accountNameViewModel)
        toggleView.setOn(viewModel.isSelected, animated: true)
        separatorView.isHidden = viewModel.isSeparatorHidden
    }
}

extension AccountNameSwitchView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
        let horizontalInset: CGFloat = 20.0
    }
}

protocol AccountNameSwitchViewDelegate: AnyObject {
    func accountNameSwitchView(_ accountNameSwitchView: AccountNameSwitchView, didChangeToggleValue value: Bool)
}
