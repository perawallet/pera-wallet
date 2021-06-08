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
//   AlgoUSDValueChartDataSetCustomizer.swift

import Charts

struct AlgoUSDValueChartDataSetCustomizer: AlgorandLineChartDataSetCustomizable {

    private let valueChangeStatus: ValueChangeStatus

    init(valueChangeStatus: ValueChangeStatus) {
        self.valueChangeStatus = valueChangeStatus
    }
    
    var mode: LineChartDataSet.Mode {
        return .linear
    }

    var color: UIColor {
        switch valueChangeStatus {
        case .increased:
            return Colors.Chart.Line.increasing
        case .decreased:
            return Colors.Chart.Line.decreasing
        case .stable:
            return Colors.Chart.Line.stable
        }
    }

    var lineWidth: CGFloat {
        return 2.0
    }

    var isDrawingValuesEnabled: Bool {
        return true
    }

    var isDrawingCirclesEnabled: Bool {
        return false
    }

    func valueFormatter(from entries: [ChartDataEntry]) -> IValueFormatter? {
        let sortedEntries = entries.sorted(by: \.y)
        return AlgoUSDValueFormatter(values: sortedEntries)
    }

    var highlightColor: UIColor {
        switch valueChangeStatus {
        case .increased:
            return Colors.Chart.Line.increasing
        case .decreased:
            return Colors.Chart.Line.decreasing
        case .stable:
            return Colors.Chart.Line.stable
        }
    }

    var highlightLineWidth: CGFloat {
        return 2.0
    }

    var valueColor: UIColor {
        return Colors.Text.tertiary
    }

    var font: UIFont {
        return UIFont.font(withWeight: .semiBold(size: 12.0))
    }

    var fillAlpha: CGFloat? {
        return nil
    }

    var fill: Fill? {
        return nil
    }

    var isDrawingFilledEnabled: Bool {
        return false
    }

    var gradiendColors: [CGColor]? {
        return nil
    }

    var isDrawingHorizontalHighlightIndicatorEnabled: Bool {
        return false
    }

    var isDrawingVerticalHighlightIndicatorEnabled: Bool {
        return true
    }

    var isLastElementDrawingCircle: Bool {
        return false
    }

    var circleColor: UIColor {
        return .clear
    }
}
