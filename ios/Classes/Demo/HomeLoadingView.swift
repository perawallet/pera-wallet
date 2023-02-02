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
//   HomeLoadingView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class HomeLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    private lazy var theme = HomeLoadingViewTheme()

    private lazy var contentView = UIView()
    private lazy var portfolioView = UIView()
    private lazy var portfolioTitleView = UILabel()
    private lazy var portfolioInfoView = MacaroonUIKit.Button()
    private lazy var portfolioPrimaryValueView = ShimmerView()
    private lazy var portfolioSecondaryValueView = ShimmerView()
    private lazy var quickActionsView = HomeQuickActionsView()
    private lazy var accountsHeaderView = ManagementItemView()
    private lazy var accountsView = VStackView()
    private lazy var backgroundView = UIView()

    var isSwapBadgeVisible: Bool = false {
        didSet {
            quickActionsView.isSwapBadgeVisible = isSwapBadgeVisible
        }
    }
    
    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        addContent()
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension HomeLoadingView {
    private func addContent() {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == theme.contentEdgeInsets.top
            $0.leading == theme.contentEdgeInsets.leading
            $0.bottom == theme.contentEdgeInsets.bottom
            $0.trailing == theme.contentEdgeInsets.trailing
        }

        addPortfolio()
        addAccounts()
        addBackground()
    }

    private func addPortfolio() {
        contentView.addSubview(portfolioView)
        portfolioView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        addPortfolioTitle()
        addPortfolioValues()
        addQuickActions()
    }

    private func addPortfolioTitle() {
        portfolioTitleView.customizeAppearance(theme.portfolioTitle)

        portfolioView.addSubview(portfolioTitleView)
        portfolioTitleView.fitToIntrinsicSize()
        portfolioTitleView.snp.makeConstraints {
            $0.top == theme.portfolioTitleTopPadding
            $0.centerX == 0
        }

        portfolioInfoView.customizeAppearance(theme.portfolioInfoAction)
        portfolioInfoView.isUserInteractionEnabled = false

        portfolioView.addSubview(portfolioInfoView)
        portfolioInfoView.snp.makeConstraints {
            $0.leading == portfolioTitleView.snp.trailing +
                theme.spacingBetweenPortfolioTitleAndPortfolioInfoAction
            $0.centerY == portfolioTitleView
        }
    }

    private func addPortfolioValues() {
        portfolioPrimaryValueView.draw(corner: theme.portfolioValueCorner)

        portfolioView.addSubview(portfolioPrimaryValueView)
        portfolioPrimaryValueView.snp.makeConstraints {
            $0.fitToSize(theme.primaryPortfolioValueSize)
            $0.top == portfolioTitleView.snp.bottom +
                theme.spacingBetweenPortfolioTitleAndPrimaryPortfolioValue
            $0.centerX == 0
        }

        portfolioSecondaryValueView.draw(corner: theme.portfolioValueCorner)

        portfolioView.addSubview(portfolioSecondaryValueView)
        portfolioSecondaryValueView.snp.makeConstraints {
            $0.fitToSize(theme.secondaryPortfolioValueSize)
            $0.top == portfolioPrimaryValueView.snp.bottom +
                theme.spacingBetweenPrimaryPortfolioValueAndSecondaryPortfolioValue
            $0.centerX == 0
        }
    }

    private func addQuickActions() {
        let quickActionsTheme = theme.quickActions

        quickActionsView.customize(quickActionsTheme)
        quickActionsView.isUserInteractionEnabled = false

        /// <todo>
        /// It should calculate its own size.
        let quickActionsSize = HomeQuickActionsView.calculatePreferredSize(
            for: quickActionsTheme,
            fittingIn: CGSize(
                width: UIScreen.main.bounds.width -
                    theme.contentEdgeInsets.leading -
                    theme.contentEdgeInsets.trailing,
                height: .greatestFiniteMagnitude
            )
        )

        portfolioView.addSubview(quickActionsView)
        quickActionsView.snp.makeConstraints {
            $0.fitToHeight(quickActionsSize.height)
            $0.top == portfolioSecondaryValueView.snp.bottom +
                theme.spacingBetweenQuickActionsAndSecondaryPortfolioValue
            $0.leading == 0
            $0.bottom == theme.quickActionsBottomPadding
            $0.trailing == 0
        }
    }

    private func addAccounts() {
        let accountsHeaderTheme = theme.accountsHeader
        let accountsHeaderViewModel = ManagementItemViewModel(.account)

        accountsHeaderView.customize(accountsHeaderTheme)
        accountsHeaderView.bindData(accountsHeaderViewModel)
        accountsHeaderView.isUserInteractionEnabled = false

        /// <todo>
        /// It should calculate its own size.
        let accountsHeaderSize = ManagementItemView.calculatePreferredSize(
            accountsHeaderViewModel,
            for: accountsHeaderTheme,
            fittingIn: CGSize(
                width: UIScreen.main.bounds.width -
                    theme.contentEdgeInsets.leading -
                    theme.contentEdgeInsets.trailing,
                height: .greatestFiniteMagnitude
            )
        )

        contentView.addSubview(accountsHeaderView)
        accountsHeaderView.snp.makeConstraints {
            $0.fitToHeight(accountsHeaderSize.height)
            $0.top == portfolioView.snp.bottom + theme.spacingBetweenAccountsHeaderAndPortfolio
            $0.leading == 0
            $0.trailing == 0
        }

        contentView.addSubview(accountsView)
        accountsView.directionalLayoutMargins = theme.accountsContentEdgeInsets
        accountsView.isLayoutMarginsRelativeArrangement = true
        accountsView.snp.makeConstraints {
            $0.top == accountsHeaderView.snp.bottom
            $0.leading == 0
            $0.trailing == 0
        }

        (1...theme.numberOfAccounts).forEach { i in
            let accountView = PreviewLoadingView()
            accountView.customize(theme.account)
            accountsView.addArrangedSubview(accountView)
            accountView.snp.makeConstraints {
                $0.fitToHeight(theme.accountHeight)
            }

            if i != theme.numberOfAccounts {
                accountView.addSeparator(theme.accountSeparator)
            }
        }
    }

    private func addBackground() {
        backgroundView.customizeAppearance(theme.background)

        insertSubview(
            backgroundView,
            at: 0
        )
        backgroundView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == portfolioView
            $0.trailing == 0
        }
    }
}
