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
//   AlgoPriceViewModel.swift

import Foundation
import MacaroonUIKit
import MagpieCore
import MagpieHipo

struct AlgoPriceViewModel: BindableViewModel {
    typealias AlgoPrice = (amount: Double, currency: Currency)
    typealias Error = AlgoStatisticsDataControllerError
    
    private(set) var price: EditText?
    private(set) var priceAttribute: AlgoPriceAttributeViewModel?
    private(set) var chart: AlgosUSDChartViewModel?
    
    init() {}
    
    init<T>(
        _ model: T
    ) {
        bind(model)
    }
}

extension AlgoPriceViewModel {
    mutating func bind<T>(
        _ model: T
    ) {
        if let algoPrice = model as? AlgoPrice {
            bind(algoPrice: algoPrice)
            return
        }
        
        if let algoPriceChangeRate = model as? AlgoPriceChangeRate {
            bind(algoPriceChangeRate: algoPriceChangeRate)
            return
        }
        
        if let algoPriceTimestamp = model as? Double {
            bind(algoPriceTimestamp: algoPriceTimestamp)
            return
        }
        
        if let algoPriceChartDataSet = model as? AlgoPriceChartDataSet {
            bind(algoPriceChartDataSet: algoPriceChartDataSet)
            return
        }
        
        if let error = model as? Error {
            bind(error: error)
            return
        }
    }
}

extension AlgoPriceViewModel {
    mutating func bind(
        algoPrice: AlgoPrice
    ) {
        bindPrice(algoPrice)
    }
    
    mutating func bindPrice(
        _ algoPrice: AlgoPrice
    ) {
        let currencyId: String
        
        if let algoCurrency = algoPrice.currency as? AlgoCurrency {
            /// In order to get USD currency id, we should cast to AlgoCurrency and get the ID from currency parameter
            /// AlgoCurrency has currency parameter that includes USD currency to handle Algo Conversion easiliy
            /// When API supports Algo Currency, these checks should be deleted
            currencyId = algoCurrency.currency.id
        } else {
            currencyId = algoPrice.currency.id
        }
        
        let price = algoPrice.amount.toCurrencyStringForLabel.unwrap {
            "\($0) \(currencyId)"
        } ?? "N/A"
        
        bindPrice(price)
    }
}

extension AlgoPriceViewModel {
    mutating func bind(
        algoPriceChangeRate: AlgoPriceChangeRate
    ) {
        bindPriceAttribute(algoPriceChangeRate)
    }
    
    mutating func bindPriceAttribute(
        _ algoPriceChangeRate: AlgoPriceChangeRate
    ) {
        priceAttribute = AlgoPriceAttributeViewModel(algoPriceChangeRate)
    }
}

extension AlgoPriceViewModel {
    mutating func bind(
        algoPriceTimestamp: Double
    ) {
        bindPriceAttribute(algoPriceTimestamp)
    }
    
    mutating func bindPriceAttribute(
        _ algoPriceTimestamp: Double
    ) {
        priceAttribute = AlgoPriceAttributeViewModel(algoPriceTimestamp)
    }
}

extension AlgoPriceViewModel {
    mutating func bind(
        algoPriceChartDataSet: AlgoPriceChartDataSet
    ) {
        bindChart(algoPriceChartDataSet)
    }
    
    mutating func bindChart(
        _ algoPriceChartDataSet: AlgoPriceChartDataSet
    ) {
        chart = AlgosUSDChartViewModel(algoPriceChartDataSet)
    }
}

extension AlgoPriceViewModel {
    mutating func bind(
        error: Error
    ) {
        bindPrice(error)
        bindPriceAttribute(error)
        bindChart(error)
    }
    
    mutating func bindPrice(
        _ error: Error
    ) {
        bindPrice("N/A")
    }
    
    mutating func bindPriceAttribute(
        _ error: Error
    ) {
        priceAttribute = AlgoPriceAttributeViewModel(error)
    }
    
    mutating func bindChart(
        _ error: Error
    ) {
        chart = AlgosUSDChartViewModel(error)
    }
}

extension AlgoPriceViewModel {
    mutating func bindPrice(
        _ aString: String?
    ) {
        guard let aString = aString else {
            price = nil
            return
        }
        
        price = .attributedString(
            aString.attributed([
                .font(Fonts.DMMono.regular.make(36)),
                .letterSpacing(-0.72)
            ])
        )
    }
}
