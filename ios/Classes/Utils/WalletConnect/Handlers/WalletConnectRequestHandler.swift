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
//   WalletConnectRequestHandler.swift

import WalletConnectSwift
import Foundation

final class WalletConnectRequestHandler: RequestHandler {
    weak var delegate: WalletConnectRequestHandlerDelegate?

    private let analytics: ALGAnalytics
    
    init(analytics: ALGAnalytics) {
        self.analytics = analytics
    }

    func canHandle(request: WalletConnectRequest) -> Bool {
        return
            request.isArbitraryDataSignRequest ||
            request.isTransactionSignRequest
    }

    func handle(request: WalletConnectRequest) {
        handleRequest(request)
    }
}

extension WalletConnectRequestHandler {
    private func handleRequest(_ request: WalletConnectRequest) {
        if request.isArbitraryDataSignRequest {
            handleArbitraryDataSignRequest(request)
            return
        }

        if request.isTransactionSignRequest {
            handleTransactionSignRequest(request)
            return
        }
    }
}

extension WalletConnectRequestHandler {
    private func handleArbitraryDataSignRequest(_ request: WalletConnectRequest) {
        var arbitraryData: [WCArbitraryData] = []

        for param in 0..<request.parameterCount {
            if let data = try? request.parameter(of: WCArbitraryData.self, at: param) {
                arbitraryData.append(data)
            } else {
                DispatchQueue.main.async {
                    [weak self] in
                    guard let self else { return }
                    self.delegate?.walletConnectRequestHandler(self, didInvalidateArbitraryDataRequest: request)
                }
                return
            }
        }

        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            delegate?.walletConnectRequestHandler(
                self,
                shouldSign: arbitraryData,
                for: request
            )
        }
    }
}

extension WalletConnectRequestHandler {
    private func handleTransactionSignRequest(_ request: WalletConnectRequest) {
        analytics.record(
            .wcTransactionRequestReceived(transactionRequest: request)
        )
        analytics.track(
            .wcTransactionRequestReceived(transactionRequest: request)
        )

        guard let transactions = try? request.parameter(of: [WCTransaction].self, at: 0) else {
            DispatchQueue.main.async {
                [weak self] in
                guard let self else { return }
                self.delegate?.walletConnectRequestHandler(self, didInvalidateTransactionRequest: request)
            }
            return
        }

        analytics.record(
            .wcTransactionRequestValidated(transactionRequest: request)
        )
        analytics.track(
            .wcTransactionRequestValidated(transactionRequest: request)
        )

        var transactionOption: WCTransactionOption?
        if request.parameterCount > 1 {
            transactionOption = try? request.parameter(of: WCTransactionOption.self, at: 1)
        }

        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            self.delegate?.walletConnectRequestHandler(
                self,
                shouldSign: transactions,
                for: request,
                with: transactionOption
            )
        }
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
        didInvalidateTransactionRequest request: WalletConnectRequest
    )
    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        shouldSign arbitraryData: [WCArbitraryData],
        for request: WalletConnectRequest
    )
    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        didInvalidateArbitraryDataRequest request: WalletConnectRequest
    )
}

fileprivate extension WalletConnectRequest {
    var isArbitraryDataSignRequest: Bool {
        return method == WalletConnectMethod.arbitraryDataSign.rawValue
    }

    var isTransactionSignRequest: Bool {
        return method == WalletConnectMethod.transactionSign.rawValue
    }
}
