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

//   SwapFailedEvent.swift

import Foundation
import MacaroonVendors

struct SwapFailedEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(mapper: SwapStatusEventMapper) {
        self.name = .swapFailed

        var mapper = mapper
        guard let params = mapper.mapEventParams() else {
            self.metadata = [:]
            return
        }

        self.metadata = [
            .inputASAID: params.inputASAID,
            .inputASAName: Self.regulate(params.inputASAName),
            .inputAmountAsASA: params.inputAmountAsASA,
            .inputAmountAsUSD: params.inputAmountAsUSD,
            .inputAmountAsAlgo: params.inputAmountAsAlgo,
            .outputASAID: params.outputASAID,
            .outputASAName: Self.regulate(params.outputASAName),
            .outputAmountAsASA: params.outputAmountAsASA,
            .outputAmountAsUSD: params.outputAmountAsUSD,
            .outputAmountAsAlgo: params.outputAmountAsAlgo,
            .swapDate: params.swapDate,
            .swapDateTimestamp: params.swapDateTimestamp,
            .swapAddress: params.swapperAddress
        ]
    }
}

extension AnalyticsEvent where Self == SwapFailedEvent {
    static func swapFailed(
        quote: SwapQuote,
        currency: CurrencyProvider
    ) -> Self {
        return SwapFailedEvent(
            mapper: SwapStatusEventMapper(
                quote: quote,
                parsedTransactions: [],
                currency: currency
            )
        )
    }
}
