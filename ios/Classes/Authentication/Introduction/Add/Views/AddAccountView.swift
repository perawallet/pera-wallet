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
//  AddAccountView.swift

import UIKit
import MacaroonUIKit
import Foundation

final class AddAccountView: View {
    weak var delegate: AddAccountViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var stackView = UIStackView()
    private lazy var createNewAccountView = AccountTypeView()
    private lazy var watchAccountView = AccountTypeView()
    private lazy var pairAccountView = AccountTypeView()

    func customize(_ theme: AddAccountViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addTitleLabel(theme)
        addStackView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func setListeners() {
        createNewAccountView.addTarget(self, action: #selector(notifyDelegateToSelectCreateNewAccount), for: .touchUpInside)
        watchAccountView.addTarget(self, action: #selector(notifyDelegateToSelectWatchAccount), for: .touchUpInside)
        pairAccountView.addTarget(self, action: #selector(notifyDelegateToSelectPairAccount), for: .touchUpInside)
    }
}

extension AddAccountView {
    @objc
    private func notifyDelegateToSelectCreateNewAccount() {
        delegate?.addAccountView(self, didSelect: .create)
    }

    @objc
    private func notifyDelegateToSelectWatchAccount() {
        delegate?.addAccountView(self, didSelect: .watch)
    }

    @objc
    private func notifyDelegateToSelectPairAccount() {
        delegate?.addAccountView(self, didSelect: .pair)
    }
}

extension AddAccountView {
    private func addTitleLabel(_ theme: AddAccountViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.topInset)
        }
    }

    private func addStackView(_ theme: AddAccountViewTheme) {
        stackView.axis = .vertical

        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(theme.verticalInset)
            $0.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + theme.verticalInset)
            $0.centerY.equalToSuperview()
        }

        createNewAccountView.customize(theme.accountTypeViewTheme)
        stackView.addArrangedSubview(createNewAccountView)
        watchAccountView.customize(theme.accountTypeViewTheme)
        stackView.addArrangedSubview(watchAccountView)
        pairAccountView.customize(theme.accountTypeViewTheme)
        stackView.addArrangedSubview(pairAccountView)
    }
}

extension AddAccountView {
    func bindCreateNewAccountView(_ viewModel: AccountTypeViewModel) {
        createNewAccountView.bindData(viewModel)
    }

    func bindWatchAccountView(_ viewModel: AccountTypeViewModel) {
        watchAccountView.bindData(viewModel)
    }

    func bindPairAccountView(_ viewModel: AccountTypeViewModel) {
        pairAccountView.bindData(viewModel)
    }
}

protocol AddAccountViewDelegate: AnyObject {
    func addAccountView(_ addAccountView: AddAccountView, didSelect type: AccountAdditionType)
}
