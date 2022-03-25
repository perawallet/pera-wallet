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
//  RewardDetailView.swift

import UIKit
import MacaroonUIKit

final class RewardDetailView:
    View,
    ViewModelBindable {
    weak var delegate: RewardDetailViewDelegate?

    private lazy var rewardsLabel = UILabel()
    private lazy var rewardsValueLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var FAQLabel = UILabel()

    func setListeners() {
        FAQLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTriggerFAQLabel))
        )
    }
    
    func customize(
        _ theme: RewardDetailViewTheme
    ) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addRewardsLabel(theme)
        addRewardsValueLabel(theme)
        addDescriptionLabel(theme)
        addFAQLabel(theme)
    }

    func prepareLayout(
        _ layoutSheet: LayoutSheet
    ) {}

    func customizeAppearance(
        _ styleSheet: StyleSheet
    ) {}

    func bindData(
        _ viewModel: RewardDetailViewModel?
    ) {
        rewardsLabel.editText = viewModel?.title
        rewardsValueLabel.editText = viewModel?.amount
        descriptionLabel.editText = viewModel?.description
        FAQLabel.editText = viewModel?.FAQLabel
    }
}

extension RewardDetailView {
    @objc
    private func didTriggerFAQLabel() {
        delegate?.rewardDetailViewDidTapFAQLabel(self)
    }
}

extension RewardDetailView {
    private func addRewardsLabel(
        _ theme: RewardDetailViewTheme
    ) {
        rewardsLabel.customizeAppearance(theme.rewardsLabel)

        addSubview(rewardsLabel)
        rewardsLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.rewardsRateTitleLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addRewardsValueLabel(
        _ theme: RewardDetailViewTheme
    ) {
        rewardsValueLabel.customizeAppearance(theme.rewardsValueLabel)
        addSubview(rewardsValueLabel)
        rewardsValueLabel.snp.makeConstraints {
            $0.top.equalTo(rewardsLabel.snp.bottom).offset(theme.rewardsLabelTopPadding)
            $0.leading.equalTo(rewardsLabel)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
        
        rewardsLabel.addSeparator(theme.separator, padding: theme.separatorTopPadding)
    }

    private func addDescriptionLabel(
        _ theme: RewardDetailViewTheme
    ) {
        descriptionLabel.customizeAppearance(theme.descriptionLabel)

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(rewardsValueLabel.snp.bottom).offset(theme.descriptionLabelTopPadding)
        }
    }

    private func addFAQLabel(
        _ theme: RewardDetailViewTheme
    ) {
        FAQLabel.customizeAppearance(theme.FAQLabel)

        addSubview(FAQLabel)
        FAQLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(theme.FAQLabelTopPadding)
            $0.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + theme.bottomInset)
        }
    }
}

protocol RewardDetailViewDelegate: AnyObject {
    func rewardDetailViewDidTapFAQLabel(_ rewardDetailView: RewardDetailView)
}
