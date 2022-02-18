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
//  Currency.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class Currency: ALGEntityModel {
    let id: String
    let name: String?
    let symbol: String?
    let usdValue: Decimal? // usd to currecy
    let price: String?
    let priceValue: Decimal? // algo to currency
    let lastUpdateDate: String?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.id = apiModel.currencyId ?? "USD"
        self.name = apiModel.name
        self.symbol = apiModel.symbol
        self.usdValue = apiModel.usdValue
        self.price = apiModel.exchangePrice
        self.priceValue = apiModel.exchangePrice.unwrap { Decimal(string: $0) }
        self.lastUpdateDate = apiModel.lastUpdatedAt
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.currencyId = id
        apiModel.name = name
        apiModel.symbol = symbol
        apiModel.usdValue = usdValue
        apiModel.exchangePrice = price
        apiModel.lastUpdatedAt = lastUpdateDate
        return apiModel
    }
}

extension Currency {
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

        init() {
            self.currencyId = nil
            self.name = nil
            self.symbol = nil
            self.usdValue = nil
            self.exchangePrice = nil
            self.lastUpdatedAt = nil
        }
    }
}

extension Currency: Equatable {
    static func == (lhs: Currency, rhs: Currency) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Currency: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}


final class CurrencyList: ListEntityModel<Currency> {}
