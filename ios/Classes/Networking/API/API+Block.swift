// Copyright 2019 Algorand, Inc.

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
//   API+Block.swift

import Magpie

extension AlgorandAPI {
    @discardableResult
    func waitRound(
        with draft: WaitRoundDraft,
        then handler: @escaping (Response.ModelResult<RoundDetail>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(algodBase)
            .path("/v2/status/wait-for-block-after/\(draft.round)")
            .headers(algodAuthenticatedHeaders())
            .completionHandler(handler)
            .build()
            .send()
    }

    @discardableResult
    func getTotalSupply(then handler: @escaping (Response.ModelResult<AlgorandTotalSupply>) -> Void) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(algodBase)
            .path("/v2/ledger/supply")
            .headers(algodAuthenticatedHeaders())
            .completionHandler(handler)
            .build()
            .send()
    }

    @discardableResult
    func getBlock(_ blockNumber: UInt64, then handler: @escaping (Response.ModelResult<AlgorandBlock>) -> Void) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(algodBase)
            .path("/v2/blocks/\(blockNumber)")
            .headers(algodAuthenticatedHeaders())
            .completionHandler(handler)
            .build()
            .send()
    }

    @discardableResult
    func getStatus(then handler: @escaping (Response.ModelResult<RoundDetail>) -> Void) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(algodBase)
            .path("/v2/status")
            .headers(algodAuthenticatedHeaders())
            .completionHandler(handler)
            .build()
            .send()
    }
}
