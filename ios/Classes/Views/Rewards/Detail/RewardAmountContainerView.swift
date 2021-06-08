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
//  RewardAmountContainerView.swift

import UIKit

class RewardAmountContainerView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.center)
            .withText("rewards-since-last-text".localized)
    }()
    
    private lazy var algoIconImageView = UIImageView(image: img("icon-algorand-asset-detail", isTemplate: true))
    
    private lazy var amountLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.single)
            .withTextColor(Colors.General.selected)
            .withFont(UIFont.font(withWeight: .semiBold(size: 28.0)))
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        algoIconImageView.tintColor = Colors.General.selected
        layer.cornerRadius = 12.0
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupAmountLabelLayout()
        setupAlgoIconImageViewLayout()
    }
}

extension RewardAmountContainerView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.titleTopInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupAmountLabelLayout() {
        addSubview(amountLabel)
        
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.amountTopInset)
            make.centerX.equalToSuperview().offset(layout.current.amountCenterOffset)
            make.bottom.equalToSuperview().inset(layout.current.amountBottomInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.amountCenterOffset)
        }
    }
    
    private func setupAlgoIconImageViewLayout() {
        addSubview(algoIconImageView)

        algoIconImageView.snp.makeConstraints { make in
            make.trailing.equalTo(amountLabel.snp.leading).offset(layout.current.imageTrailingInset)
            make.size.equalTo(layout.current.imageSize)
            make.centerY.equalTo(amountLabel)
        }
    }
}

extension RewardAmountContainerView {
    func bind(_ viewModel: RewardDetailViewModel) {
        amountLabel.text = viewModel.amount
    }
}

extension RewardAmountContainerView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleTopInset: CGFloat = 20.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let imageTrailingInset: CGFloat = -4.0
        let amountTopInset: CGFloat = 4.0
        let amountBottomInset: CGFloat = 20.0
        let amountCenterOffset: CGFloat = 13.0
    }
}
