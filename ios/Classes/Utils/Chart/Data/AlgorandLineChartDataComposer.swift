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
//   AlgorandLineChartDataComposer.swift

import Foundation
import Charts

struct AlgorandLineChartDataComposer {

    private(set) var data: ChartData?

    init(customizer: AlgoUSDValueChartDataSetCustomizer, entries: [ChartDataEntry]) {
        data = composeLineChartDataSet(with: customizer, entries: entries)
    }

    private func composeLineChartDataSet(with customizer: AlgoUSDValueChartDataSetCustomizer, entries: [ChartDataEntry]) -> ChartData {
        let dataSet = LineChartDataSet(entries: entries)
        dataSet.mode = customizer.mode
        dataSet.setColor(customizer.color)
        dataSet.lineWidth = customizer.lineWidth
        dataSet.drawCirclesEnabled = customizer.isDrawingCirclesEnabled
        dataSet.drawValuesEnabled = customizer.isDrawingValuesEnabled
        dataSet.valueFormatter = customizer.valueFormatter(from: entries)
        dataSet.highlightColor = customizer.highlightColor
        dataSet.highlightLineWidth = customizer.highlightLineWidth
        dataSet.valueTextColor = customizer.valueColor
        dataSet.valueFont = customizer.font

        if let fill = customizer.fill,
           let fillAlpha = customizer.fillAlpha,
           customizer.isDrawingFilledEnabled {
            dataSet.fillAlpha = fillAlpha
            dataSet.fill = fill
            dataSet.drawFilledEnabled = true
        }

        dataSet.drawHorizontalHighlightIndicatorEnabled = customizer.isDrawingHorizontalHighlightIndicatorEnabled
        dataSet.drawVerticalHighlightIndicatorEnabled = customizer.isDrawingVerticalHighlightIndicatorEnabled

        let data = LineChartData(dataSet: dataSet)

        // Add another data point for circle if it should be seen at the end of the chart.
        if customizer.isLastElementDrawingCircle {
            if let lastElement = entries.last {
                let dataSet = LineChartDataSet(entries: [lastElement])
                dataSet.drawCirclesEnabled = customizer.isDrawingCirclesEnabled
                dataSet.drawValuesEnabled = false
                dataSet.circleColors = [customizer.circleColor]
                dataSet.drawHorizontalHighlightIndicatorEnabled = customizer.isDrawingHorizontalHighlightIndicatorEnabled
                dataSet.drawVerticalHighlightIndicatorEnabled = customizer.isDrawingVerticalHighlightIndicatorEnabled
                data.append(dataSet)
            }
        }

        return data
    }
}
