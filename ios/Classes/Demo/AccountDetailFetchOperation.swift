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
//   AccountDetailFetchOperation.swift


import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class AccountDetailFetchOperation: MacaroonUtils.AsyncOperation {
    typealias Error = HIPNetworkError<NoAPIModel>
    
    let input: Input
    
    private(set) var result: Result<Output, Error> =
        .failure(.unexpected(UnexpectedError(responseData: nil, underlyingError: nil)))
    
    private var ongoingEndpoint: EndpointOperatable?

    private let api: ALGAPI
    private let completionQueue: DispatchQueue
    
    init(
        input: Input,
        api: ALGAPI
    ) {
        let address = input.localAccount.address

        self.input = input
        self.api = api
        self.completionQueue = DispatchQueue(
            label: "pera.queue.operation.accountFetch.\(address)",
            qos: .userInitiated
        )
    }
    
    override func main() {
        if finishIfCancelled() {
            return
        }
        
        let draft = AccountFetchDraft(publicKey: input.localAccount.address)

        ongoingEndpoint =
            api.fetchAccount(
                draft,
                queue: completionQueue,
                ignoreResponseOnCancelled: false
            ) { [weak self] result in
                guard let self = self else { return }
            
                self.ongoingEndpoint = nil
                
                switch result {
                case .success(let response):
                    let account = response.account
                    account.update(from: self.input.localAccount)
                    let output = Output(account: account)
                    self.result = .success(output)
                case .failure(let apiError, let apiErrorDetail):
                    if apiError.isHttpNotFound {
                        let account = Account(localAccount: self.input.localAccount)
                        let output = Output(account: account)
                        self.result = .success(output)
                    } else {
                        let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                        self.result = .failure(error)
                    }
                }
                
                self.finish()
            }
    }

    override func finishIfCancelled() -> Bool {
        if !isCancelled {
            return false
        }

        result = .failure(.connection(.init(reason: .cancelled)))
        finish()

        return true
    }
    
    override func cancel() {
        cancelOngoingEndpoint()
        super.cancel()
    }
}

extension AccountDetailFetchOperation {
    private func cancelOngoingEndpoint() {
        ongoingEndpoint?.cancel()
        ongoingEndpoint = nil
    }
}

extension AccountDetailFetchOperation {
    struct Input {
        let localAccount: AccountInformation
    }
    
    struct Output {
        let account: Account
    }
}
