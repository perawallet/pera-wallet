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
//   AlgoStatisticsLoadingView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AlgoStatisticsLoadingView:
    View,
    ListReusable {

    private lazy var priceView = GradientView(
        gradientStartColor: AppColors.Shared.Layer.gray.uiColor,
        gradientEndColor: AppColors.Shared.Layer.grayLighter.uiColor.withAlphaComponent(0.5)
    )

    private lazy var priceSubview = GradientView(
        gradientStartColor: AppColors.Shared.Layer.gray.uiColor,
        gradientEndColor: AppColors.Shared.Layer.grayLighter.uiColor.withAlphaComponent(0.5)
    )

    private lazy var statsImageView = ImageView()

    private lazy var controlView = GradientView(
        gradientStartColor: AppColors.Shared.Layer.gray.uiColor,
        gradientEndColor: AppColors.Shared.Layer.grayLighter.uiColor.withAlphaComponent(0.5)
    )

    private lazy var headerLoading = GradientView(
        gradientStartColor: AppColors.Shared.Layer.gray.uiColor,
        gradientEndColor: AppColors.Shared.Layer.grayLighter.uiColor.withAlphaComponent(0.5)
    )

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        linkInteractors()
    }

    func customize(
        _ theme: AlgoStatisticsLoadingViewTheme
    ) {
        addPriceView(theme)
        addPriceSubview(theme)
        addStatsView(theme)
        addControlView(theme)
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

extension AlgoStatisticsLoadingView {
    private func addPriceView(_ theme: AlgoStatisticsLoadingViewTheme) {
        priceView.draw(corner: theme.loadingCorner)

        addSubview(priceView)
        priceView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.priceViewMargin.top)
            $0.leading.equalToSuperview().inset(theme.priceViewMargin.leading)
            $0.size.equalTo(
                CGSize(width: theme.priceViewSize.w,
                       height: theme.priceViewSize.h)
            )
        }
    }

    private func addPriceSubview(_ theme: AlgoStatisticsLoadingViewTheme) {
        priceSubview.draw(corner: theme.loadingCorner)

        addSubview(priceSubview)
        priceSubview.snp.makeConstraints {
            $0.top.equalTo(priceView.snp.bottom).offset(theme.priceSubviewMargin.top)
            $0.leading.equalToSuperview().inset(theme.priceSubviewMargin.leading)
            $0.size.equalTo(
                CGSize(width: theme.priceSubviewSize.w,
                       height: theme.priceSubviewSize.h)
            )
        }
    }

    private func addStatsView(_ theme: AlgoStatisticsLoadingViewTheme) {
        statsImageView.customizeAppearance(theme.statsImage)

        addSubview(statsImageView)
        statsImageView.snp.makeConstraints {
            $0.top.equalTo(priceSubview.snp.bottom).offset(theme.statsMargin.top)
            $0.leading.equalToSuperview().inset(theme.statsMargin.leading)
            $0.trailing.equalToSuperview().inset(theme.statsMargin.trailing)
            $0.height.equalTo(
                theme.statsHeight
            )
        }
    }

    private func addControlView(_ theme: AlgoStatisticsLoadingViewTheme) {
        controlView.draw(corner: theme.loadingCorner)

        addSubview(controlView)
        controlView.snp.makeConstraints {
            $0.top.equalTo(statsImageView.snp.bottom).offset(theme.controlViewMargin.top)
            $0.leading.equalToSuperview().inset(theme.controlViewMargin.leading)
            $0.trailing.equalToSuperview().inset(theme.controlViewMargin.trailing)
            $0.height.equalTo(
                theme.controlViewHeight
            )
        }
    }

    private func addHeaderView(_ theme: AlgoStatisticsLoadingViewTheme) {
        headerLoading.draw(corner: theme.loadingCorner)

        addSubview(headerLoading)
        headerLoading.snp.makeConstraints {
            $0.top.equalTo(controlView.snp.bottom).offset(theme.headerLoadingMargin.top)
            $0.leading.equalToSuperview().inset(theme.headerLoadingMargin.leading)
            $0.size.equalTo(
                CGSize(width: theme.headerLoadingSize.w, height: theme.headerLoadingSize.h)
            )
        }
    }

    private func addItems(_ theme: AlgoStatisticsLoadingViewTheme) {
        var latestView: UIView? = headerLoading

        for index in 0...2 {
            guard let topView = latestView else {
                continue
            }

            let itemContainerView = UIView()
            let leftView = GradientView(
                gradientStartColor: AppColors.Shared.Layer.gray.uiColor,
                gradientEndColor: AppColors.Shared.Layer.grayLighter.uiColor.withAlphaComponent(0.5)
            )
            leftView.draw(corner: theme.loadingCorner)

            let rightView = GradientView(
                gradientStartColor: AppColors.Shared.Layer.gray.uiColor,
                gradientEndColor: AppColors.Shared.Layer.grayLighter.uiColor.withAlphaComponent(0.5)
            )
            rightView.draw(corner: theme.loadingCorner)

            addSubview(itemContainerView)
            itemContainerView.snp.makeConstraints {
                if topView == headerLoading {
                    $0.top.equalTo(topView.snp.bottom).offset(theme.firstItemTopInset)
                } else {
                    $0.top.equalTo(topView.snp.bottom)
                }
                $0.leading.trailing.equalToSuperview().inset(theme.itemLeadingInset)
                $0.height.equalTo(theme.itemHeight)
            }

            if index < 2 {
                itemContainerView.addSeparator(
                    theme.itemContainerSeparator
                )
            }

            itemContainerView.addSubview(leftView)
            leftView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview()
                $0.size.equalTo(
                    CGSize(width: theme.itemLeftSize.w, height: theme.itemLeftSize.h)
                )
            }

            let rightItemSize: LayoutSize

            if index == 0 {
                rightItemSize = theme.firstRightItemSize
            } else if index == 1 {
                rightItemSize = theme.secondRightItemSize
            } else {
                rightItemSize = theme.thirdRightItemSize
            }

            itemContainerView.addSubview(rightView)
            rightView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview()
                $0.size.equalTo(
                    CGSize(width: rightItemSize.w, height: rightItemSize.h)
                )
            }

            latestView = itemContainerView
        }
        latestView = nil
    }
}
