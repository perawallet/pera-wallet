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
    private lazy var bottomSeparator = UIView()

    func customize(
        _ theme: AlgosDetailInfoViewTheme
    ) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addYourBalanceTitleLabel(theme)
        addAlgosValueLabel(theme)
        addSecondaryValueLabel(theme)
        addRewardsInfoView(theme)
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
        yourBalanceTitleLabel.editText = viewModel?.yourBalanceTitle
        algosValueLabel.editText = viewModel?.totalAmount
        secondaryValueLabel.editText = viewModel?.secondaryValue
        rewardsInfoView.bindData(viewModel?.rewardsInfoViewModel)
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
        let yourBalanceTitleSize = viewModel.yourBalanceTitle.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let amountSize = viewModel.totalAmount.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let rewardsInfoSize = RewardsInfoView.calculatePreferredSize(
            viewModel.rewardsInfoViewModel,
            for: theme.rewardsInfoViewTheme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        var preferredHeight =
        theme.topPadding +
        yourBalanceTitleSize.height +
        theme.algosValueLabelTopPadding +
        amountSize.height +
        theme.rewardsInfoViewTopPadding +
        rewardsInfoSize.height +
        theme.separatorPadding +
        theme.separator.size +
        theme.bottomPadding

        if !viewModel.secondaryValue.isNilOrEmpty {
            let secondaryValueLabelSize = viewModel.secondaryValue.boundingSize(
                multiline: false,
                fittingSize: CGSize((width, .greatestFiniteMagnitude))
            )

            preferredHeight =
            preferredHeight +
            theme.secondaryValueLabelTopPadding +
            secondaryValueLabelSize.height
        }

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }

    func setListeners() {
        rewardsInfoView.setListeners()
        rewardsInfoView.delegate = self
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
        rewardsInfoView.customize(theme.rewardsInfoViewTheme)

        addSubview(rewardsInfoView)
        rewardsInfoView.snp.makeConstraints {
            $0.top.equalTo(secondaryValueLabel.snp.bottom).offset(theme.rewardsInfoViewTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addBottomSeparator(
        _ theme: AlgosDetailInfoViewTheme
    ) {
        bottomSeparator.backgroundColor = theme.separator.color

        addSubview(bottomSeparator)
        bottomSeparator.snp.makeConstraints {
            $0.top.equalTo(rewardsInfoView.snp.bottom).offset(theme.separatorPadding)
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
}

protocol AlgosDetailInfoViewDelegate: AnyObject {
    func algosDetailInfoViewDidTapInfoButton(_ algosDetailInfoView: AlgosDetailInfoView)
}
