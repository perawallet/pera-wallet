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

//   ASAAboutLoadingView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ASAAboutLoadingView:
    UIView,
    ShimmerAnimationDisplaying {
    private lazy var statisticsView = UIView()
    private lazy var statisticsTitleView = ShimmerView()
    private lazy var statisticsValueView = HStackView()
    private lazy var priceTitleView = ShimmerView()
    private lazy var priceValueView = ShimmerView()
    private lazy var totalSupplyTitleView = ShimmerView()
    private lazy var totalSupplyValueView = ShimmerView()
    private lazy var aboutView = UIView()
    private lazy var aboutTitleView = ShimmerView()
    private lazy var aboutValueView = VStackView()
    private lazy var aboutItem1TitleView = ShimmerView()
    private lazy var aboutItem1ValueView = ShimmerView()
    private lazy var aboutItem2TitleView = ShimmerView()
    private lazy var aboutItem2ValueView = ShimmerView()
    private lazy var aboutItem3TitleView = ShimmerView()
    private lazy var aboutItem3ValueView = ShimmerView()
    private lazy var descriptionView = UIView()
    private lazy var descriptionTitleView = ShimmerView()
    private lazy var descriptionValueView = ShimmerView()
    private lazy var descriptionAccessoryView = ShimmerView()

    func customize(_ theme: ASAAboutLoadingViewTheme) {
        addBackground(theme)
        addStatistics(theme)
        addAbout(theme)
        addDescription(theme)
    }
}

extension ASAAboutLoadingView {
    private func addBackground(_ theme: ASAAboutLoadingViewTheme) {
        customizeAppearance(theme.background)
    }

    private func addStatistics(_ theme: ASAAboutLoadingViewTheme) {
        addSubview(statisticsView)
        statisticsView.snp.makeConstraints {
            $0.top == theme.contentEdgeInsets.top
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
        }

        attachSeparator(
            theme.separator,
            to: statisticsView,
            margin: theme.spacingBetweenSectionAndSeparator
        )

        addStatisticsTitle(theme)
        addStatisticsValue(theme)
    }

    private func addStatisticsTitle(_ theme: ASAAboutLoadingViewTheme) {
        statisticsTitleView.drawAppearance(corner: theme.corner)

        statisticsView.addSubview(statisticsTitleView)
        statisticsTitleView.snp.makeConstraints {
            $0.fitToSize(theme.statisticsTitleSize)
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addStatisticsValue(_ theme: ASAAboutLoadingViewTheme) {
        statisticsView.addSubview(statisticsValueView)
        statisticsValueView.distribution = .fillEqually
        statisticsValueView.alignment = .top
        statisticsValueView.spacing = theme.spacingBetweenStatisticsItems
        statisticsValueView.snp.makeConstraints {
            $0.top == statisticsTitleView.snp.bottom + theme.spacingBetweenStatisticsTitleAndValue
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        addPrice(theme)
        addTotalSupply(theme)
    }

    private func addPrice(_ theme: ASAAboutLoadingViewTheme) {
        let priceView = UIView()

        priceTitleView.drawAppearance(corner: theme.corner)

        priceView.addSubview(priceTitleView)
        priceTitleView.snp.makeConstraints {
            $0.fitToSize(theme.statisticsItemTitleSize)
            $0.top == 0
            $0.leading == 0
            $0.trailing <= 0
        }

        priceValueView.drawAppearance(corner: theme.corner)

        priceView.addSubview(priceValueView)
        priceValueView.snp.makeConstraints {
            $0.fitToSize(theme.statisticsItemValueSize)
            $0.top == priceTitleView.snp.bottom + theme.spacingBetweenStatisticsItemTitleAndValue
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }

        statisticsValueView.addArrangedSubview(priceView)
    }

    private func addTotalSupply(_ theme: ASAAboutLoadingViewTheme) {
        let totalSupplyView = UIView()

        totalSupplyTitleView.drawAppearance(corner: theme.corner)

        totalSupplyView.addSubview(totalSupplyTitleView)
        totalSupplyTitleView.snp.makeConstraints {
            $0.fitToSize(theme.statisticsItemTitleSize)
            $0.top == 0
            $0.leading == 0
            $0.trailing <= 0
        }

        totalSupplyValueView.drawAppearance(corner: theme.corner)

        totalSupplyView.addSubview(totalSupplyValueView)
        totalSupplyValueView.snp.makeConstraints {
            $0.fitToSize(theme.statisticsItemValueSize)
            $0.top == totalSupplyTitleView.snp.bottom + theme.spacingBetweenStatisticsItemTitleAndValue
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }

        statisticsValueView.addArrangedSubview(totalSupplyView)
    }

    private func addAbout(_ theme: ASAAboutLoadingViewTheme) {
        addSubview(aboutView)
        aboutView.snp.makeConstraints {
            $0.top == statisticsView.snp.bottom + theme.spacingBetweenStatisticsAndAbout
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
        }

        attachSeparator(
            theme.separator,
            to: aboutView,
            margin: theme.spacingBetweenSectionAndSeparator
        )

        addAboutTitle(theme)
        addAboutValue(theme)
    }

    private func addAboutTitle(_ theme: ASAAboutLoadingViewTheme) {
        aboutTitleView.drawAppearance(corner: theme.corner)

        aboutView.addSubview(aboutTitleView)
        aboutTitleView.snp.makeConstraints {
            $0.fitToSize(theme.aboutTitleSize)
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addAboutValue(_ theme: ASAAboutLoadingViewTheme) {
        aboutView.addSubview(aboutValueView)
        aboutValueView.distribution = .fill
        aboutValueView.alignment = .fill
        aboutValueView.spacing = theme.spacingBetweenAboutItems
        aboutValueView.snp.makeConstraints {
            $0.top == aboutTitleView.snp.bottom + theme.spacingBetweenAboutTitleAndValue
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        addAboutItem1(theme)
        addAboutItem2(theme)
        addAboutItem3(theme)
    }

    private func addAboutItem1(_ theme: ASAAboutLoadingViewTheme) {
        let itemView = UIView()

        aboutItem1TitleView.drawAppearance(corner: theme.corner)

        itemView.addSubview(aboutItem1TitleView)
        aboutItem1TitleView.snp.makeConstraints {
            $0.fitToSize(theme.aboutItemTitleSize)
            $0.top >= 0
            $0.leading == 0
            $0.bottom <= 0
            $0.centerY == 0
        }

        aboutItem1ValueView.drawAppearance(corner: theme.corner)

        itemView.addSubview(aboutItem1ValueView)
        aboutItem1ValueView.snp.makeConstraints {
            $0.fitToSize(theme.aboutItemValueSize)
            $0.top >= 0
            $0.bottom <= 0
            $0.trailing == 0
            $0.centerY == 0
        }

        aboutValueView.addArrangedSubview(itemView)
    }

    private func addAboutItem2(_ theme: ASAAboutLoadingViewTheme) {
        let itemView = UIView()

        aboutItem2TitleView.drawAppearance(corner: theme.corner)

        itemView.addSubview(aboutItem2TitleView)
        aboutItem2TitleView.snp.makeConstraints {
            $0.fitToSize(theme.aboutItemTitleSize)
            $0.top >= 0
            $0.leading == 0
            $0.bottom <= 0
            $0.centerY == 0
        }

        aboutItem2ValueView.drawAppearance(corner: theme.corner)

        itemView.addSubview(aboutItem2ValueView)
        aboutItem2ValueView.snp.makeConstraints {
            $0.fitToSize(theme.aboutItemValueSize)
            $0.top >= 0
            $0.bottom <= 0
            $0.trailing == 0
            $0.centerY == 0
        }

        aboutValueView.addArrangedSubview(itemView)
    }

    private func addAboutItem3(_ theme: ASAAboutLoadingViewTheme) {
        let itemView = UIView()

        aboutItem3TitleView.drawAppearance(corner: theme.corner)

        itemView.addSubview(aboutItem3TitleView)
        aboutItem3TitleView.snp.makeConstraints {
            $0.fitToSize(theme.aboutItemTitleSize)
            $0.top >= 0
            $0.leading == 0
            $0.bottom <= 0
            $0.centerY == 0
        }

        aboutItem3ValueView.drawAppearance(corner: theme.corner)

        itemView.addSubview(aboutItem3ValueView)
        aboutItem3ValueView.snp.makeConstraints {
            $0.fitToSize(theme.aboutItemValueSize)
            $0.top >= 0
            $0.bottom <= 0
            $0.trailing == 0
            $0.centerY == 0
        }

        aboutValueView.addArrangedSubview(itemView)
    }

    private func addDescription(_ theme: ASAAboutLoadingViewTheme) {
        addSubview(descriptionView)
        descriptionView.snp.makeConstraints {
            $0.top == aboutView.snp.bottom + theme.spacingBetweenAboutAndDescription
            $0.leading == theme.contentEdgeInsets.leading
            $0.bottom == 0
            $0.trailing == theme.contentEdgeInsets.trailing
        }

        attachSeparator(
            theme.separator,
            to: descriptionView,
            margin: theme.spacingBetweenSectionAndSeparator
        )

        addDescriptionTitle(theme)
        addDescriptionValue(theme)
        addDescriptionAccessory(theme)
    }

    private func addDescriptionTitle(_ theme: ASAAboutLoadingViewTheme) {
        descriptionTitleView.drawAppearance(corner: theme.corner)

        descriptionView.addSubview(descriptionTitleView)
        descriptionTitleView.snp.makeConstraints {
            $0.fitToSize(theme.descriptionTitleSize)
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addDescriptionValue(_ theme: ASAAboutLoadingViewTheme) {
        descriptionValueView.drawAppearance(corner: theme.corner)

        descriptionView.addSubview(descriptionValueView)
        descriptionValueView.snp.makeConstraints {
            $0.fitToHeight(theme.descriptionValueHeight)
            $0.top == descriptionTitleView.snp.bottom + theme.spacingBetweenDescriptionTitleAndValue
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addDescriptionAccessory(_ theme: ASAAboutLoadingViewTheme) {
        descriptionAccessoryView.drawAppearance(corner: theme.corner)

        descriptionView.addSubview(descriptionAccessoryView)
        descriptionAccessoryView.snp.makeConstraints {
            $0.fitToSize(theme.descriptionAccessorySize)
            $0.top == descriptionValueView.snp.bottom + theme.spacingBetweenDescriptionValueAndAccessory
            $0.leading == 0
            $0.bottom == 0
        }
    }
}
