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
//  API+Currency.swift

import Foundation
import MagpieCore

extension ALGAPI {
    @discardableResult
    func getCurrencies(
        onCompleted handler: @escaping (Response.ModelResult<FiatCurrencyList>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.currencies)
            .method(.get)
            .completionHandler(handler)
            .execute()
    }
    
    @discardableResult
    func getCurrencyValue(
        _ currencyId: String,
        queue: DispatchQueue,
        onCompleted handler: @escaping (Response.ModelResult<FiatCurrency>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.currencyDetail, args: currencyId)
            .method(.get)
            .completionHandler(handler)
            .responseDispatcher(queue)
            .execute()
    }
}
