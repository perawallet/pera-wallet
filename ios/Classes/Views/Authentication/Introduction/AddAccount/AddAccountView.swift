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
//  AddAccountView.swift

import UIKit

class AddAccountView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: AddAccountViewDelegate?

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 28.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.contained)
            .withAlignment(.center)
            .withText("introduction-add-account-text".localized)
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.spacing = 0.0
        stackView.alignment = .fill
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.axis = .vertical
        stackView.isUserInteractionEnabled = true
        return stackView
    }()

    private lazy var createNewAccountView = AccountTypeView()

    private lazy var watchAccountView = AccountTypeView()

    private lazy var pairAccountView = AccountTypeView()

    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }

    override func setListeners() {
        createNewAccountView.addTarget(self, action: #selector(notifyDelegateToSelectCreateNewAccount), for: .touchUpInside)
        watchAccountView.addTarget(self, action: #selector(notifyDelegateToSelectWatchAccount), for: .touchUpInside)
        pairAccountView.addTarget(self, action: #selector(notifyDelegateToSelectPairAccount), for: .touchUpInside)
    }

    override func prepareLayout() {
        setupTitleLabelLayout()
        setupStackViewLayout()
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
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }

    private func setupStackViewLayout() {
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(layout.current.verticalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + layout.current.verticalInset)
            make.centerY.equalToSuperview()
        }

        stackView.addArrangedSubview(createNewAccountView)
        stackView.addArrangedSubview(watchAccountView)
        stackView.addArrangedSubview(pairAccountView)
    }
}

extension AddAccountView {
    func configureCreateNewAccountView(with viewModel: AccountTypeViewModel) {
        createNewAccountView.bind(viewModel)
    }

    func configureWatchAccountView(with viewModel: AccountTypeViewModel) {
        watchAccountView.bind(viewModel)
    }

    func configurePairAccountView(with viewModel: AccountTypeViewModel) {
        pairAccountView.bind(viewModel)
    }
}

extension AddAccountView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 32.0
        let topInset: CGFloat = 12.0
        let verticalInset: CGFloat = 20.0
    }
}

protocol AddAccountViewDelegate: AnyObject {
    func addAccountView(_ addAccountView: AddAccountView, didSelect type: AccountAdditionType)
}
