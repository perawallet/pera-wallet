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
//   AlgoUSDValueChart.swift

import Charts

struct AlgoUSDValueChartCustomizer: AlgorandChartViewCustomizable {
    
    var isDescriptionEnabled: Bool {
        return false
    }

    var isDragEnabled: Bool {
        return true
    }

    var isScaleEnabled: Bool {
        return false
    }

    var isPinchZoomEnabled: Bool {
        return false
    }

    var isDoubleTapToZoomEnabled: Bool {
        return false
    }

    var isHighlightPerDragEnabled: Bool {
        return false
    }

    var isHighlightPerTapEnabled: Bool {
        return false
    }

    var isLegendEnabled: Bool {
        return false
    }

    var legendForm: Legend.Form {
        return .default
    }

    var isRightAxisEnabled: Bool {
        return false
    }

    var isDragYEnabled: Bool {
        return false
    }

    var emptyText: String {
        return "chart-no-data-text".localized
    }

    var xAxisCustomizer: AlgorandChartViewAxisCustomizable {
        return AlgoUSDValueChartAxisCustomizer()
    }

    var yAxisCustomizer: AlgorandChartViewAxisCustomizable {
        return AlgoUSDValueChartAxisCustomizer()
    }

    var minimumOffset: CGFloat {
        return 20.0
    }
}

private struct AlgoUSDValueChartAxisCustomizer: AlgorandChartViewAxisCustomizable {

    var isAxisLineEnabled: Bool {
        return false
    }

    var isGridLinesEnabled: Bool {
        return false
    }

    var isAxisLabelsEnabled: Bool {
        return false
    }

    var isGranularityEnabled: Bool {
        return false
    }
}
