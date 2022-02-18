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
//   AlgoTransactionHistoryLoadingView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AlgoTransactionHistoryLoadingView:
    View,
    ListReusable {

    private lazy var titleView = GradientView(
        gradientStartColor: AppColors.Shared.Layer.gray.uiColor,
        gradientEndColor: AppColors.Shared.Layer.grayLighter.uiColor.withAlphaComponent(0.5)
    )

    private lazy var balanceView = GradientView(
        gradientStartColor: AppColors.Shared.Layer.gray.uiColor,
        gradientEndColor: AppColors.Shared.Layer.grayLighter.uiColor.withAlphaComponent(0.5)
    )

    private lazy var currencyView = GradientView(
        gradientStartColor: AppColors.Shared.Layer.gray.uiColor,
        gradientEndColor: AppColors.Shared.Layer.grayLighter.uiColor.withAlphaComponent(0.5)
    )

    private lazy var rewardsContainer = TripleShadowView()

    private lazy var rewardsImage = ImageView()
    private lazy var rewardsTitle = GradientView(
        gradientStartColor: AppColors.Shared.Layer.gray.uiColor,
        gradientEndColor: AppColors.Shared.Layer.grayLighter.uiColor.withAlphaComponent(0.5)
    )
    private lazy var rewardsSubtitle = GradientView(
        gradientStartColor: AppColors.Shared.Layer.gray.uiColor,
        gradientEndColor: AppColors.Shared.Layer.grayLighter.uiColor.withAlphaComponent(0.5)
    )
    private lazy var rewardsSupplementaryImage = UIImageView()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        linkInteractors()
    }

    func customize(
        _ theme: AlgoTransactionHistoryLoadingViewTheme
    ) {
        addTitleView(theme)
        addBalanceView(theme)
        addCurrencyView(theme)
        addRewardsView(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func linkInteractors() {
        isUserInteractionEnabled = false
    }
}

extension AlgoTransactionHistoryLoadingView {
    private func addTitleView(_ theme: AlgoTransactionHistoryLoadingViewTheme) {
        titleView.draw(corner: Corner(radius: theme.titleViewCorner))

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.titleMargin.top)
            $0.leading.equalToSuperview()
            $0.size.equalTo(
                CGSize(width: theme.titleViewSize.w,
                       height: theme.titleViewSize.h)
            )
        }
    }

    private func addBalanceView(_ theme: AlgoTransactionHistoryLoadingViewTheme) {
        balanceView.draw(corner: Corner(radius: theme.balanceViewCorner))

        addSubview(balanceView)
        balanceView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(theme.balanceViewMargin.top)
            $0.leading.equalToSuperview()
            $0.size.equalTo(
                CGSize(width: theme.balanceViewSize.w,
                       height: theme.balanceViewSize.h)
            )
        }
    }

    private func addCurrencyView(_ theme: AlgoTransactionHistoryLoadingViewTheme) {
        currencyView.draw(corner: Corner(radius: theme.balanceViewCorner))

        addSubview(currencyView)
        currencyView.snp.makeConstraints {
            $0.top.equalTo(balanceView.snp.bottom).offset(theme.currencyViewMargin.top)
            $0.leading.equalToSuperview()
            $0.size.equalTo(
                CGSize(width: theme.currencyViewSize.w,
                       height: theme.currencyViewSize.h)
            )
        }
    }

    private func addRewardsView(_ theme: AlgoTransactionHistoryLoadingViewTheme) {
        rewardsContainer.draw(corner: theme.rewardsContainerCorner)
        rewardsContainer.drawAppearance(border: theme.rewardsContainerBorder)

        rewardsContainer.drawAppearance(shadow: theme.rewardsContainerFirstShadow)
        rewardsContainer.drawAppearance(secondShadow: theme.rewardsContainerSecondShadow)
        rewardsContainer.drawAppearance(thirdShadow: theme.rewardsContainerThirdShadow)

        addSubview(rewardsContainer)
        rewardsContainer.snp.makeConstraints {
            $0.top.equalTo(currencyView.snp.bottom).offset(theme.rewardsContainerMargin.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(theme.rewardsContainerSize.h)
            $0.bottom.equalToSuperview().inset(theme.rewardsContainerMargin.bottom)
        }

        addRewardsItemsView(theme)
    }

    private func addRewardsItemsView(_ theme: AlgoTransactionHistoryLoadingViewTheme) {
        addRewardsImageView(theme)
        addRewardsTitleView(theme)
        addRewardsSubtitleView(theme)
        addRewardsSupplementaryView(theme)
    }

    private func addRewardsImageView(_ theme: AlgoTransactionHistoryLoadingViewTheme) {
        rewardsImage.backgroundColor = theme.rewardsImageViewBackgroundColor
        rewardsImage.layer.cornerRadius = theme.rewardsImageViewCorner

        rewardsContainer.addSubview(rewardsImage)
        rewardsImage.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.rewardsImageViewMargin.leading)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(
                CGSize(width: theme.rewardsImageViewSize.w,
                       height: theme.rewardsImageViewSize.h)
            )
        }
    }

    private func addRewardsTitleView(_ theme: AlgoTransactionHistoryLoadingViewTheme) {
        rewardsTitle.draw(corner: Corner(radius: theme.balanceViewCorner))

        rewardsContainer.addSubview(rewardsTitle)
        rewardsTitle.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.rewardsTitleViewMargin.top)
            $0.leading.equalTo(rewardsImage.snp.trailing).offset(theme.rewardsTitleViewMargin.leading)
            $0.size.equalTo(
                CGSize(width: theme.rewardsTitleViewSize.w,
                       height: theme.rewardsTitleViewSize.h)
            )
        }
    }

    private func addRewardsSubtitleView(_ theme: AlgoTransactionHistoryLoadingViewTheme) {
        rewardsSubtitle.draw(corner: Corner(radius: theme.rewardsSubtitleViewCorner))

        rewardsContainer.addSubview(rewardsSubtitle)
        rewardsSubtitle.snp.makeConstraints {
            $0.top.equalTo(rewardsTitle.snp.bottom).offset(theme.rewardsSubtitleViewMargin.top)
            $0.leading.equalTo(rewardsImage.snp.trailing).offset(theme.rewardsSubtitleViewMargin.leading)
            $0.size.equalTo(
                CGSize(width: theme.rewardsSubtitleViewSize.w,
                       height: theme.rewardsSubtitleViewSize.h)
            )
        }
    }

    private func addRewardsSupplementaryView(_ theme: AlgoTransactionHistoryLoadingViewTheme) {
        rewardsSupplementaryImage.customizeAppearance(theme.rewardsSupplementaryViewImage)

        rewardsContainer.addSubview(rewardsSupplementaryImage)
        rewardsSupplementaryImage.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.rewardsSupplementaryViewMargin.trailing)
            $0.centerY.equalToSuperview()
        }
    }
}

extension AlgoTransactionHistoryLoadingView {
    static func height(for theme: AlgoTransactionHistoryLoadingViewTheme) -> LayoutMetric {
        theme.titleViewSize.h +
        theme.titleMargin.top +
        theme.balanceViewSize.h +
        theme.balanceViewMargin.top +
        theme.currencyViewSize.h +
        theme.currencyViewMargin.top +
        theme.rewardsContainerSize.h +
        theme.rewardsContainerMargin.top +
        theme.rewardsContainerMargin.bottom
    }
}
