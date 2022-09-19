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
//   AlgorandChartView.swift

import Charts
import UIKit
import Foundation
import MacaroonUIKit

/// <todo>
/// Refactor
final class AlgorandChartView: BaseView {
    weak var delegate: AlgorandChartViewDelegate?

    private lazy var lineChartView: AlgorandLineChartView = {
        let lineChartView = AlgorandLineChartView()
        lineChartView.chartDescription.enabled = chartCustomizer.isDescriptionEnabled
        lineChartView.dragEnabled = chartCustomizer.isDragEnabled
        lineChartView.setScaleEnabled(chartCustomizer.isScaleEnabled)
        lineChartView.pinchZoomEnabled = chartCustomizer.isPinchZoomEnabled
        lineChartView.doubleTapToZoomEnabled = chartCustomizer.isDoubleTapToZoomEnabled
        lineChartView.highlightPerDragEnabled = chartCustomizer.isHighlightPerDragEnabled
        lineChartView.highlightPerTapEnabled = chartCustomizer.isHighlightPerTapEnabled
        lineChartView.legend.enabled = chartCustomizer.isLegendEnabled
        lineChartView.legend.form = chartCustomizer.legendForm
        lineChartView.rightAxis.enabled = chartCustomizer.isRightAxisEnabled
        lineChartView.dragYEnabled = chartCustomizer.isDragYEnabled
        lineChartView.xAxis.drawAxisLineEnabled = chartCustomizer.xAxisCustomizer.isAxisLineEnabled
        lineChartView.xAxis.drawGridLinesEnabled = chartCustomizer.xAxisCustomizer.isGridLinesEnabled
        lineChartView.xAxis.drawLabelsEnabled = chartCustomizer.xAxisCustomizer.isAxisLabelsEnabled
        lineChartView.xAxis.granularityEnabled = chartCustomizer.xAxisCustomizer.isGranularityEnabled
        lineChartView.leftAxis.drawAxisLineEnabled = chartCustomizer.yAxisCustomizer.isAxisLineEnabled
        lineChartView.leftAxis.drawGridLinesEnabled = chartCustomizer.yAxisCustomizer.isGridLinesEnabled
        lineChartView.leftAxis.drawLabelsEnabled = chartCustomizer.yAxisCustomizer.isAxisLabelsEnabled
        lineChartView.leftAxis.granularityEnabled = chartCustomizer.yAxisCustomizer.isGranularityEnabled
        lineChartView.minOffset = chartCustomizer.minimumOffset
        lineChartView.extraTopOffset = chartCustomizer.extraOffset
        lineChartView.extraBottomOffset = chartCustomizer.extraOffset
        return lineChartView
    }()

    private lazy var loadingView = ImageView()

    private let chartCustomizer: AlgorandChartViewCustomizable

    init(chartCustomizer: AlgorandChartViewCustomizable) {
        self.chartCustomizer = chartCustomizer
        super.init(frame: .zero)
    }

    override func configureAppearance() {
        backgroundColor = .clear
        lineChartView.noDataText = chartCustomizer.emptyText
    }

    override func prepareLayout() {
        addLineChartView()
        addLoadingView()
    }

    override func linkInteractors() {
        lineChartView.delegate = self
        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleHighlightingChart(_:)))
        tapGestureRecognizer.minimumPressDuration = 0.0
        lineChartView.addGestureRecognizer(tapGestureRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleHighlightingChart(_:)))
        lineChartView.addGestureRecognizer(panGestureRecognizer)
    }
}

extension AlgorandChartView {
    private func addLineChartView() {
        addSubview(lineChartView)
        lineChartView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addLoadingView() {
        loadingView.image = "chart-loading-bg".uiImage
        loadingView.contentMode = .scaleAspectFit

        addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension AlgorandChartView {
    @objc
    private func handleHighlightingChart(_ gesture: UIPanGestureRecognizer) {
        if gesture.isGestureCompleted {
            removeChartHighlighting()
            return
        }

        if let highlight = getHighlight(from: gesture) {
            lineChartView.highlightValue(x: highlight.x, dataSetIndex: highlight.dataSetIndex, dataIndex: highlight.dataIndex)
        }

        highlightChart()
    }

    private func removeChartHighlighting() {
        lineChartView.highlightValue(nil)
        lineChartView.marker = nil

        if let dataSet = lineChartView.data?.dataSets.last as? LineChartDataSet,
           let currentColor = dataSet.colors.first {
            dataSet.setColor(currentColor.withAlphaComponent(1.0))
            dataSet.drawValuesEnabled = true
        }

        lineChartView.lastHighlighted = nil
        delegate?.algorandChartViewDidDeselect(self)
    }

    private func highlightChart() {
        if let dataSet = lineChartView.data?.dataSets.last as? LineChartDataSet {
            // Add circle point for the highlighted value
            dataSet.drawValuesEnabled = false

            if let currentColor = dataSet.colors.first {
                addMarkerForHighlightedValue(with: currentColor)
                dataSet.setColor(currentColor.withAlphaComponent(0.5))
            }
        }
    }

    private func addMarkerForHighlightedValue(with color: UIColor) {
        let marker = ChartCircleMarker(outsideColor: Colors.Defaults.background.uiColor, insideColor: color.withAlphaComponent(1.0))
        marker.size = CGSize(width: 10, height: 10)
        lineChartView.marker = marker
    }

    private func getHighlight(from gesture: UIPanGestureRecognizer) -> Highlight? {
        let point = gesture.location(in: lineChartView)
        guard let highlight = lineChartView.getHighlightByTouchPoint(point),
              highlight.x != lineChartView.lastHighlighted?.x else {
            return nil
        }

        return highlight
    }
}

extension AlgorandChartView: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        lineChartView.lastHighlighted = highlight
        delegate?.algorandChartView(self, didSelectItemAt: Int(highlight.x))
    }
}

extension AlgorandChartView {
    func bind(_ viewModel: AlgorandChartViewModel?) {
        if let anyData = viewModel?.data {
            lineChartView.data = anyData
        } else {
            lineChartView.clear()
        }

        lineChartView.isHidden = viewModel == nil
        loadingView.isHidden = viewModel != nil
    }

    func clear() {
        lineChartView.clear()
    }
}

protocol AlgorandChartViewDelegate: AnyObject {
    func algorandChartView(_ algorandChartView: AlgorandChartView, didSelectItemAt index: Int)
    func algorandChartViewDidDeselect(_ algorandChartView: AlgorandChartView)
}
