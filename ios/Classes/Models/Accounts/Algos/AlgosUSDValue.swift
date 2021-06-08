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
//   AlgosUSDValue.swift

import Magpie

class AlgosUSDValue: Model {
    let timestamp: Double?
    let open: Double?
    let low: Double?
    let high: Double?
    let close: Double?
    let volume: Double?
}

extension AlgosUSDValue {
    func getCurrencyScaledChartHighValue(with current: AlgosUSDValue, for currency: Currency) -> Double? {
        return getCurrencyScaledChartValue(current.high, with: current, for: currency)
    }

    func getCurrencyScaledChartOpenValue(with current: AlgosUSDValue, for currency: Currency) -> Double? {
        return getCurrencyScaledChartValue(current.open, with: current, for: currency)
    }

    // Scales conversion of current algo-preferredCurrency value with the current algo price to display
    private func getCurrencyScaledChartValue(_ value: Double?, with current: AlgosUSDValue, for currency: Currency) -> Double? {
        guard let chartDisplayValue = getChartDisplayValue(with: currency),
              let currentPrice = current.open else {
            return nil
        }

        return (1 / currentPrice) * chartDisplayValue
    }

    // Convert current value of algo to preferred currency value
    private func getChartDisplayValue(with currency: Currency? = nil) -> Double? {
        guard let currency = currency,
              let currencyPrice = currency.price,
              let currencyPriceDoubleValue = Double(currencyPrice),
              let highValue = high else {
            return high?.round(to: 2)
        }

        return (currencyPriceDoubleValue * highValue).round(to: 2)
    }
}
