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
//   AlgoUSDAnalyticsView.swift

import UIKit

class AlgoUSDAnalyticsView: BaseView {

    weak var delegate: AlgoUSDAnalyticsViewDelegate?
    
    private let layout = Layout<LayoutConstants>()

    private lazy var modalIconImageView = UIImageView(image: img("modal-top-icon"))

    private lazy var titleView = AlgorandIconTitleView()

    private lazy var analyticsHeaderView = AlgoAnalyticsHeaderView()

    private lazy var lineChartView = AlgorandChartView(chartCustomizer: AlgoUSDValueChartCustomizer())

    private lazy var chartTimeFrameSelectionView = ChartTimeFrameSelectionView()

    private lazy var separatorView = LineSeparatorView()

    private lazy var footerView = AlgoUSDAnalyticsFooterView()

    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }

    override func prepareLayout() {
        setupModalIconImageViewLayout()
        setupTitleViewLayout()
        setupAnalyticsHeaderViewLayout()
        setupLineChartViewLayout()
        setupChartTimeFrameSelectionViewLayout()
        setupSeparatorViewLayout()
        setupFooterViewLayout()
    }

    override func linkInteractors() {
        chartTimeFrameSelectionView.delegate = self
        lineChartView.delegate = self
    }
}

extension AlgoUSDAnalyticsView {
    private func setupModalIconImageViewLayout() {
        addSubview(modalIconImageView)

        modalIconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }

    private func setupTitleViewLayout() {
        addSubview(titleView)

        titleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.titleTopInset)
        }
    }

    private func setupAnalyticsHeaderViewLayout() {
        addSubview(analyticsHeaderView)

        analyticsHeaderView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.lessThanOrEqualToSuperview().inset(layout.current.headerHorizontalInset)
            make.top.equalTo(titleView.snp.bottom).offset(layout.current.headerTopInset)
        }
    }

    private func setupLineChartViewLayout() {
        addSubview(lineChartView)

        lineChartView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.chartHeight)
            make.top.equalTo(analyticsHeaderView.snp.bottom).offset(layout.current.chartVerticalInset)
        }
    }

    private func setupChartTimeFrameSelectionViewLayout() {
        addSubview(chartTimeFrameSelectionView)

        chartTimeFrameSelectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.timeSelectionHorizontalInset)
            make.top.equalTo(lineChartView.snp.bottom).offset(layout.current.chartVerticalInset)
            make.height.equalTo(layout.current.timeSelectionHeight)
        }
    }

    private func setupSeparatorViewLayout() {
        addSubview(separatorView)

        separatorView.snp.makeConstraints { make in
            make.top.equalTo(chartTimeFrameSelectionView.snp.bottom).offset(layout.current.separatorVerticalInset)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
        }
    }

    private func setupFooterViewLayout() {
        addSubview(footerView)

        footerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(separatorView.snp.bottom).offset(layout.current.separatorVerticalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + layout.current.bottomInset)
        }
    }
}

extension AlgoUSDAnalyticsView: ChartTimeFrameSelectionViewDelegate {
    func chartTimeFrameSelectionView(_ view: ChartTimeFrameSelectionView, didSelect timeInterval: AlgosUSDValueInterval) {
        delegate?.algoUSDAnalyticsView(self, didSelect: timeInterval)
    }
}

extension AlgoUSDAnalyticsView: AlgorandChartViewDelegate {
    func algorandChartView(_ algorandChartView: AlgorandChartView, didSelectItemAt index: Int) {
        delegate?.algoUSDAnalyticsView(self, didSelectItemAt: index)
    }

    func algorandChartViewDidDeselect(_ algorandChartView: AlgorandChartView) {
        delegate?.algoUSDAnalyticsViewDidDeselect(self)
    }
}

extension AlgoUSDAnalyticsView {
    func bind(_ viewModel: AlgoUSDAnalyticsViewModel) {
        if let headerViewModel = viewModel.headerViewModel {
            analyticsHeaderView.bind(headerViewModel)
        }

        if let chartViewModel = viewModel.chartViewModel {
            lineChartView.bind(chartViewModel)
        }

        if let footerViewModel = viewModel.footerViewModel {
            footerView.bind(footerViewModel)
        }
    }

    func bind(_ viewModel: AlgoAnalyticsHeaderViewModel) {
        analyticsHeaderView.bind(viewModel)
    }
}

extension AlgoUSDAnalyticsView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 8.0
        let titleTopInset: CGFloat = 32.0
        let titleHorizontalInset: CGFloat = 8.0
        let headerTopInset: CGFloat = 40.0
        let headerHorizontalInset: CGFloat = 8.0
        let chartVerticalInset: CGFloat = 32.0
        let chartHeight: CGFloat = 188.0
        let timeSelectionHorizontalInset: CGFloat = 24.0
        let timeSelectionHeight: CGFloat = 28.0
        let separatorHeight: CGFloat = 1.0
        let separatorVerticalInset: CGFloat = 36.0
        let bottomInset: CGFloat = 24.0
    }
}

protocol AlgoUSDAnalyticsViewDelegate: AnyObject {
    func algoUSDAnalyticsView(_ view: AlgoUSDAnalyticsView, didSelect timeInterval: AlgosUSDValueInterval)
    func algoUSDAnalyticsView(_ view: AlgoUSDAnalyticsView, didSelectItemAt index: Int)
    func algoUSDAnalyticsViewDidDeselect(_ view: AlgoUSDAnalyticsView)
}
