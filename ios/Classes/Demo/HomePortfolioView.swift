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
//   HomePortfolioView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class HomePortfolioView:
    View,
    ViewModelBindable,
    UIInteractionObservable,
    UIControlInteractionPublisher,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .showInfo: UIControlInteraction()
    ]

    private lazy var titleView = Label()
    private lazy var infoActionView = MacaroonUIKit.Button()
    private lazy var valueView = Label()
    private lazy var holdingsView = UIView()
    private lazy var algoHoldingsCanvasView = UIView()
    private lazy var algoHoldingsView = HomePortfolioItemView()
    private lazy var assetHoldingsCanvasView = UIView()
    private lazy var assetHoldingsView = HomePortfolioItemView()
    
    func customize(
        _ theme: HomePortfolioViewTheme
    ) {
        addTitle(theme)
        addInfoAction(theme)
        addValue(theme)
        addHoldings(theme)
    }
    
    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}
    
    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
    
    func bindData(
        _ viewModel: HomePortfolioViewModel?
    ) {
        titleView.editText = viewModel?.title
        titleView.textColor = viewModel?.titleColor
        infoActionView.tintColor = viewModel?.titleColor
        valueView.editText = viewModel?.value
        algoHoldingsView.bindData(viewModel?.algoHoldings)
        assetHoldingsView.bindData(viewModel?.assetHoldings)
    }
    
    class func calculatePreferredSize(
        _ viewModel: HomePortfolioViewModel?,
        for theme: HomePortfolioViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }
        
        let width = size.width
        let titleSize = viewModel.title.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let valueSize = viewModel.value.boundingSize(
            multiline: false,
            fittingSize: .greatestFiniteMagnitude
        )
        let holdingsMaxWidth =
            (width - theme.minSpacingBetweenAlgoHoldingsAndAssetHoldings) / 2
        let algoHoldingsSize = HomePortfolioItemView.calculatePreferredSize(
            viewModel.algoHoldings,
            for: theme.algoHoldings,
            fittingIn: CGSize((holdingsMaxWidth, .greatestFiniteMagnitude))
        )
        let assetHoldingsSize = HomePortfolioItemView.calculatePreferredSize(
            viewModel.assetHoldings,
            for: theme.assetHoldings,
            fittingIn: CGSize((holdingsMaxWidth, .greatestFiniteMagnitude))
        )
        let preferredHeight =
            theme.titleTopPadding +
            titleSize.height +
            theme.spacingBetweenTitleAndValue +
            valueSize.height +
            theme.spacingBetweenValueAndHoldings +
            max(algoHoldingsSize.height, assetHoldingsSize.height)
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension HomePortfolioView {
    private func addTitle(
        _ theme: HomePortfolioViewTheme
    ) {
        titleView.customizeAppearance(theme.title)
        
        addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == theme.titleTopPadding
            $0.leading == 0
        }
    }
    
    private func addInfoAction(
        _ theme: HomePortfolioViewTheme
    ) {
        infoActionView.customizeAppearance(theme.infoAction)
        
        addSubview(infoActionView)
        infoActionView.snp.makeConstraints{
            $0.centerY == titleView
            $0.leading == titleView.snp.trailing + theme.spacingBetweenTitleAndInfoAction
        }

        startPublishing(
            event: .showInfo,
            for: infoActionView
        )
    }
    
    private func addValue(
        _ theme: HomePortfolioViewTheme
    ) {
        valueView.customizeAppearance(theme.value)
        
        addSubview(valueView)
        valueView.fitToIntrinsicSize()
        valueView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndValue
            $0.leading == 0
            $0.trailing == 0
        }
    }
    
    private func addHoldings(
        _ theme: HomePortfolioViewTheme
    ) {
        addSubview(holdingsView)
        holdingsView.snp.makeConstraints {
            $0.top == valueView.snp.bottom + theme.spacingBetweenValueAndHoldings
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
        
        addAlgoHoldings(theme)
        addAssetHoldings(theme)
    }
    
    private func addAlgoHoldings(
        _ theme: HomePortfolioViewTheme
    ) {
        holdingsView.addSubview(algoHoldingsCanvasView)
        algoHoldingsCanvasView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
        
        algoHoldingsView.customize(theme.algoHoldings)
        
        algoHoldingsCanvasView.addSubview(algoHoldingsView)
        algoHoldingsView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing <= 0
            $0.bottom == 0
        }
    }
    
    private func addAssetHoldings(
        _ theme: HomePortfolioViewTheme
    ) {
        holdingsView.addSubview(assetHoldingsCanvasView)
        assetHoldingsCanvasView.snp.makeConstraints {
            $0.width == algoHoldingsCanvasView
            $0.top == 0
            $0.leading ==
                algoHoldingsCanvasView.snp.trailing +
                theme.minSpacingBetweenAlgoHoldingsAndAssetHoldings
            $0.bottom == 0
            $0.trailing == 0
        }
        
        assetHoldingsView.customize(theme.assetHoldings)
        
        assetHoldingsCanvasView.addSubview(assetHoldingsView)
        assetHoldingsView.snp.makeConstraints {
            $0.width <= 0
            $0.centerX == 0
            $0.top == 0
            $0.bottom == 0
        }
    }
}

extension HomePortfolioView {
    enum Event {
        case showInfo
    }
}
