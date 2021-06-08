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
//   AlgoUSDAnalyticsViewModel.swift

import UIKit

class AlgoUSDAnalyticsViewModel {
    private(set) var headerViewModel: AlgoAnalyticsHeaderViewModel?
    private(set) var chartViewModel: AlgosUSDChartViewModel?
    private(set) var footerViewModel: AlgoUSDAnalyticsFooterViewModel?

    init(
        account: Account,
        values: [AlgosUSDValue],
        priceChange: AlgoUSDPriceChange,
        timeInterval: AlgosUSDValueInterval,
        currency: Currency
    ) {
        setHeaderViewModel(from: priceChange, and: timeInterval, and: currency)
        setChartViewModel(from: values, and: priceChange, and: currency)
        setFooterViewModel(from: account, and: currency)
    }

    private func setHeaderViewModel(from priceChange: AlgoUSDPriceChange, and timeInterval: AlgosUSDValueInterval, and currency: Currency) {
        headerViewModel = AlgoAnalyticsHeaderViewModel(priceChange: priceChange, timeInterval: timeInterval, currency: currency)
    }

    private func setChartViewModel(from values: [AlgosUSDValue], and priceChange: AlgoUSDPriceChange, and currency: Currency) {
        chartViewModel = AlgosUSDChartViewModel(valueChangeStatus: priceChange.getValueChangeStatus(), values: values, currency: currency)
    }

    private func setFooterViewModel(from account: Account, and currency: Currency) {
        footerViewModel = AlgoUSDAnalyticsFooterViewModel(account: account, currency: currency)
    }
}
