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
//   AlgoUSDPrice.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AlgoUSDPrice: ALGAPIModel {
    let timestamp: Double?
    let open: Double?
    let low: Double?
    let high: Double?
    let close: Double?
    let volume: Double?

    init() {
        self.timestamp = nil
        self.open = nil
        self.low = nil
        self.high = nil
        self.close = nil
        self.volume = nil
    }
}

extension AlgoUSDPrice {
    func getCurrencyScaledChartHighValue(with current: AlgoUSDPrice, for currency: RemoteCurrency) -> Double? {
        return getCurrencyScaledChartValue(current.high, with: current, for: currency)
    }

    func getCurrencyScaledChartOpenValue(with current: AlgoUSDPrice, for currency: RemoteCurrency) -> Double? {
        return getCurrencyScaledChartValue(current.open, with: current, for: currency)
    }

    // Scales conversion of current algo-preferredCurrency value with the current algo price to display
    private func getCurrencyScaledChartValue(_ value: Double?, with current: AlgoUSDPrice, for currency: RemoteCurrency) -> Double? {
        guard let chartDisplayValue = getChartDisplayValue(with: currency),
              let currentPrice = current.open else {
            return nil
        }

        return (1 / currentPrice) * chartDisplayValue
    }

    // Convert current value of algo to preferred currency value
    private func getChartDisplayValue(with currency: RemoteCurrency? = nil) -> Double? {
        guard let currency = currency,
              let algoValue = currency.algoValue,
              let highValue = high else {
            return high?.round(to: 2)
        }

        return (algoValue.doubleValue * highValue).round(to: 2)
    }
}
