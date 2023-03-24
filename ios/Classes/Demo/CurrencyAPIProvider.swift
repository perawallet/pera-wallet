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

//   CurrencyAPIProvider.swift

import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo
import SwiftDate

final class CurrencyAPIProvider: CurrencyProvider {
    private(set) var primaryValue: RemoteCurrencyValue?
    private(set) var secondaryValue: RemoteCurrencyValue?

    var isExpired: Bool {
        return hasExpiredValue()
    }

    private var preferredCurrencyID: CurrencyID {
        didSet { session.preferredCurrencyID = preferredCurrencyID }
    }

    private var ongoingEndpointToRefreshCurrency: EndpointOperatable?

    @Atomic(identifier: "currencyAPIProvider.observers")
    private var observers: [UUID: EventHandler] = [:]

    private let session: Session
    private let api: ALGAPI

    init(
        session: Session,
        api: ALGAPI
    ) {
        self.preferredCurrencyID = session.preferredCurrencyID
        self.session = session
        self.api = api
    }
}

extension CurrencyAPIProvider {
    func refresh(
        on queue: DispatchQueue
    ) {
        cancelRefreshing()

        ongoingEndpointToRefreshCurrency = api.getCurrencyValue(
            preferredCurrencyID.remoteValue,
            queue: queue
        ) { [weak self] result in
            guard let self = self else { return }

            self.ongoingEndpointToRefreshCurrency = nil

            switch result {
            case .success(let currency):
                self.performUpdates(with: currency)
            case .failure(let apiError, let apiErrorDetail):
                let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                self.performUpdates(with: .networkFailed(error))
            }
        }
    }

    private func cancelRefreshing() {
        ongoingEndpointToRefreshCurrency?.cancel()
        ongoingEndpointToRefreshCurrency = nil
    }

    private func performUpdates(
        with currency: FiatCurrency
    ) {
        if currency.isFault {
            performUpdates(with: .corrupted)
            return
        }

        if !canSetAsPrimaryCurrency(currency) {
            return
        }

        if preferredCurrencyID.isAlgo {
            setAlgoAsPrimaryCurrency(currency)
        } else {
            setFiatAsPrimaryCurrency(currency)
        }

        notifyObservers(for: .didUpdate)
    }

    private func performUpdates(
        with error: CurrencyError
    ) {
        if !hasCachedValue() {
            primaryValue = .failure(error)
            secondaryValue = .failure(error)
        }

        notifyObservers(for: .didUpdate)
    }

    private func hasCachedValue() -> Bool {
        let currency = getCachedCurrency()
        return currency?.id.localValue == preferredCurrencyID.localValue
    }

    private func hasExpiredValue() -> Bool {
        guard let currency = getCachedCurrency() else {
            return true
        }

        let lastUpdateDate = currency.lastUpdateDate
        let expirationDate = calculateExpirationDate(starting: lastUpdateDate)
        return Date.now().isAfterDate(
            expirationDate,
            orEqual: true,
            granularity: .second
        )
    }

    private func getCachedCurrency() -> RemoteCurrency? {
        return try? primaryValue?.unwrap()
    }
}

extension CurrencyAPIProvider {
    func setAsPrimaryCurrency(
        _ currencyID: CurrencyID
    ) {
        if preferredCurrencyID == currencyID {
            return
        }

        preferredCurrencyID = currencyID

        primaryValue = nil
        secondaryValue = nil

        notifyObservers(for: .didUpdate)

        refresh(on: .main)
    }

    private func canSetAsPrimaryCurrency(
        _ currency: FiatCurrency
    ) -> Bool {
        return preferredCurrencyID.remoteValue == currency.id.remoteValue
    }

    private func setAlgoAsPrimaryCurrency(
        _ currency: FiatCurrency
    ) {
        let algoCurrency = AlgoRemoteCurrency(baseCurrency: currency)

        primaryValue = .available(algoCurrency)
        secondaryValue = .available(currency)
    }

    private func setFiatAsPrimaryCurrency(
        _ currency: FiatCurrency
    ) {
        let algoCurrency = AlgoRemoteCurrency(baseCurrency: currency)

        primaryValue = .available(currency)
        secondaryValue = .available(algoCurrency)
    }
}

extension CurrencyAPIProvider {
    func addObserver(
        using handler: @escaping EventHandler
    ) -> UUID {
        let observerKey = UUID()

        $observers.mutate {
            $0[observerKey] = handler
        }

        return observerKey
    }

    func removeObserver(
        _ observer: UUID
    ) {
        $observers.mutate {
            $0[observer] = nil
        }
    }

    private func notifyObservers(
        for event: CurrencyEvent
    ) {
        observers.forEach {
            $0.value(event)
        }
    }
}
