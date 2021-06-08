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
//   AlgoAnalyticsHeaderView.swift

import UIKit

class AlgoAnalyticsHeaderView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var amountLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 32.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.center)
    }()

    private lazy var informationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 3.0
        return stackView
    }()

    private lazy var valueChangeView = AnalyticsValueChangeView()

    private lazy var dateLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.center)
    }()

    override func configureAppearance() {
        backgroundColor = .clear
    }

    override func prepareLayout() {
        setupAmountLabelLayout()
        setupInformationStackViewLayout()
    }
}

extension AlgoAnalyticsHeaderView {
    private func setupAmountLabelLayout() {
        addSubview(amountLabel)

        amountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
    }

    private func setupInformationStackViewLayout() {
        addSubview(informationStackView)

        valueChangeView.setContentHuggingPriority(.required, for: .horizontal)
        valueChangeView.setContentCompressionResistancePriority(.required, for: .horizontal)
        dateLabel.setContentHuggingPriority(.required, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        informationStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.stackHeight)
            make.top.equalTo(amountLabel.snp.bottom).offset(layout.current.stackTopInset)
        }

        informationStackView.addArrangedSubview(valueChangeView)
        informationStackView.addArrangedSubview(dateLabel)
    }
}

extension AlgoAnalyticsHeaderView {
    func bind(_ viewModel: AlgoAnalyticsHeaderViewModel) {
        amountLabel.text = viewModel.amount
        dateLabel.text = viewModel.date
        valueChangeView.isHidden = !viewModel.isValueChangeDisplayed

        if viewModel.isValueChangeDisplayed {
            valueChangeView.bind(viewModel.valueChangeViewModel)
        }
    }
}

extension AlgoAnalyticsHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let stackTopInset: CGFloat = 12.0
        let horizontalInset: CGFloat = 20.0
        let stackHeight: CGFloat = 22.0
    }
}

enum ValueChangeStatus {
    case increased
    case decreased
    case stable
}
