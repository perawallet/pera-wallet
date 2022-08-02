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
//   AlgoPriceViewModel.swift

import Foundation
import MacaroonUIKit
import MagpieCore
import MagpieHipo

struct AlgoPriceViewModel: ViewModel {
    typealias AlgoPrice = (amount: Double, currency: RemoteCurrency)
    typealias Error = AlgoStatisticsDataControllerError
    
    private(set) var price: EditText?
    private(set) var priceAttribute: AlgoPriceAttributeViewModel?
    private(set) var chart: AlgosUSDChartViewModel?
    
    init() {}
}

extension AlgoPriceViewModel {
    mutating func bind(
        algoPrice: AlgoPrice,
        currencyFormatter: CurrencyFormatter
    ) {
        bindPrice(
            algoPrice,
            currencyFormatter: currencyFormatter
        )
    }
    
    mutating func bindPrice(
        _ algoPrice: AlgoPrice,
        currencyFormatter: CurrencyFormatter
    ) {
        var constraintRules = CurrencyFormattingContextRules()
        constraintRules.minimumFractionDigits = 2
        constraintRules.maximumFractionDigits = 2

        currencyFormatter.formattingContext = .standalone(constraints: constraintRules)
        currencyFormatter.currency = nil

        let currencyID = algoPrice.currency.id
        let currencyName = currencyID.isAlgo ? currencyID.pairValue : currencyID.localValue
        let text = currencyFormatter.format(algoPrice.amount)
        let finalText = text.unwrap {
            "\($0) \(currencyName)"
        }
        
        bindPrice(finalText)
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
