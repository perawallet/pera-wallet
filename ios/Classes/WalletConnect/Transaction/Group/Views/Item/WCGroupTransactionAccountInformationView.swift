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
//   WCGroupTransactionAccountInformationView.swift

import UIKit

final class WCGroupTransactionAccountInformationView: BaseView {
    private let layout = Layout<LayoutConstants>()

    private lazy var accountNameView = WCAccountInformationNameView()

    private lazy var dotImage = UIImageView(image: img("img-round-separator"))

    private lazy var balanceStackView: HStackView = {
        let stackView = HStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.spacing = 4.0
        stackView.alignment = .leading
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return stackView
    }()

    private lazy var balanceLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.gray.uiColor)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(Fonts.DMMono.regular.make(13).uiFont)
    }()

    private lazy var assetNameLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.gray.uiColor)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(Fonts.DMMono.regular.make(13).uiFont)
    }()

    override func configureAppearance() {
        super.configureAppearance()

        backgroundColor = .clear
    }

    override func prepareLayout() {
        setupAccountNameViewLayout()
        setupDotImageLayout()
        setupBalanceStackViewLayout()
    }
}

extension WCGroupTransactionAccountInformationView {
    private func setupAccountNameViewLayout() {
        addSubview(accountNameView)

        accountNameView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupDotImageLayout() {
        addSubview(dotImage)

        dotImage.snp.makeConstraints { make in
            make.size.equalTo(layout.current.imageSize)
            make.leading.equalTo(accountNameView.snp.trailing).offset(layout.current.dotImageLeadingInset)
            make.centerY.equalTo(accountNameView)
        }
    }

    private func setupBalanceStackViewLayout() {
        addSubview(balanceStackView)

        balanceStackView.snp.makeConstraints { make in
            make.leading.equalTo(dotImage.snp.trailing).offset(layout.current.balanceLeadingInset)
            make.centerY.equalTo(accountNameView)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
        }

        balanceStackView.addArrangedSubview(balanceLabel)
        balanceStackView.addArrangedSubview(assetNameLabel)
    }
}

extension WCGroupTransactionAccountInformationView {
    func bind(_ viewModel: WCGroupTransactionAccountInformationViewModel) {
        if let accountNameViewModel = viewModel.accountNameViewModel {
            accountNameView.bind(accountNameViewModel)
        }

        dotImage.isHidden = !viewModel.isDisplayingDotSeparator
        balanceLabel.text = viewModel.balance
        balanceLabel.isHidden = !viewModel.isDisplayingDotSeparator
        assetNameLabel.text = viewModel.assetName
    }
}

extension WCGroupTransactionAccountInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 12.0
        let dotImageLeadingInset: CGFloat = 8.0
        let balanceLeadingInset: CGFloat = 4.0
        let imageSize = CGSize(width: 2.0, height: 2.0)
    }
}
