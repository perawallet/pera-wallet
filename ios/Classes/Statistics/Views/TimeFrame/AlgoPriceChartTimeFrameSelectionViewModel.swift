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
//   AlgoPriceChartTimeFrameSelectionViewModel.swift

import Foundation
import MacaroonUIKit
import MagpieCore
import MagpieHipo

struct AlgoPriceChartTimeFrameSelectionViewModel: BindableViewModel {
    typealias Error = AlgoStatisticsDataControllerError
    
    private(set) var options: [AlgoPriceChartTimeFrameSelection] = []
    
    init<T>(
        _ model: T
    ) {
        bind(model)
    }
}

extension AlgoPriceChartTimeFrameSelectionViewModel {
    mutating func bind<T>(
        _ model: T
    ) {
        if let options = model as? [AlgoPriceChartTimeFrameSelection] {
            bind(options: options)
            return
        }
        
        if let error = model as? Error {
            bind(error: error)
            return
        }
    }
}

extension AlgoPriceChartTimeFrameSelectionViewModel {
    mutating func bind(
        options: [AlgoPriceChartTimeFrameSelection]
    ) {
        bindOptions(options)
    }
    
    mutating func bindOptions(
        _ anyOptions: [AlgoPriceChartTimeFrameSelection]
    ) {
        options = anyOptions
    }
}

extension AlgoPriceChartTimeFrameSelectionViewModel {
    mutating func bind(
        error: Error
    ) {
        bindOptions(error)
    }
    
    mutating func bindOptions(
        _ error: Error
    ) {
        options = []
    }
}

protocol AlgoPriceChartTimeFrameSelection {
    var title: String { get }
}
