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

//   CurrencySelectionAPIDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore

final class CurrencySelectionListAPIDataController: CurrencySelectionDataController {
    var eventHandler: ((CurrencySelectionDataControllerEvent) -> Void)?

    private(set) var selectedCurrencyID: CurrencyID?

    var isEmpty: Bool {
        return currencies.isEmpty
    }

    private lazy var searchThrottler = Throttler(intervalInSeconds: 0.3)
    
    private var currencies = [RemoteCurrency]()
    private var searchResults = [RemoteCurrency]()

    private var lastSnapshot: Snapshot?

    private var currencyObserverKey: UUID?

    private let sharedDataController: SharedDataController
    private let api: ALGAPI

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.selectCurrency.updates",
        qos: .userInitiated)
    
    init(
        sharedDataController: SharedDataController,
        api: ALGAPI
    ) {
        self.sharedDataController = sharedDataController
        self.api = api

        setInitialSelectedCurrency()
    }

    deinit {
        stopObservingSelectedCurrencyEvents()
    }
    
    subscript (indexPath: IndexPath) -> RemoteCurrency? {
        return searchResults[safe: indexPath.item]
    }
}

extension CurrencySelectionListAPIDataController {
    func loadData() {
        deliverLoadingUpdates()

        currencies.removeAll()
        searchResults.removeAll()

        api.getCurrencies { response in
            switch response {
            case let .success(currencyList):
                var currencies: [RemoteCurrency] = []

                let fiatCurrencies = currencyList.items

                if let usdCurrency = fiatCurrencies.first(where: \.isUSD) {
                    let algoCurrency = AlgoRemoteCurrency(baseCurrency: usdCurrency)
                    currencies.append(algoCurrency)
                }

                currencies.append(contentsOf: fiatCurrencies)

                self.currencies = currencies
                self.searchResults = currencies

                self.deliverContentUpdates()

                if self.selectedCurrencyID == nil {
                    self.startObservingSelectedCurrencyEvents()
                }
            case .failure:
                self.deliverErrorContentUpdates()
            }
        }
    }

    func reloadData() {
        deliverContentUpdates()
    }
}

extension CurrencySelectionListAPIDataController {
    func search(for query: String) {
        searchThrottler.performNext {
            [weak self] in

            guard let self = self else {
                return
            }

            self.searchResults = self.currencies.filter { currency in
                self.isCurrencyContainsID(currency, query: query) ||
                self.isCurrencyContainsName(currency, query: query)
            }

            self.deliverContentUpdates()
        }
    }

    private func isCurrencyContainsID(_ currency: RemoteCurrency, query: String) -> Bool {
        let currencyLocalValue = currency.id.localValue
        return currencyLocalValue.localizedCaseInsensitiveContains(query)
    }

    private func isCurrencyContainsName(_ currency: RemoteCurrency, query: String) -> Bool {
        return currency.name.someString.localizedCaseInsensitiveContains(query)
    }

    func resetSearch() {
        searchThrottler.cancelAll()
        
        searchResults.removeAll()
        searchResults = currencies

        deliverContentUpdates()
    }
}

extension CurrencySelectionListAPIDataController {
    func selectCurrency(
        at indexPath: IndexPath
    ) -> RemoteCurrency? {
        guard let currency = self[indexPath] else {
            return nil
        }

        setSelectedCurrency(currency)
        reloadData()

        return currency
    }

    @discardableResult
    private func setInitialSelectedCurrency() -> Bool {
        let currencyValue = sharedDataController.currency.primaryValue

        guard let rawCurrency = try? currencyValue?.unwrap() else {
            return false
        }

        setSelectedCurrency(rawCurrency)
        return true
    }

    private func setSelectedCurrency(
        _ rawCurrency: RemoteCurrency
    ) {
        selectedCurrencyID = rawCurrency.id
    }
}

extension CurrencySelectionListAPIDataController {
    private func startObservingSelectedCurrencyEvents() {
        currencyObserverKey = sharedDataController.currency.addObserver {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate:
                let isSuccess = self.setInitialSelectedCurrency()

                if isSuccess {
                    self.stopObservingSelectedCurrencyEvents()
                    self.reloadData()
                }
            }
        }
    }

    private func stopObservingSelectedCurrencyEvents() {
        if let currencyObserverKey = currencyObserverKey {
            sharedDataController.currency.removeObserver(currencyObserverKey)
        }
    }
}

extension CurrencySelectionListAPIDataController {
    private func deliverContentUpdates() {
        guard !self.currencies.isEmpty else {
            deliverErrorContentUpdates()
            return
        }
        
        guard !self.searchResults.isEmpty else {
            deliverNoContentUpdates()
            return
        }
        
        deliverUpdates {
            [weak self] in
            guard let self = self else { return nil }
            
            var snapshot = Snapshot()
            
            var currencyItems: [CurrencySelectionItem] = []

            self.searchResults.forEach { currency in
                let title = currency.id.localValue
                let isSelected = currency.id == self.selectedCurrencyID
                let viewModel = SingleSelectionViewModel(
                    title: title,
                    isSelected: isSelected
                )
                
                currencyItems.append(.currency(viewModel))
            }
                        
            snapshot.appendSections([.currencies])
            snapshot.appendItems(
                currencyItems,
                toSection: .currencies
            )
            
            snapshot.reloadItems(currencyItems)
            return (snapshot, false)
        }
    }

    private func deliverLoadingUpdates() {
        deliverUpdates {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty(.loading)],
                toSection: .empty
            )
            return (snapshot, true)
        }
    }
    
    private func deliverNoContentUpdates() {
        deliverUpdates {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty(
                    .noContent(CurrencySelectionNoContentViewModel())
                )],
                toSection: .empty
            )
            return (snapshot, false)
        }
    }
    
    private func deliverErrorContentUpdates() {
        deliverUpdates {
            var snapshot = Snapshot()
            snapshot.appendSections([.error])
            snapshot.appendItems(
                [.error],
                toSection: .error
            )
            return (snapshot, false)
        }
    }
    
    private func deliverUpdates(
        _ updates: @escaping () -> Updates?
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else { return }

            guard let updates = updates() else {
                return
            }
            
            self.lastSnapshot = updates.snapshot
            self.publish(.didUpdate(updates))
        }
    }
}

extension CurrencySelectionListAPIDataController {
    private func publish(
        _ event: CurrencySelectionDataControllerEvent
    ) {
        asyncMain {
            [weak self] in
            
            guard let self = self else {
                return
            }
            
            self.eventHandler?(event)
        }
    }
}
