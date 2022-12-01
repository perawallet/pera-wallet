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

//   SlippageToleranceStore.swift

import Foundation

final class SlippageToleranceStore: Storable {
    typealias Object = Any

    static let slippagePresetPointOnePercent: Decimal = 0.1
    static let defaultSlippage: Decimal = 0.5
    static let slippagePresetOnePercent: Decimal = 1

    private let slippageToleranceKey = "cache.key.swap.slippageTolerance"

    private var slippageToleranceValue: String? {
        get { userDefaults.string (forKey: slippageToleranceKey) }
        set { userDefaults.set(newValue, forKey: slippageToleranceKey) }
    }

    var slippageTolerance: SwapSlippageTolerancePercentage {
        get {
            guard let slippageToleranceValue else {
                return PresetSwapSlippageTolerancePercentage(value: SlippageToleranceStore.defaultSlippage)
            }

            let decimalValue = Decimal(string: slippageToleranceValue) ?? SlippageToleranceStore.defaultSlippage
            return getSwapSlippageTolerancePercentage(for: decimalValue * 100)
        }
        set {
            slippageToleranceValue = NSDecimalNumber(decimal: newValue.value).stringValue
        }
    }
}

extension SlippageToleranceStore {
    private func getSwapSlippageTolerancePercentage(
        for value: Decimal
    ) -> SwapSlippageTolerancePercentage {
        switch value {
        case SlippageToleranceStore.slippagePresetPointOnePercent: return PresetSwapSlippageTolerancePercentage(value: value)
        case SlippageToleranceStore.defaultSlippage: return PresetSwapSlippageTolerancePercentage(value: value)
        case SlippageToleranceStore.slippagePresetOnePercent: return PresetSwapSlippageTolerancePercentage(value: value)
        default: return CustomSwapSlippageTolerancePercentage(value: value)
        }
    }
}
