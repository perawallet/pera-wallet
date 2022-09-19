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
//   AlgorandLineChartDataSetCustomizable.swift

import Foundation
import UIKit
import Charts

protocol AlgorandLineChartDataSetCustomizable {
    var mode: LineChartDataSet.Mode { get }
    var color: UIColor { get }
    var lineWidth: CGFloat { get }
    var isDrawingValuesEnabled: Bool { get }
    var isDrawingCirclesEnabled: Bool { get }
    var highlightColor: UIColor { get }
    var highlightLineWidth: CGFloat { get }
    func valueFormatter(from entries: [ChartDataEntry]) -> ValueFormatter
    var valueColor: UIColor { get }
    var font: UIFont { get }
    var fillAlpha: CGFloat? { get }
    var fill: Fill? { get }
    var gradiendColors: [CGColor]? { get }
    var isDrawingFilledEnabled: Bool { get }
    var isDrawingHorizontalHighlightIndicatorEnabled: Bool { get }
    var isDrawingVerticalHighlightIndicatorEnabled: Bool { get }
    var isLastElementDrawingCircle: Bool { get }
    var circleColor: UIColor { get }
}
