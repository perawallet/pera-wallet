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
//  TransactionAPIConnector.swift

import MagpieCore
import Foundation
import MagpieExceptions
import MagpieHipo

class TransactionAPIConnector {

    private var api: ALGAPI
    private let sharedDataController: SharedDataController

    init(api: ALGAPI, sharedDataController: SharedDataController) {
        self.api = api
        self.sharedDataController = sharedDataController
    }

    func getTransactionParams(
        then completion: @escaping (Result<TransactionParams, HIPNetworkError<NoAPIModel>>) -> Void
    ) {
        sharedDataController.getTransactionParams(completion)
    }

    func uploadTransaction(_ signedTransaction: Data, then completion: @escaping (TransactionID?, APIError?) -> Void) {
        api.sendTransaction(signedTransaction) { transactionIdResponse in
            switch transactionIdResponse {
            case let .success(transactionId):
                self.api.trackTransaction(TransactionTrackDraft(transactionId: transactionId.identifier))
                completion(transactionId, nil)
            case let .failure(error, _):
                completion(nil, error)
            }
        }
    }
}
