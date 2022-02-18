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
//   AlgosUSDChartViewModel.swift

import Charts
import MacaroonUIKit
import MagpieCore
import MagpieHipo

struct AlgosUSDChartViewModel:
    AlgorandChartViewModel,
    BindableViewModel {
    typealias Error = AlgoStatisticsDataControllerError
    
    private(set) var data: ChartData?
    
    init<T>(
        _ model: T
    ) {
        bind(model)
    }
}

extension AlgosUSDChartViewModel {
    mutating func bind<T>(
        _ model: T
    ) {
        if let dataSet = model as? AlgoPriceChartDataSet {
            bind(dataSet: dataSet)
            return
        }
        
        if let error = model as? Error {
            bind(error: error)
            return
        }
    }
}

extension AlgosUSDChartViewModel {
    mutating func bind(
        dataSet: AlgoPriceChartDataSet
    ) {
        bindData(dataSet)
    }
    
    mutating func bindData(
        _ dataSet: AlgoPriceChartDataSet
    ) {
        guard
            let basePriceValue = dataSet.values.last,
            let currencyValue = dataSet.currency.value
        else {
            data = nil
            return
        }
        
        var x: Double = -1
        let dataEntries: [ChartDataEntry] = dataSet.values.compactMap {
            guard let priceValue = $0.getCurrencyScaledChartHighValue(
                with: basePriceValue,
                for: currencyValue
            ) else {
                return nil
            }
            
            x += 1
            return ChartDataEntry(x: x, y: priceValue)
        }

        data = AlgorandLineChartDataComposer(
            customizer: AlgoUSDValueChartDataSetCustomizer(algoPriceChangeRate: dataSet.changeRate),
            entries: dataEntries
        ).data
    }
}

extension AlgosUSDChartViewModel {
    mutating func bind(
        error: Error
    ) {
        bindData(error)
    }
    
    mutating func bindData(
        _ error: Error
    ) {
        data = nil
    }
}

struct AlgoPriceChartDataSet {
    let values: [AlgoUSDPrice]
    let changeRate: AlgoPriceChangeRate
    let currency: CurrencyHandle
    
    init(
        values: [AlgoUSDPrice],
        changeRate: AlgoPriceChangeRate,
        currency: CurrencyHandle
    ) {
        self.values = values
            .sorted(by: \.timestamp)
            .reversed()
        self.changeRate = changeRate
        self.currency = currency
    }
}
