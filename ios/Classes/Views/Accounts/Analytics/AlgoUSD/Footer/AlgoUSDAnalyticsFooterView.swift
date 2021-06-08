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
//   AlgoUSDAnalyticsFooterView.swift

import UIKit

class AlgoUSDAnalyticsFooterView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var balanceTitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.secondary)
            .withLine(.single)
            .withAlignment(.left)
            .withText("title-account-balance".localized)
    }()

    private lazy var algorandIconImageView = UIImageView(image: img("icon-algorand-bg-green"))

    private lazy var balanceLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
    }()

    private lazy var valueTitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.secondary)
            .withLine(.single)
            .withAlignment(.right)
            .withText("title-algorand-value".localized)
    }()

    private lazy var valueLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.right)
    }()

    override func configureAppearance() {
        backgroundColor = .clear
    }

    override func prepareLayout() {
        setupBalanceTitleLabelLayout()
        setupAlgorandIconImageViewLayout()
        setupBalanceLabelLayout()
        setupValueTitleLabelLayout()
        setupValueLabelLayout()
    }
}

extension AlgoUSDAnalyticsFooterView {
    private func setupBalanceTitleLabelLayout() {
        addSubview(balanceTitleLabel)

        balanceTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupAlgorandIconImageViewLayout() {
        addSubview(algorandIconImageView)

        algorandIconImageView.snp.makeConstraints { make in
            make.top.equalTo(balanceTitleLabel.snp.bottom).offset(layout.current.labelInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.iconSize)
            make.bottom.equalToSuperview().inset(layout.current.minimumInset)
        }
    }

    private func setupBalanceLabelLayout() {
        addSubview(balanceLabel)

        balanceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(algorandIconImageView)
            make.leading.equalTo(algorandIconImageView.snp.trailing).offset(layout.current.labelInset)
        }
    }

    private func setupValueTitleLabelLayout() {
        addSubview(valueTitleLabel)

        valueTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupValueLabelLayout() {
        addSubview(valueLabel)

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(valueTitleLabel.snp.bottom).offset(layout.current.labelInset)
            make.leading.greaterThanOrEqualTo(balanceLabel.snp.trailing).offset(layout.current.minimumInset)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension AlgoUSDAnalyticsFooterView {
    func bind(_ viewModel: AlgoUSDAnalyticsFooterViewModel) {
        balanceLabel.text = viewModel.balance
        valueLabel.text = viewModel.value
    }
}

extension AlgoUSDAnalyticsFooterView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let minimumInset: CGFloat = 4.0
        let labelInset: CGFloat = 8.0
        let iconSize = CGSize(width: 24.0, height: 24.0)
        let horizontalInset: CGFloat = 20.0
    }
}
