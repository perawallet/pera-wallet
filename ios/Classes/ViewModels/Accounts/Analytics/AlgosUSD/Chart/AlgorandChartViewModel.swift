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
//   AlgosUSDChartViewModel.swift

import Charts

class AlgosUSDChartViewModel: AlgorandChartViewModelConvertible {
    private var data: ChartData?
    private let valueChangeStatus: ValueChangeStatus
    private var historicalPrices: [AlgosUSDValue] = []

    init(valueChangeStatus: ValueChangeStatus, values: [AlgosUSDValue], currency: Currency) {
        self.valueChangeStatus = valueChangeStatus
        setChartData(from: values, and: currency)
    }

    func chartData() -> ChartData? {
        data
    }
}

extension AlgosUSDChartViewModel {
    private func setChartData(from values: [AlgosUSDValue], and currency: Currency) {
        historicalPrices = values.sorted(by: \.timestamp).reversed()

        if historicalPrices.isEmpty {
            return
        }

        var entries: [ChartDataEntry] = []
        var index = 0

        for historicalPrice in historicalPrices {
            if let lastPrice = historicalPrices.last,
               let algosPrice = historicalPrice.getCurrencyScaledChartHighValue(with: lastPrice, for: currency) {
                entries.append(ChartDataEntry(x: Double(index), y: algosPrice))
                index = index.advanced(by: 1)
            }
        }

        if entries.isEmpty {
            return
        }

        data = AlgorandLineChartDataComposer(
            customizer: AlgoUSDValueChartDataSetCustomizer(valueChangeStatus: valueChangeStatus),
            entries: entries
        ).data
    }
}
