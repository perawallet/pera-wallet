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
//   AlgosCardAnalyticsContainerView.swift

import UIKit

class AlgosCardAnalyticsContainerView: BaseView {

    weak var delegate: AlgosCardAnalyticsContainerViewDelegate?

    private let layout = Layout<LayoutConstants>()

    private lazy var backgroundView = UIView()

    private lazy var algoCurrencyValueLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withTextColor(Colors.Main.white.withAlphaComponent(0.8))
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
    }()

    private lazy var analyticsButton: AlignedButton = {
        let button = AlignedButton(.imageAtLeft(spacing: 8.0))
        button.setImage(img("icon-chart"), for: .normal)
        button.setTitle("title-analytics".localized, for: .normal)
        button.setTitleColor(Colors.Main.white, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 14.0))
        button.titleLabel?.textAlignment = .center
        return button
    }()

    private lazy var rightArrowImageView = UIImageView(image: img("icon-right-arrow-white"))

    override func configureAppearance() {
        backgroundColor = .clear
        backgroundView.backgroundColor = Colors.Main.white.withAlphaComponent(0.1)
        backgroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        backgroundView.layer.cornerRadius = 24.0
    }

    override func setListeners() {
        analyticsButton.addTarget(self, action: #selector(notifyDelegateToOpenAnalytics), for: .touchUpInside)
    }

    override func prepareLayout() {
        setupBackgroundViewLayout()
        setupRightArrowImageViewLayout()
        setupAlgoCurrencyValueLabelLayout()
        setupAnalyticsButtonLayout()
    }
}

extension AlgosCardAnalyticsContainerView {
    private func setupBackgroundViewLayout() {
        prepareWholeScreenLayoutFor(backgroundView)
    }

    private func setupRightArrowImageViewLayout() {
        addSubview(rightArrowImageView)

        rightArrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupAlgoCurrencyValueLabelLayout() {
        addSubview(algoCurrencyValueLabel)

        algoCurrencyValueLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }

    private func setupAnalyticsButtonLayout() {
        addSubview(analyticsButton)

        analyticsButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.bottom.top.equalToSuperview()
            make.trailing.equalTo(rightArrowImageView.snp.leading).offset(layout.current.analyticsTrailinfInset)
            make.leading.greaterThanOrEqualTo(algoCurrencyValueLabel.snp.trailing).offset(layout.current.minimumOffset)
        }
    }
}

extension AlgosCardAnalyticsContainerView {
    @objc
    private func notifyDelegateToOpenAnalytics() {
        delegate?.algosCardAnalyticsContainerViewDidOpenAnalytics(self)
    }
}

extension AlgosCardAnalyticsContainerView {
    func bind(_ viewModel: AlgosCardAnalyticsContainerViewModel?) {
        algoCurrencyValueLabel.text = viewModel?.algosCurrencyValue
    }
}

extension AlgosCardAnalyticsContainerView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 24.0
        let analyticsTrailinfInset: CGFloat = -12.0
        let minimumOffset: CGFloat = 4.0
    }
}

protocol AlgosCardAnalyticsContainerViewDelegate: class {
    func algosCardAnalyticsContainerViewDidOpenAnalytics(_ algosCardAnalyticsContainerView: AlgosCardAnalyticsContainerView)
}
