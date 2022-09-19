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

//   AssetStatisticsSectionView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AssetStatisticsSectionView:
    MacaroonUIKit.View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .showTotalSupplyInfo: GestureInteraction()
    ]

    private lazy var titleView = UILabel()
    private lazy var statisticsView = HStackView()
    private lazy var priceView = PrimaryTitleView()
    private lazy var totalSupplyView = PrimaryTitleView()
    
    func customize(_ theme: AssetStatisticsSectionViewTheme) {
        addTitle(theme)
        addStatistics(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func bindData(_ viewModel: AssetStatisticsSectionViewModel?) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        priceView.bindData(viewModel?.price)
        totalSupplyView.bindData(viewModel?.totalSupply)
    }
}

extension AssetStatisticsSectionView {
    private func addTitle(_ theme: AssetStatisticsSectionViewTheme) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addStatistics(_ theme: AssetStatisticsSectionViewTheme) {
        addSubview(statisticsView)
        statisticsView.distribution = .fillEqually
        statisticsView.alignment = .top
        statisticsView.spacing = theme.spacingBetweenPriceAndTotalSupply
        statisticsView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndStatistics
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        addPrice(theme)
        addTotalSupply(theme)
    }
    
    private func addPrice(_ theme: AssetStatisticsSectionViewTheme) {
        priceView.customize(theme.price)
        statisticsView.addArrangedSubview(priceView)
    }
    
    private func addTotalSupply(_ theme: AssetStatisticsSectionViewTheme) {
        totalSupplyView.customize(theme.totalSupply)
        statisticsView.addArrangedSubview(totalSupplyView)
        
        startPublishing(
            event: .showTotalSupplyInfo,
            for: totalSupplyView
        )
    }
}

extension AssetStatisticsSectionView {
    enum Event {
        case showTotalSupplyInfo
    }
}
