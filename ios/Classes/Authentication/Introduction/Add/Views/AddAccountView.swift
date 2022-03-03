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

final class AddAccountView:
    View,
    ViewModelBindable {
    weak var delegate: AddAccountViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var stackView = UIStackView()
    private lazy var createNewAccountView = AccountTypeView()
    private lazy var addWatchAccountView = AccountTypeView()

    func customize(_ theme: AddAccountViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addTitleLabel(theme)
        addStackView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func setListeners() {
        createNewAccountView.addTarget(
            self,
            action: #selector(notifyDelegateToSelectCreateNewAccount),
            for: .touchUpInside
        )

        addWatchAccountView.addTarget(
            self,
            action: #selector(notifyDelegateToSelectAddWatchAccount),
            for: .touchUpInside
        )
    }

    func bindData(_ viewModel: AddAccountViewModel?) {
        createNewAccountView.bindData(viewModel?.createNewAccountViewModel)
        addWatchAccountView.bindData(viewModel?.addWatchAccountViewModel)
    }
}

extension AddAccountView {
    @objc
    private func notifyDelegateToSelectCreateNewAccount() {
        delegate?.addAccountView(self, didSelect: .create)
    }

    @objc
    private func notifyDelegateToSelectAddWatchAccount() {
        delegate?.addAccountView(self, didSelect: .watch)
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
        addWatchAccountView.customize(theme.accountTypeViewTheme)
        stackView.addArrangedSubview(addWatchAccountView)
    }
}

protocol AddAccountViewDelegate: AnyObject {
    func addAccountView(_ addAccountView: AddAccountView, didSelect type: AccountAdditionType)
}
