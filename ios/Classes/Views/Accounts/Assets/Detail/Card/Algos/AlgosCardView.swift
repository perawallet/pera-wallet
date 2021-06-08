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
//  AlgosCardView.swift

import UIKit

class AlgosCardView: BaseView {
    
    weak var delegate: AlgosCardViewDelegate?
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var backgroundImageView = UIImageView(image: img("bg-card-green"))
    
    private lazy var totalAmountLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.left)
            .withTextColor(Colors.Main.white)
            .withFont(UIFont.font(withWeight: .medium(size: 28.0)))
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var algosImageView = UIImageView(image: img("icon-algorand-asset-detail"))
    
    private lazy var currencyAmountLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.left)
            .withTextColor(Colors.Main.white.withAlphaComponent(0.9))
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
        return label
    }()

    private lazy var algosTitleLabel: UILabel = {
        UILabel()
            .withText("accounts-algos-available-title".localized)
            .withAlignment(.left)
            .withTextColor(Colors.Main.white.withAlphaComponent(0.8))
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
    }()

    private lazy var algosAmountLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.left)
            .withTextColor(Colors.Main.white)
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
        label.minimumScaleFactor = 0.3
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private lazy var rewardTitleButton: AlignedButton = {
        let button = AlignedButton(.imageAtRight(spacing: 4.0))
        button.setImage(img("icon-info-white"), for: .normal)
        button.setTitle("rewards-title".localized, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitleColor(Colors.Main.white.withAlphaComponent(0.8), for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .regular(size: 14.0))
        button.contentEdgeInsets = .zero
        button.titleLabel?.textAlignment = .left
        button.contentEdgeInsets.top = 20.0
        return button
    }()

    private lazy var rewardAmountLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.left)
            .withTextColor(Colors.Main.white)
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private lazy var analyticsContainerView = AlgosCardAnalyticsContainerView()
    
    override func configureAppearance() {
        backgroundColor = .clear
        algosImageView.contentMode = .scaleAspectFit
    }

    override func linkInteractors() {
        analyticsContainerView.delegate = self
    }
    
    override func setListeners() {
        rewardTitleButton.addTarget(self, action: #selector(notifyDelegateToOpenRewardDetails), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupBackgroundImageViewLayout()
        setupTotalAmountLabelLayout()
        setupAlgosImageViewLayout()
        setupCurrencyAmountLabelLayout()
        setupAlgosTitleLabelLayout()
        setupAlgosAmountLabelLayout()
        setupRewardTitleButtonLayout()
        setupRewardAmountLabelLayout()
        setupAnalyticsContainerViewLayout()
    }
}

extension AlgosCardView {
    @objc
    private func notifyDelegateToOpenRewardDetails() {
        delegate?.algosCardViewDidOpenRewardDetails(self)
    }
}

extension AlgosCardView {
    private func setupBackgroundImageViewLayout() {
        addSubview(backgroundImageView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTotalAmountLabelLayout() {
        addSubview(totalAmountLabel)
        
        totalAmountLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.defaultInset)
        }
    }
    
    private func setupAlgosImageViewLayout() {
        addSubview(algosImageView)
        
        algosImageView.snp.makeConstraints { make in
            make.size.equalTo(layout.current.algosImageSize)
            make.leading.equalTo(totalAmountLabel.snp.trailing).offset(layout.current.minimumOffset)
            make.centerY.equalTo(totalAmountLabel)
        }
    }
    
    private func setupCurrencyAmountLabelLayout() {
        addSubview(currencyAmountLabel)
        
        currencyAmountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(totalAmountLabel.snp.bottom).offset(layout.current.currencyTopInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.amountTrailingInset)
        }
    }

    private func setupAlgosTitleLabelLayout() {
        addSubview(algosTitleLabel)

        algosTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(totalAmountLabel.snp.bottom).offset(layout.current.algosTopInset)
        }
    }

    private func setupAlgosAmountLabelLayout() {
        addSubview(algosAmountLabel)

        algosAmountLabel.snp.makeConstraints { make in
            make.leading.equalTo(algosTitleLabel)
            make.top.equalTo(algosTitleLabel.snp.bottom).offset(layout.current.minimumOffset)
        }
    }
    
    private func setupRewardTitleButtonLayout() {
        addSubview(rewardTitleButton)
        
        rewardTitleButton.snp.makeConstraints { make in
            make.top.equalTo(totalAmountLabel.snp.bottom).offset(layout.current.rewardTopInset)
            make.leading.equalTo(algosAmountLabel.snp.trailing).offset(layout.current.rewardTitleLeadingInset)
        }
    }

    private func setupRewardAmountLabelLayout() {
        addSubview(rewardAmountLabel)

        rewardAmountLabel.setContentHuggingPriority(.required, for: .horizontal)
        rewardAmountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        rewardAmountLabel.snp.makeConstraints { make in
            make.leading.equalTo(rewardTitleButton)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.rewardAmountTrailingInset)
            make.top.equalTo(algosAmountLabel)
        }
    }

    private func setupAnalyticsContainerViewLayout() {
        addSubview(analyticsContainerView)

        analyticsContainerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(layout.current.analyticsContainerHeight)
        }
    }
}

extension AlgosCardView: AlgosCardAnalyticsContainerViewDelegate {
    func algosCardAnalyticsContainerViewDidOpenAnalytics(_ algosCardAnalyticsContainerView: AlgosCardAnalyticsContainerView) {
        delegate?.algosCardViewDidOpenAnalytics(self)
    }
}

extension AlgosCardView {
    func bind(_ viewModel: AlgosCardViewModel) {
        totalAmountLabel.text = viewModel.totalAmount
        currencyAmountLabel.text = viewModel.currency
        algosAmountLabel.text = viewModel.algosAmount
        rewardAmountLabel.text = viewModel.reward
        analyticsContainerView.bind(viewModel.analyticsContainerViewModel)
    }

    func bind(_ viewModel: RewardCalculationViewModel) {
        totalAmountLabel.text = viewModel.totalAmount
        currencyAmountLabel.text = viewModel.currency
        rewardAmountLabel.text = viewModel.rewardAmount
    }
}

extension AlgosCardView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 24.0
        let rewardLabelTopOffset: CGFloat = -1.0
        let currencyTopInset: CGFloat = 8.0
        let rewardTopInset: CGFloat = 42.0
        let rewardAmountTrailingInset: CGFloat = 8.0
        let algosTopInset: CGFloat = 64.0
        let amountTrailingInset: CGFloat = 40.0
        let minimumOffset: CGFloat = 4.0
        let algosImageSize = CGSize(width: 16.0, height: 16.0)
        let rewardTitleLeadingInset: CGFloat = 32.0
        let analyticsContainerTopInset: CGFloat = 28.0
        let analyticsContainerHeight: CGFloat = 52.0
    }
}

protocol AlgosCardViewDelegate: class {
    func algosCardViewDidOpenRewardDetails(_ algosCardView: AlgosCardView)
    func algosCardViewDidOpenAnalytics(_ algosCardView: AlgosCardView)
}
