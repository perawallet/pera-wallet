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

//   AssetTransactionHistoryLoadingView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AssetTransactionHistoryLoadingView:
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

    private lazy var topSeparator = UIView()

    private lazy var assetNameLabel = GradientView(
        gradientStartColor: AppColors.Shared.Layer.gray.uiColor,
        gradientEndColor: AppColors.Shared.Layer.grayLighter.uiColor.withAlphaComponent(0.5)
    )

    private lazy var assetIDButton = GradientView(
        gradientStartColor: AppColors.Shared.Layer.gray.uiColor,
        gradientEndColor: AppColors.Shared.Layer.grayLighter.uiColor.withAlphaComponent(0.5)
    )

    private lazy var bottomSeparator = UIView()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        linkInteractors()
    }

    func customize(
        _ theme: AssetTransactionHistoryLoadingViewTheme
    ) {
        addTitleView(theme)
        addBalanceView(theme)
        addCurrencyView(theme)
        addTopSeparator(theme)
        addAssetNameLabel(theme)
        addAssetIDButton(theme)
        addBottomSeparator(theme)
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

extension AssetTransactionHistoryLoadingView {
    private func addTitleView(_ theme: AssetTransactionHistoryLoadingViewTheme) {
        titleView.draw(corner: Corner(radius: theme.titleViewCorner))

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.titleMargin.top)
            $0.leading.equalToSuperview()
            $0.fitToSize(theme.titleViewSize)
        }
    }

    private func addBalanceView(_ theme: AssetTransactionHistoryLoadingViewTheme) {
        balanceView.draw(corner: Corner(radius: theme.balanceViewCorner))

        addSubview(balanceView)
        balanceView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(theme.balanceViewMargin.top)
            $0.leading.equalToSuperview()
            $0.fitToSize(theme.balanceViewSize)
        }
    }

    private func addCurrencyView(_ theme: AssetTransactionHistoryLoadingViewTheme) {
        currencyView.draw(corner: Corner(radius: theme.balanceViewCorner))

        addSubview(currencyView)
        currencyView.snp.makeConstraints {
            $0.top.equalTo(balanceView.snp.bottom).offset(theme.currencyViewMargin.top)
            $0.leading.equalToSuperview()
            $0.fitToSize(theme.currencyViewSize)
        }
    }

    private func addTopSeparator(
        _ theme: AssetTransactionHistoryLoadingViewTheme
    ) {
        topSeparator.backgroundColor = theme.separator.color

        addSubview(topSeparator)
        topSeparator.snp.makeConstraints {
            $0.top.equalTo(currencyView.snp.bottom).offset(theme.separatorPadding)
            $0.leading.trailing.equalToSuperview()
            $0.fitToHeight(theme.separator.size)
        }
    }

    private func addAssetNameLabel(
        _ theme: AssetTransactionHistoryLoadingViewTheme
    ) {
        assetNameLabel.draw(corner: Corner(radius: theme.titleViewCorner))

        addSubview(assetNameLabel)
        assetNameLabel.snp.makeConstraints {
            $0.top.equalTo(topSeparator.snp.bottom).offset(theme.assetNameLabelTopPadding)
            $0.leading.equalToSuperview()
            $0.fitToSize(theme.assetNameLabelSize)
        }
    }

    private func addAssetIDButton(
        _ theme: AssetTransactionHistoryLoadingViewTheme
    ) {
        assetIDButton.draw(corner: Corner(radius: theme.titleViewCorner))

        addSubview(assetIDButton)
        assetIDButton.snp.makeConstraints {
            $0.top.equalTo(assetNameLabel.snp.bottom).offset(theme.assetIDButtonTopPadding)
            $0.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.fitToSize(theme.assetIDButtonSize)
        }
    }

    private func addBottomSeparator(
        _ theme: AssetTransactionHistoryLoadingViewTheme
    ) {
        bottomSeparator.backgroundColor = theme.separator.color

        addSubview(bottomSeparator)
        bottomSeparator.snp.makeConstraints {
            $0.top.equalTo(assetIDButton.snp.bottom).offset(theme.separatorPadding)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(theme.bottomPadding)
            $0.fitToHeight(theme.separator.size)
        }
    }
}

extension AssetTransactionHistoryLoadingView {
    static func height(for theme: AssetTransactionHistoryLoadingViewTheme) -> LayoutMetric {
        theme.titleViewSize.h +
        theme.titleMargin.top +
        theme.balanceViewSize.h +
        theme.balanceViewMargin.top +
        theme.currencyViewSize.h +
        theme.currencyViewMargin.top +
        theme.separatorPadding +
        theme.separator.size +
        theme.assetNameLabelTopPadding +
        theme.assetNameLabelSize.h +
        theme.assetIDButtonTopPadding +
        theme.assetIDButtonSize.h +
        theme.separatorPadding +
        theme.separator.size +
        theme.bottomPadding
    }
}
