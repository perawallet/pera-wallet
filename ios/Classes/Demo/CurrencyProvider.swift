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

//   CurrencyProvider.swift

import Foundation
import SwiftDate

protocol CurrencyProvider: AnyObject {
    typealias EventHandler = (CurrencyEvent) -> Void

    var primaryValue: RemoteCurrencyValue? { get }
    var secondaryValue: RemoteCurrencyValue? { get }

    var isExpired: Bool { get }

    func refresh(
        on queue: DispatchQueue
    )

    func setAsPrimaryCurrency(
        _ currencyID: CurrencyID
    )

    func addObserver(
        using handler: @escaping EventHandler
    ) -> UUID
    func removeObserver(
        _ observer: UUID
    )
}

extension CurrencyProvider {
    var algoValue: RemoteCurrencyValue? {
        get {
            if let primaryRawCurrency = try? primaryValue?.unwrap(),
               primaryRawCurrency.isAlgo {
                return primaryValue
            }

            if let secondaryRawCurrency = try? secondaryValue?.unwrap(),
               secondaryRawCurrency.isAlgo {
                return secondaryValue
            }

            /// <note>
            /// If both conditions aren't met, it means the currency failed to be fetched from API;
            /// therefore, in order to handle the error case, the primary value is being returned.
            return primaryValue
        }
    }

    var fiatValue: RemoteCurrencyValue? {
        get {
            if let primaryRawCurrency = try? primaryValue?.unwrap(),
               !primaryRawCurrency.isAlgo {
                return primaryValue
            }

            if let secondaryRawCurrency = try? secondaryValue?.unwrap(),
               !secondaryRawCurrency.isAlgo {
                return secondaryValue
            }

            /// <note>
            /// If both conditions aren't met, it means the currency failed to be fetched from API;
            /// therefore, in order to handle the error case, the primary value is being returned.
            return primaryValue
        }
    }
}

extension CurrencyProvider {
    func calculateExpirationDate(
        starting startDate: Date
    ) -> Date {
        return startDate + 1.minutes
    }
}

enum CurrencyEvent {
    /// It may be called in a background queue
    case didUpdate
}
