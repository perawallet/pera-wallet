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
//   AlgosDetailInfoView.swift

import MacaroonUIKit
import UIKit

final class AlgosDetailInfoView:
    View,
    ViewModelBindable,
    ListReusable {
    weak var delegate: AlgosDetailInfoViewDelegate?

    private lazy var yourBalanceTitleLabel = UILabel()
    private lazy var algoImageView = UIImageView()
    private lazy var algosValueLabel = UILabel()
    private lazy var secondaryValueLabel = Label()
    private lazy var rewardsInfoView = RewardsInfoView()
    private lazy var buyAlgoButton = Button()
    private lazy var bottomSeparator = UIView()

    func customize(
        _ theme: AlgosDetailInfoViewTheme
    ) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addYourBalanceTitleLabel(theme)
        addAlgosValueLabel(theme)
        addSecondaryValueLabel(theme)
        addRewardsInfoView(theme)
        addBuyAlgoButton(theme)
        addBottomSeparator(theme)
    }

    func customizeAppearance(
        _ styleSheet: StyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: LayoutSheet
    ) {}

    func bindData(
        _ viewModel: AlgosDetailInfoViewModel?
    ) {
        if let title = viewModel?.title {
            title.load(in: yourBalanceTitleLabel)
        } else {
            yourBalanceTitleLabel.text = nil
            yourBalanceTitleLabel.attributedText = nil
        }

        if let primaryValue = viewModel?.primaryValue {
            primaryValue.load(in: algosValueLabel)
        } else {
            algosValueLabel.text = nil
            algosValueLabel.attributedText = nil
        }

        if let secondaryValue = viewModel?.secondaryValue {
            secondaryValue.load(in: secondaryValueLabel)
        } else {
            secondaryValueLabel.text = nil
            secondaryValueLabel.attributedText = nil
        }

        rewardsInfoView.bindData(viewModel?.rewardsInfo)
        buyAlgoButton.isHidden = !(viewModel?.isBuyAlgoAvailable ?? false)
    }

    class func calculatePreferredSize(
        _ viewModel: AlgosDetailInfoViewModel?,
        for theme: AlgosDetailInfoViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width =
            size.width -
            2 * theme.horizontalPadding
        let titleSize = viewModel.title?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let primaryValueSize = viewModel.primaryValue?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let secondaryValueSize = viewModel.secondaryValue?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let rewardsInfoSize = RewardsInfoView.calculatePreferredSize(
            viewModel.rewardsInfo,
            for: theme.rewardsInfoViewTheme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        var preferredHeight =
            theme.topPadding +
            titleSize.height +
            theme.algosValueLabelTopPadding +
            primaryValueSize.height +
            secondaryValueSize.height +
            theme.rewardsInfoViewTopPadding +
            rewardsInfoSize.height +
            theme.separatorPadding +
            theme.separator.size +
            theme.bottomPadding
        
        if viewModel.isBuyAlgoAvailable {
            preferredHeight += theme.buyAlgoButtonHeight
            preferredHeight += theme.buyAlgoButtonMargin.top
        }

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }

    func setListeners() {
        rewardsInfoView.setListeners()
        rewardsInfoView.delegate = self
        buyAlgoButton.addTouch(target: self, action: #selector(didTapBuy))
    }
}

extension AlgosDetailInfoView {
    private func addYourBalanceTitleLabel(_ theme: AlgosDetailInfoViewTheme) {
        yourBalanceTitleLabel.customizeAppearance(theme.yourBalanceTitleLabel)

        addSubview(yourBalanceTitleLabel)
        yourBalanceTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addAlgosValueLabel(_ theme: AlgosDetailInfoViewTheme) {
        algosValueLabel.customizeAppearance(theme.algosValueLabel)

        addSubview(algosValueLabel)
        algosValueLabel.snp.makeConstraints {
            $0.top.equalTo(yourBalanceTitleLabel.snp.bottom).offset(theme.algosValueLabelTopPadding)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addSecondaryValueLabel(_ theme: AlgosDetailInfoViewTheme) {
        secondaryValueLabel.customizeAppearance(theme.secondaryValueLabel)

        addSubview(secondaryValueLabel)
        secondaryValueLabel.snp.makeConstraints {
            $0.top.equalTo(algosValueLabel.snp.bottom)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }

        secondaryValueLabel.contentEdgeInsets.top = theme.secondaryValueLabelTopPadding
    }

    private func addRewardsInfoView(_ theme: AlgosDetailInfoViewTheme) {
        addSubview(rewardsInfoView)
        rewardsInfoView.snp.makeConstraints {
            $0.top.equalTo(secondaryValueLabel.snp.bottom).offset(theme.rewardsInfoViewTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addBuyAlgoButton(
        _ theme: AlgosDetailInfoViewTheme
    ) {
        buyAlgoButton.customize(theme.buyAlgoButton)
        buyAlgoButton.setTitle("moonpay-buy-button-title".localized, for: .normal)

        addSubview(buyAlgoButton)
        buyAlgoButton.snp.makeConstraints {
            $0.top.equalTo(rewardsInfoView.snp.bottom).offset(theme.buyAlgoButtonMargin.top)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.fitToHeight(theme.buyAlgoButtonHeight)
        }
    }


    private func addBottomSeparator(
        _ theme: AlgosDetailInfoViewTheme
    ) {
        bottomSeparator.backgroundColor = theme.separator.color

        addSubview(bottomSeparator)
        bottomSeparator.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.equalToSuperview().inset(theme.bottomPadding)
            $0.fitToHeight(theme.separator.size)
        }
    }
}

extension AlgosDetailInfoView: RewardsInfoViewDelegate {
    func rewardsInfoViewDidTapInfoButton(_ rewardsInfoView: RewardsInfoView) {
        delegate?.algosDetailInfoViewDidTapInfoButton(self)
    }

    @objc
    private func didTapBuy() {
        delegate?.algosDetailInfoViewDidTapBuyButton(self)
    }
}

protocol AlgosDetailInfoViewDelegate: AnyObject {
    func algosDetailInfoViewDidTapInfoButton(_ algosDetailInfoView: AlgosDetailInfoView)
    func algosDetailInfoViewDidTapBuyButton(_ algosDetailInfoView: AlgosDetailInfoView)
}
