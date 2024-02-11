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

//   ALGAPI+Swap.swift

import Foundation
import MagpieCore
import MagpieExceptions

extension ALGAPI {
    @discardableResult
    func getAvailablePoolAssets(
        _ draft: AvailablePoolAssetsQuery,
        ignoreResponseOnCancelled: Bool,
        onCompleted handler: @escaping (Response.Result<AssetDecorationList, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.availableSwapPoolAssets)
            .method(.get)
            .query(draft)
            .ignoreResponseWhenEndpointCancelled(ignoreResponseOnCancelled)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func calculatePeraSwapFee(
        _ draft: PeraSwapFeeDraft,
        onCompleted handler: @escaping (Response.Result<PeraSwapFee, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.calculatePeraFee)
            .method(.post)
            .body(draft)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func prepareSwapTransactions(
        _ draft: SwapTransactionPreparationDraft,
        ignoreResponseOnCancelled: Bool = true,
        onCompleted handler: @escaping (Response.Result<SwapTransactionPreparation, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.prepareSwapTransaction)
            .method(.post)
            .body(draft)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func getSwapQuote(
        _ draft: SwapQuoteDraft,
        onCompleted handler: @escaping (Response.Result<SwapQuoteList, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.swapQuote)
            .method(.post)
            .body(draft)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func updateSwapQuote(_ draft: UpdateSwapQuoteDraft) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.swapQuoteUpdate, args: String(draft.id))
            .method(.patch)
            .body(draft)
            .execute()
    }
}
