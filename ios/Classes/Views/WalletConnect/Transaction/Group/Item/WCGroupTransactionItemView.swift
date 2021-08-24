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
//   WCGroupTransactionItemView.swift

import UIKit

class WCGroupTransactionItemView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var senderStackView: HStackView = {
        let stackView = HStackView()
        stackView.distribution = .equalSpacing
        stackView.spacing = 8.0
        stackView.alignment = .leading
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return stackView
    }()

    private lazy var warningImageView = UIImageView(image: img("icon-orange-warning"))

    private lazy var senderLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
    }()

    private lazy var balanceStackView: HStackView = {
        let stackView = HStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.spacing = 4.0
        stackView.alignment = .center
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return stackView
    }()

    private lazy var algoIconImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-algo-gray", isTemplate: true))
        imageView.tintColor = Colors.Text.primary
        return imageView
    }()

    private lazy var balanceLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
    }()

    private lazy var assetNameLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
    }()

    private lazy var arrowImageView = UIImageView(image: img("icon-arrow-gray-24"))

    private(set) lazy var accountInformationView = WCGroupTransactionAccountInformationView()

    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
        layer.cornerRadius = 12.0
    }

    override func prepareLayout() {
        setupSenderStackViewLayout()
        setupArrowImageViewLayout()
        setupBalanceStackViewLayout()
        setupAccountInformationViewLayout()
    }
}

extension WCGroupTransactionItemView {
    private func setupSenderStackViewLayout() {
        addSubview(senderStackView)

        senderStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.defaultInset)
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.defaultInset)
            make.height.equalTo(layout.current.senderStackHeight)
        }

        senderStackView.addArrangedSubview(warningImageView)
        senderStackView.addArrangedSubview(senderLabel)
    }

    private func setupArrowImageViewLayout() {
        addSubview(arrowImageView)

        arrowImageView.snp.makeConstraints { make in
            make.size.equalTo(layout.current.arrowImageSize)
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalToSuperview().inset(layout.current.arrowImageTopInset)
        }
    }

    private func setupBalanceStackViewLayout() {
        addSubview(balanceStackView)

        balanceStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.lessThanOrEqualTo(arrowImageView.snp.leading).offset(-layout.current.defaultInset)
            make.top.equalTo(senderStackView.snp.bottom).offset(layout.current.balanceStackTopInset)
            make.height.equalTo(layout.current.balanceStackHeight)
        }

        balanceStackView.addArrangedSubview(algoIconImageView)
        balanceStackView.addArrangedSubview(balanceLabel)
        balanceStackView.addArrangedSubview(assetNameLabel)
    }

    private func setupAccountInformationViewLayout() {
        addSubview(accountInformationView)

        accountInformationView.snp.makeConstraints { make in
            make.top.equalTo(balanceStackView.snp.bottom).offset(layout.current.accountInformationViewTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.accountInformationViewInset)
            make.height.greaterThanOrEqualTo(layout.current.accountInformationHeight)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.accountInformationViewInset)
        }
    }
}

extension WCGroupTransactionItemView {
    func bind(_ viewModel: WCGroupTransactionItemViewModel) {
        warningImageView.isHidden = !viewModel.hasWarning
        senderLabel.text = viewModel.title
        algoIconImageView.isHidden = !viewModel.isAlgos
        balanceLabel.text = viewModel.amount
        assetNameLabel.isHidden = viewModel.isAlgos
        assetNameLabel.text = viewModel.assetName

        if let accountInformationViewModel = viewModel.accountInformationViewModel {
            accountInformationView.bind(accountInformationViewModel)
        }
    }
}

extension WCGroupTransactionItemView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let senderStackHeight: CGFloat = 20.0
        let arrowImageSize = CGSize(width: 24.0, height: 24.0)
        let arrowImageTopInset: CGFloat = 36.0
        let balanceStackHeight: CGFloat = 24.0
        let balanceStackTopInset: CGFloat = 8.0
        let accountInformationHeight: CGFloat = 36.0
        let accountInformationViewTopInset: CGFloat = 12.0
        let accountInformationViewInset: CGFloat = 8.0
    }
}
