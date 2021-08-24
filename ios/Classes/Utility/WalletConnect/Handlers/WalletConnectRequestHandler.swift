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
//   WalletConnectRequestHandler.swift

import WalletConnectSwift

class WalletConnectRequestHandler: RequestHandler {

    weak var delegate: WalletConnectRequestHandlerDelegate?

    func canHandle(request: WalletConnectRequest) -> Bool {
        return false
    }

    func handle(request: WalletConnectRequest) {

    }
}

protocol WalletConnectRequestHandlerDelegate: AnyObject {
    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        shouldSign transactions: [WCTransaction],
        for request: WalletConnectRequest,
        with transactionOption: WCTransactionOption?
    )
    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        didInvalidate request: WalletConnectRequest
    )
}
