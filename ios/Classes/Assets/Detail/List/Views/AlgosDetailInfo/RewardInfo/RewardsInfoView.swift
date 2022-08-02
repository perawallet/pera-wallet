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
//   RewardsInfoView.swift

import UIKit
import MacaroonUIKit

final class RewardsInfoView:
    View,
    ViewModelBindable,
    TripleShadowDrawable {
    weak var delegate: RewardsInfoViewDelegate?

    private lazy var rewardImageView = UIImageView()
    private lazy var rewardsLabel = UILabel()
    private lazy var rewardsValueLabel = UILabel()
    private lazy var infoButton = UIButton()

    var thirdShadow: MacaroonUIKit.Shadow?
    var thirdShadowLayer: CAShapeLayer = CAShapeLayer()
    var secondShadow: MacaroonUIKit.Shadow?
    var secondShadowLayer: CAShapeLayer = CAShapeLayer()
    
    private lazy var theme = RewardsInfoViewTheme()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customize(theme)
    }

    func customize(
        _ theme: RewardsInfoViewTheme
    ) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        draw(corner: theme.containerCorner)
        draw(border: theme.containerBorder)
        draw(shadow: theme.containerFirstShadow)
        draw(secondShadow: theme.containerSecondShadow)
        draw(thirdShadow: theme.containerThirdShadow)

        addRewardImageView(theme)
        addInfoButton(theme)
        addRewardsLabel(theme)
        addRewardsValueLabel(theme)
    }
    
    override func preferredUserInterfaceStyleDidChange() {
        super.preferredUserInterfaceStyleDidChange()
        
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        draw(corner: theme.containerCorner)
        draw(border: theme.containerBorder)
        draw(shadow: theme.containerFirstShadow)
        draw(secondShadow: theme.containerSecondShadow)
        draw(thirdShadow: theme.containerThirdShadow)
    }

    func prepareLayout(
        _ layoutSheet: LayoutSheet
    ) {}

    func customizeAppearance(
        _ styleSheet: StyleSheet
    ) {}

    func bindData(_ viewModel: RewardInfoViewModel?) {
        if let title = viewModel?.title {
            title.load(in: rewardsLabel)
        } else {
            rewardsLabel.text = nil
            rewardsLabel.attributedText = nil
        }

        if let value = viewModel?.value {
            value.load(in: rewardsValueLabel)
        } else {
            rewardsValueLabel.text = nil
            rewardsLabel.attributedText = nil
        }
    }

    class func calculatePreferredSize(
        _ viewModel: RewardInfoViewModel?,
        for theme: RewardsInfoViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let titleSize = viewModel.title?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let valueSize = viewModel.value?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let preferredHeight =
        theme.bottomPadding +
        titleSize.height +
        theme.rewardsValueLabelTopPadding +
        valueSize.height +
        theme.bottomPadding
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }

    func setListeners() {
        infoButton.addTarget(self, action: #selector(didTapInfoButton), for: .touchUpInside)
    }
}

extension RewardsInfoView {
    @objc
    private func didTapInfoButton() {
        delegate?.rewardsInfoViewDidTapInfoButton(self)
    }
}

extension RewardsInfoView {
    private func addRewardImageView(
        _ theme: RewardsInfoViewTheme
    ) {
        rewardImageView.customizeAppearance(theme.rewardImage)

        addSubview(rewardImageView)
        rewardImageView.snp.makeConstraints {
            $0.fitToSize(theme.infoButtonSize)
            $0.leading.equalToSuperview().inset(theme.imageHorizontalInset)
            $0.centerY.equalToSuperview()
        }
    }

    private func addInfoButton(
        _ theme: RewardsInfoViewTheme
    ) {
        infoButton.customizeAppearance(theme.infoButton)

        addSubview(infoButton)
        infoButton.snp.makeConstraints {
            $0.fitToSize(theme.infoButtonSize)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addRewardsLabel(
        _ theme: RewardsInfoViewTheme
    ) {
        rewardsLabel.customizeAppearance(theme.rewardsLabel)

        addSubview(rewardsLabel)
        rewardsLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.bottomPadding)
            $0.leading.equalTo(rewardImageView.snp.trailing).offset(theme.rewardsLabelLeadingPadding)
            $0.trailing.lessThanOrEqualTo(infoButton.snp.leading).offset(theme.minimumHorizontalInset)
        }
    }

    private func addRewardsValueLabel(
        _ theme: RewardsInfoViewTheme
    ) {
        rewardsValueLabel.customizeAppearance(theme.rewardsValueLabel)

        addSubview(rewardsValueLabel)
        rewardsValueLabel.snp.makeConstraints {
            $0.top.equalTo(rewardsLabel.snp.bottom).offset(theme.rewardsValueLabelTopPadding)
            $0.leading.equalTo(rewardsLabel)
            $0.trailing.lessThanOrEqualTo(infoButton.snp.leading).offset(theme.minimumHorizontalInset)
            $0.bottom.equalToSuperview().inset(theme.bottomPadding)
        }
    }
}

protocol RewardsInfoViewDelegate: AnyObject {
    func rewardsInfoViewDidTapInfoButton(_ rewardsInfoView: RewardsInfoView)
}
