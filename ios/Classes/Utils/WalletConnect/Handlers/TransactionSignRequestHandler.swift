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
//   TransactionSignRequestHandler.swift

import WalletConnectSwift
import Foundation

class TransactionSignRequestHandler: WalletConnectRequestHandler {
    private let analytics: ALGAnalytics
    
    init(analytics: ALGAnalytics) {
        self.analytics = analytics
    }

    override func canHandle(request: WalletConnectRequest) -> Bool {
        return request.method == WalletConnectMethod.transactionSign.rawValue
    }

    override func handle(request: WalletConnectRequest) {
        handleTransaction(from: request)
    }
}

extension TransactionSignRequestHandler {
    private func handleTransaction(from request: WalletConnectRequest) {
        analytics.record(
            .wcTransactionRequestReceived(transactionRequest: request)
        )
        
        analytics.track(
            .wcTransactionRequestReceived(transactionRequest: request)
        )
        
        guard let transactions = try? request.parameter(of: [WCTransaction].self, at: 0) else {
            DispatchQueue.main.async {
                self.delegate?.walletConnectRequestHandler(self, didInvalidate: request)
            }
            return
        }

        var transactionOption: WCTransactionOption?
        if request.parameterCount > 1 {
            transactionOption = try? request.parameter(of: WCTransactionOption.self, at: 1)
        }
        
        analytics.record(
            .wcTransactionRequestValidated(transactionRequest: request)
        )

        analytics.track(
            .wcTransactionRequestValidated(transactionRequest: request)
        )

        DispatchQueue.main.async {
            self.delegate?.walletConnectRequestHandler(self, shouldSign: transactions, for: request, with: transactionOption)
        }
    }
}
