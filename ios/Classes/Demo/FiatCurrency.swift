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

//   FiatCurrency.swift

import Foundation
import MacaroonUtils
import MagpieCore
import SwiftDate

final class FiatCurrency:
    ALGEntityModel,
    RemoteCurrency {
    var isUSD: Bool {
        return id.isUSD
    }
    var isFault: Bool {
        return
            algoValue == nil ||
            usdValue == nil
    }

    let id: CurrencyID
    let name: String?
    let symbol: String?
    let algoValue: Decimal?
    let usdValue: Decimal?
    let lastUpdateDate: Date

    init(
        _ apiModel: APIModel
    ) {
        self.id = CurrencyID.fiat(localValue: apiModel.currencyId)
        self.name = apiModel.name
        self.symbol = apiModel.symbol
        self.algoValue = apiModel.exchangePrice.unwrap {
            Decimal(string: $0)
        }
        self.usdValue = apiModel.usdValue
        self.lastUpdateDate = apiModel.lastUpdatedAt.unwrap {
            $0.toDate(.fullNumericWithoutTimezone)
        } ?? Date.now()
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.currencyId = id.localValue
        apiModel.name = name
        apiModel.symbol = symbol
        apiModel.exchangePrice = algoValue?.number.stringValue
        apiModel.usdValue = usdValue
        apiModel.lastUpdatedAt = lastUpdateDate.toFormat(.fullNumericWithoutTimezone)
        return apiModel
    }
}

extension FiatCurrency {
    struct APIModel: ALGAPIModel {
        var currencyId: String?
        var name: String?
        var symbol: String?
        var usdValue: Decimal?
        var exchangePrice: String?
        var lastUpdatedAt: String?

        static var encodingStrategy: JSONEncodingStrategy {
            return JSONEncodingStrategy(keys: .convertToSnakeCase)
        }
        static var decodingStrategy: JSONDecodingStrategy {
            return JSONDecodingStrategy(keys: .convertFromSnakeCase)
        }

        init() {}
    }
}

final class FiatCurrencyList: ListEntityModel<FiatCurrency> {}
