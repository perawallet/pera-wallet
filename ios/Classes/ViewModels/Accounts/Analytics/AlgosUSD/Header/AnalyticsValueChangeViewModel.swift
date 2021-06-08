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
//   AnalyticsValueChangeViewModel.swift

import UIKit

class AnalyticsValueChangeViewModel {
    private(set) var image: UIImage?
    private(set) var valueColor: UIColor?
    private(set) var value: String?

    init(priceChange: AlgoUSDPriceChange) {
        setImage(from: priceChange)
        setValueColor(from: priceChange)
        setValue(from: priceChange)
    }

    private func setImage(from priceChange: AlgoUSDPriceChange) {
        switch priceChange.getValueChangeStatus() {
        case .increased:
            image = img("icon-arrow-up-green")
        case .decreased:
            image = img("icon-arrow-down-red")
        case .stable:
            image = nil
        }
    }

    private func setValueColor(from priceChange: AlgoUSDPriceChange) {
        switch priceChange.getValueChangeStatus() {
        case .increased:
            valueColor = Colors.Main.primary700
        case .decreased:
            valueColor = Colors.Main.red600
        case .stable:
            valueColor = nil
        }
    }

    private func setValue(from priceChange: AlgoUSDPriceChange) {
        switch priceChange.getValueChangeStatus() {
        case .increased:
            value = (priceChange.getValueChangePercentage() - 1).toPercentage
        case .decreased:
            value = (1 - priceChange.getValueChangePercentage()).toPercentage
        case .stable:
            value = nil
        }
    }
}
