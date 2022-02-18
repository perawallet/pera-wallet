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
//   AlgorandChartViewCustomizable.swift

import Foundation
import UIKit
import Charts

protocol AlgorandChartViewCustomizable {
    var isDescriptionEnabled: Bool { get }
    var isDragEnabled: Bool { get }
    var isScaleEnabled: Bool { get }
    var isPinchZoomEnabled: Bool { get }
    var isDoubleTapToZoomEnabled: Bool { get }
    var isHighlightPerTapEnabled: Bool { get }
    var isHighlightPerDragEnabled: Bool { get }
    var isLegendEnabled: Bool { get }
    var legendForm: Legend.Form { get }
    var isRightAxisEnabled: Bool { get }
    var isDragYEnabled: Bool { get }
    var emptyText: String { get }
    var xAxisCustomizer: AlgorandChartViewAxisCustomizable { get }
    var yAxisCustomizer: AlgorandChartViewAxisCustomizable { get }
    var minimumOffset: CGFloat { get }
    var extraOffset: CGFloat { get }
}
