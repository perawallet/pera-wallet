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

//   ASADetailLoadingView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ASADetailLoadingView:
    UIView,
    ShimmerAnimationDisplaying,
    UIScrollViewDelegate {
    var animatableSubviews: [ShimmerAnimatable] {
        var subviews: [ShimmerAnimatable] = [
            iconView,
            titleView,
            primaryValueView,
            secondaryValueView
        ]
        subviews += activityView.animatableSubviews
        subviews += aboutView.animatableSubviews
        return subviews
    }

    private lazy var profileView = UIView()
    private lazy var iconView = ShimmerView()
    private lazy var titleView = ShimmerView()
    private lazy var primaryValueView = ShimmerView()
    private lazy var secondaryValueView = ShimmerView()
    private lazy var quickActionsView = HStackView()
    private lazy var pageBar = PageBar()
    private lazy var pagesView = UIScrollView()
    private lazy var activityContainerView = UIView()
    private lazy var activityView = TransactionHistoryLoadingView()
    private lazy var aboutView = ASAAboutLoadingView()

    func customize(_ theme: ASADetailLoadingViewTheme) {
        addBackground(theme)
        addProfile(theme)
        addQuickActions(theme)
        addPagesFragment(theme)
    }
}

extension ASADetailLoadingView {
    private func addBackground(_ theme: ASADetailLoadingViewTheme) {
        customizeAppearance(theme.background)
    }

    private func addProfile(_ theme: ASADetailLoadingViewTheme) {
        profileView.customizeAppearance(theme.profile)

        addSubview(profileView)
        profileView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        addIcon(theme)
        addTitle(theme)
        addPrimaryValue(theme)
        addSecondaryValue(theme)
    }

    private func addIcon(_ theme: ASADetailLoadingViewTheme) {
        iconView.draw(corner: theme.iconCorner)

        profileView.addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.top == theme.profileTopEdgeInset
            $0.centerX == 0
        }
    }

    private func addTitle(_ theme: ASADetailLoadingViewTheme) {
        titleView.draw(corner: theme.corner)

        profileView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.fitToSize(theme.titleSize)
            $0.top == iconView.snp.bottom + theme.spacingBetweenIconAndTitle
            $0.centerX == 0
        }
    }

    private func addPrimaryValue(_ theme: ASADetailLoadingViewTheme) {
        primaryValueView.draw(corner: theme.corner)

        profileView.addSubview(primaryValueView)
        primaryValueView.snp.makeConstraints {
            $0.fitToSize(theme.primaryValueSize)
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndPrimaryValue
            $0.centerX == 0
        }
    }

    private func addSecondaryValue(_ theme: ASADetailLoadingViewTheme) {
        secondaryValueView.drawAppearance(corner: theme.corner)

        profileView.addSubview(secondaryValueView)
        secondaryValueView.snp.makeConstraints {
            $0.fitToSize(theme.secondaryValueSize)
            $0.top == primaryValueView.snp.bottom + theme.spacingBetweenPrimaryAndSecondaryValue
            $0.bottom == 0
            $0.centerX == 0
        }
    }

    private func addQuickActions(_ theme: ASADetailLoadingViewTheme) {
        addSubview(quickActionsView)
        quickActionsView.distribution = .fillEqually
        quickActionsView.alignment = .top
        quickActionsView.spacing = theme.spacingBetweenQuickActions
        quickActionsView.directionalLayoutMargins = .init(
            top: theme.spacingBetweenProfileAndQuickActions,
            leading: 0,
            bottom: theme.spacingBetweenQuickActionsAndPageBar,
            trailing: 0
        )
        quickActionsView.isLayoutMarginsRelativeArrangement = true
        quickActionsView.snp.makeConstraints {
            $0.top == profileView.snp.bottom
            $0.leading >= 0
            $0.trailing <= 0
            $0.centerX == 0
        }

        let backgroundView = UIView()
        backgroundView.customizeAppearance(theme.quickActions)

        insertSubview(
            backgroundView,
            belowSubview: quickActionsView
        )
        backgroundView.snp.makeConstraints {
            $0.top == quickActionsView
            $0.leading == 0
            $0.bottom == quickActionsView
            $0.trailing == 0
        }

        addQuickAction(
            icon: theme.sendActionIcon,
            title: theme.sendActionTitle,
            theme: theme
        )
        addQuickAction(
            icon: theme.receiveActionIcon,
            title: theme.receiveActionTitle,
            theme: theme
        )
    }

    private func addQuickAction(
        icon: Image,
        title: TextProvider,
        theme: ASADetailLoadingViewTheme
    ) {
        let view = UIView()
        view.snp.makeConstraints {
            $0.fitToWidth(theme.quickActionWidth)
        }

        let iconView = UIImageView()

        iconView.image = icon.uiImage

        view.addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.top == 0
            $0.leading >= 0
            $0.trailing <= 0
            $0.centerX == 0
        }

        let titleView = UILabel()

        title.load(in: titleView)

        view.addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == iconView.snp.bottom + theme.spacingBetweenQuickActionIconAndTitle
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        quickActionsView.addArrangedSubview(view)
    }

    private func addPagesFragment(_ theme: ASADetailLoadingViewTheme) {
        addPageBar(theme)
        addPages(theme)
    }

    private func addPageBar(_ theme: ASADetailLoadingViewTheme) {
        pageBar.customizeAppearance(theme.pageBarStyle)
        pageBar.prepareLayout(theme.pageBarLayout)

        addSubview(pageBar)
        pageBar.snp.makeConstraints {
            $0.top == quickActionsView.snp.bottom
            $0.leading == 0
            $0.trailing == 0
        }

        pageBar.items = [
            theme.activityPageBarItem,
            theme.aboutPageBarItem
        ]
    }

    private func addPages(_ theme: ASADetailLoadingViewTheme) {
        addSubview(pagesView)
        pagesView.bounces = false
        pagesView.showsHorizontalScrollIndicator = false
        pagesView.showsVerticalScrollIndicator = false
        pagesView.isPagingEnabled = true
        pagesView.delegate = self
        pagesView.snp.makeConstraints {
            $0.top == pageBar.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        addActivity(theme)
        addAbout(theme)
    }

    private func addActivity(_ theme: ASADetailLoadingViewTheme) {
        pagesView.addSubview(activityContainerView)
        activityContainerView.snp.makeConstraints {
            $0.width == self
            $0.top == 0
            $0.leading == 0
        }

        activityView.customize(theme.activity)

        activityContainerView.addSubview(activityView)
        activityView.snp.makeConstraints {
            $0.top == theme.activityContentEdgeInsets.top
            $0.leading == theme.activityContentEdgeInsets.leading
            $0.bottom == theme.activityContentEdgeInsets.bottom
            $0.trailing == theme.activityContentEdgeInsets.trailing
        }
    }

    private func addAbout(_ theme: ASADetailLoadingViewTheme) {
        aboutView.customize(theme.about)

        pagesView.addSubview(aboutView)
        aboutView.snp.makeConstraints {
            $0.width == self
            $0.top == 0
            $0.leading == activityContainerView.snp.trailing
            $0.trailing == 0
        }
    }
}

/// <mark>
/// UIScrollViewDelegate
extension ASADetailLoadingView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageBar.scrollToItem(
            at: scrollView.contentOffset.x - pageBar.frame.minX,
            animated: false
        )
    }
}
