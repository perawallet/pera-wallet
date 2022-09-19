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
//   AlgoUSDValueFormatter.swift

import Foundation
import UIKit
import Charts

class AlgoUSDValueFormatter: ValueFormatter {
    private let values: [ChartDataEntry]
    private var minimumIndex: Double?
    private var maximumIndex: Double?

    init(values: [ChartDataEntry]) {
        self.values = values
    }

    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        guard let maximumPrice = values.first?.y,
              let minimumPrice = values.last?.y else {
            return ""
        }

        if value == maximumPrice && (maximumIndex == entry.x || maximumIndex == nil) {
            maximumIndex = entry.x
            return getPriceRepresentation(for: maximumPrice)
        }

        if value == minimumPrice && (minimumIndex == entry.x || minimumIndex == nil) {
            minimumIndex = entry.x
            return "\n\n\(getPriceRepresentation(for: minimumPrice))"
        }

        return ""
    }

    private func getPriceRepresentation(for value: Double) -> String {
        return ""
    }
}
