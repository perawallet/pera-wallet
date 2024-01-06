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

//   SwapDataLocalStore.swift

import Foundation
import MacaroonUtils

final class SwapDataLocalStore:
    SwapDataStore,
    WeakPublisher {
    var amountPercentage: SwapAmountPercentage? {
        didSet { notifyForAmountPercentageChanges() }
    }
    var slippageTolerancePercentage: SwapSlippageTolerancePercentage? {
        didSet { notifyForSlippageTolerancePercentageChanges() }
    }

    var observations: [ObjectIdentifier : SwapDataStoreObservation] = [:]

    init() {
        self.slippageTolerancePercentage = nil
    }
}

extension SwapDataLocalStore {
    func reset() {
        invalidateObservers()

        amountPercentage = nil
        slippageTolerancePercentage = nil
    }
}

extension SwapDataLocalStore {
    private func notifyForAmountPercentageChanges() {
        notifyObservers {
            let observer = $0 as? SwapAmountPercentageStoreObserver
            observer?.swapAmountPercentageDidChange()
        }
    }

    private func notifyForSlippageTolerancePercentageChanges() {
        notifyObservers {
            let observer = $0 as? SwapSlippageTolerancePercentageStoreObserver
            observer?.swapSlippageTolerancePercentageDidChange()
        }
    }
}
