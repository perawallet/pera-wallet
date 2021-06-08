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
//  API+Node.swift

import Magpie

extension AlgorandAPI {
    @discardableResult
    func checkNodeHealth(with draft: NodeTestDraft, then handler: BoolHandler? = nil) -> EndpointOperatable? {
        let resultHandler: (Response.RawResult) -> Void = { result in
            switch result {
            case .success:
                handler?(true)
            case .failure:
                handler?(false)
            }
        }
        
        let address = draft.address
        let token = draft.token
        
        guard let url = URL(string: address) else {
            handler?(false)
            return nil
        }
        
        return EndpointBuilder(api: self)
            .base(url.absoluteString)
            .path("/health")
            .validateResponseBeforeEndpointCompleted(false)
            .headers(nodeHealthHeaders(for: token))
            .completionHandler(resultHandler)
            .build()
            .send()
    }
}
