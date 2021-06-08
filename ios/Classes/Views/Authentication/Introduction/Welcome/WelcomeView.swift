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
//  WelcomeView.swift

import UIKit

class WelcomeView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: WelcomeViewDelegate?

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 28.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.contained)
            .withAlignment(.center)
            .withText("account-welcome-wallet-title".localized)
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

    private lazy var termsAndConditionsTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .link
        textView.textContainerInset = .zero
        textView.textAlignment = .center
        textView.linkTextAttributes = [
            .foregroundColor: Colors.Text.link,
            .underlineColor: UIColor.clear,
            .font: UIFont.font(withWeight: .semiBold(size: 14.0))
        ]

        let centerParagraphStyle = NSMutableParagraphStyle()
        centerParagraphStyle.alignment = .center

        textView.bindHtml(
            "introduction-title-terms-and-services".localized,
            with: [
                .font: UIFont.font(withWeight: .regular(size: 14.0)),
                .foregroundColor: Colors.Text.tertiary,
                .paragraphStyle: centerParagraphStyle
            ]
        )
        return textView
    }()

    private lazy var addAccountView = AccountTypeView()

    private lazy var recoverAccountView = AccountTypeView()

    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }

    override func setListeners() {
        addAccountView.addTarget(self, action: #selector(notifyDelegateToAddAccount), for: .touchUpInside)
        recoverAccountView.addTarget(self, action: #selector(notifyDelegateToRecoverAccount), for: .touchUpInside)
    }

    override func linkInteractors() {
        termsAndConditionsTextView.delegate = self
    }

    override func prepareLayout() {
        setupTitleLabelLayout()
        setupTermsAndConditionsTextViewLayout()
        setupStackViewLayout()
    }
}

extension WelcomeView {
    @objc
    private func notifyDelegateToAddAccount() {
        delegate?.welcomeView(self, didSelect: .add(type: .none))
    }

    @objc
    private func notifyDelegateToRecoverAccount() {
        delegate?.welcomeView(self, didSelect: .recover)
    }
}

extension WelcomeView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }

    private func setupTermsAndConditionsTextViewLayout() {
        addSubview(termsAndConditionsTextView)

        termsAndConditionsTextView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.verticalInset)
            make.centerX.equalToSuperview()
        }
    }

    private func setupStackViewLayout() {
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(layout.current.verticalInset)
            make.bottom.lessThanOrEqualTo(termsAndConditionsTextView.snp.top).offset(-layout.current.verticalInset)
            make.centerY.equalToSuperview()
        }

        stackView.addArrangedSubview(addAccountView)
        stackView.addArrangedSubview(recoverAccountView)
    }
}

extension WelcomeView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        delegate?.welcomeView(self, didOpen: URL)
        return false
    }
}

extension WelcomeView {
    func configureAddAccountView(with viewModel: AccountTypeViewModel) {
        addAccountView.bind(viewModel)
    }

    func configureRecoverAccountView(with viewModel: AccountTypeViewModel) {
        recoverAccountView.bind(viewModel)
    }
}

extension WelcomeView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 24.0
        let topInset: CGFloat = 12.0
        let verticalInset: CGFloat = 20.0
    }
}

protocol WelcomeViewDelegate: class {
    func welcomeView(_ welcomeView: WelcomeView, didSelect mode: AccountSetupMode)
    func welcomeView(_ welcomeView: WelcomeView, didOpen url: URL)
}
