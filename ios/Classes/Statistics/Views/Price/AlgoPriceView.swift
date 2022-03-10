// Copyright 2019 Algorand, Inc.

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
//   AlgoPriceView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AlgoPriceView:
    View,
    ViewModelBindable,
    AlgorandChartViewDelegate {
    typealias EventHandler = (Event) -> Void
    
    var eventHandler: EventHandler?
    
    private lazy var priceCanvasView = UIView()
    private lazy var priceView = Label()
    private lazy var priceLoadingView = ShimmerView()
    private lazy var priceAttributeView = AlgoPriceAttributeView()
    private lazy var chartView = AlgorandChartView(chartCustomizer: AlgoUSDValueChartCustomizer())
    
    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        setListeners()
    }
    
    func customize(
        _ theme: AlgoPriceViewTheme
    ) {
        addPriceCanvas(theme)
        addPriceAttribute(theme)
        addChart(theme)
    }
    
    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
    
    func setListeners() {
        chartView.delegate = self
    }
    
    func bindData(
        _ viewModel: AlgoPriceViewModel?
    ) {
        bindPriceData(viewModel)
        chartView.bind(viewModel?.chart)
    }
    
    func bindPriceData(
        _ viewModel: AlgoPriceViewModel?
    ) {
        let price = viewModel?.price
        priceView.editText = price
        priceLoadingView.isHidden = price != nil

        priceAttributeView.bindData(viewModel?.priceAttribute)
    }
}

extension AlgoPriceView {
    private func addPriceCanvas(
        _ theme: AlgoPriceViewTheme
    ) {
        addSubview(priceCanvasView)
        priceCanvasView.snp.makeConstraints {
            $0.top == 0
            $0.leading == theme.contentHorizontalPaddings.leading
            $0.trailing <= theme.contentHorizontalPaddings.trailing
        }
        
        addPrice(theme)
        addPriceLoading(theme)
    }
    
    private func addPrice(
        _ theme: AlgoPriceViewTheme
    ) {
        priceView.customizeAppearance(theme.price)
        
        priceCanvasView.addSubview(priceView)
        priceView.fitToIntrinsicSize()
        priceView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
    
    private func addPriceLoading(
        _ theme: AlgoPriceViewTheme
    ) {
        priceLoadingView.draw(corner: theme.priceLoadingCorner)
        
        priceCanvasView.addSubview(priceLoadingView)
        priceLoadingView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
            
            $0.greaterThanSize(theme.priceLoadingMinSize)
        }
    }
    
    private func addPriceAttribute(
        _ theme: AlgoPriceViewTheme
    ) {
        priceAttributeView.customize(theme.priceAttribute)
        
        addSubview(priceAttributeView)
        priceAttributeView.snp.makeConstraints {
            $0.top == priceCanvasView.snp.bottom + theme.spacingBetweenPriceAndPriceAttribute
            $0.leading == theme.contentHorizontalPaddings.leading
            $0.trailing <= theme.contentHorizontalPaddings.trailing
            
            $0.greaterThanSize(theme.priceAttributeMinSize)
        }
    }
    
    private func addChart(
        _ theme: AlgoPriceViewTheme
    ) {
        addSubview(chartView)
        chartView.snp.makeConstraints {
            $0.top == priceAttributeView.snp.bottom + theme.spacingBetweenPriceAttributeAndChart
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
            
            $0.fitToHeight(theme.chartHeight)
        }
    }
}

extension AlgoPriceView {
    func algorandChartView(
        _ algorandChartView: AlgorandChartView,
        didSelectItemAt index: Int
    ) {
        eventHandler?(.selectChartAtPrice(index: index))
    }
    
    func algorandChartViewDidDeselect(
        _ algorandChartView: AlgorandChartView
    ) {
        eventHandler?(.deselectChart)
    }
}

extension AlgoPriceView {
    enum Event {
        case selectChartAtPrice(index: Int)
        case deselectChart
    }
}
