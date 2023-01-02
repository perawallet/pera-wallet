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
//   CurrencyRefreshOperation.swift

import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class CurrencyRefreshOperation: MacaroonUtils.AsyncOperation {
    private var observerKey: UUID?

    private let cachedCurrency: CurrencyProvider
    private let api: ALGAPI
    private let completionQueue = DispatchQueue(
        label: "pera.queue.operation.currencyFetch",
        qos: .userInitiated
    )
    
    init(
        cachedCurrency: CurrencyProvider,
        api: ALGAPI
    ) {
        self.cachedCurrency = cachedCurrency
        self.api = api
    }

    deinit {
        stopObservingCurrencyEvents()
    }

    
    override func main() {
        if finishIfCancelled() {
            return
        }

        startObservingCurrencyEvents()
        refreshCurrency()
    }
    
    override func cancel() {
        super.cancel()

        stopObservingCurrencyEvents()
        finish()
    }
}

extension CurrencyRefreshOperation {
    private func startObservingCurrencyEvents() {
        observerKey = cachedCurrency.addObserver {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate:
                self.stopObservingCurrencyEvents()
                self.finish()
            }
        }
    }

    private func refreshCurrency() {
        cachedCurrency.refresh(on: completionQueue)
    }

    private func stopObservingCurrencyEvents() {
        if let observerKey = observerKey {
            cachedCurrency.removeObserver(observerKey)
        }
    }
}
