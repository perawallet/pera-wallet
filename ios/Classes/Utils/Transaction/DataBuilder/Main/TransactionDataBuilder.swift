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
//  TransactionDataBuilder.swift

import Foundation
import MagpieHipo

class TransactionDataBuilder: NSObject, TransactionDataBuildable {

    weak var delegate: TransactionDataBuilderDelegate?

    private(set) var params: TransactionParams?
    private(set) var draft: TransactionSendDraft?

    let algorandSDK = AlgorandSDK()

    init(params: TransactionParams?, draft: TransactionSendDraft?) {
        self.params = params
        self.draft = draft
    }

    func composeData() -> Data? {
        return nil
    }
}

extension TransactionDataBuilder {
    func isValidAddress(_ address: String) -> Bool {
        if !algorandSDK.isValidAddress(address) {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.invalidAddress(address: address)))
            return false
        }
        
        return true
    }
}

protocol TransactionDataBuilderDelegate: AnyObject {
    func transactionDataBuilder(_ transactionDataBuilder: TransactionDataBuilder, didFailedComposing error: HIPTransactionError)
}
