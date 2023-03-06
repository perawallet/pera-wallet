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
//   WalletConnectBridge.swift

import Foundation
import WalletConnectSwift

class WalletConnectBridge {

    weak var delegate: WalletConnectBridgeDelegate?

    private(set) lazy var walletConnectServer = WalletConnectServer(delegate: self)
}

extension WalletConnectBridge {
    func register(_ handler: WalletConnectRequestHandler) {
        walletConnectServer.register(handler: handler)
    }

    func connect(to url: WCURL) throws {
        try walletConnectServer.connect(to: url)
    }

    func reconnect(to session: WalletConnectSession) throws {
        try walletConnectServer.reconnect(to: session)
    }

    func disconnect(from session: WalletConnectSession) throws {
        try walletConnectServer.disconnect(from: session)
    }
    
    func update(session: WalletConnectSession, with newWalletInfo: WalletConnectSessionWalletInfo) throws {
        try walletConnectServer.updateSession(session, with: newWalletInfo)
    }
}

extension WalletConnectBridge {
    func signTransactionRequest(_ request: WalletConnectRequest, with signature: [Data?]) {
        if let signature = WalletConnectResponse.signature(signature, for: request) {
            walletConnectServer.send(signature)
        }
    }

    func rejectTransactionRequest(_ request: WalletConnectRequest, with error: WCTransactionErrorResponse) {
        if let rejection = WalletConnectResponse.rejection(request, with: error) {
            walletConnectServer.send(rejection)
        }
    }
}

extension WalletConnectBridge: ServerDelegate {
    func server(
        _ server: WalletConnectServer,
        shouldStart session: WalletConnectSession,
        completion: @escaping (WalletConnectSession.WalletInfo) -> Void
    ) {
        delegate?.walletConnectBridge(self, shouldStart: session, then: completion)
    }

    func server(_ server: WalletConnectServer, didConnect session: WalletConnectSession) {
        delegate?.walletConnectBridge(self, didConnectTo: session)
    }

    func server(_ server: WalletConnectServer, didDisconnect session: WalletConnectSession) {
        delegate?.walletConnectBridge(self, didDisconnectFrom: session)
    }

    func server(_ server: WalletConnectServer, didFailToConnect url: WalletConnectURL) {
        delegate?.walletConnectBridge(self, didFailToConnect: url)
    }

    func server(_ server: WalletConnectServer, didUpdate session: WalletConnectSession) {
        delegate?.walletConnectBridge(self, didUpdate: session)
    }
    
    func server(_ server: Server, didFailWith error: Error?, for url: WCURL) {
        delegate?.walletConnectBridge(self, didFailWith: error, for: url)
    }
}

protocol WalletConnectBridgeDelegate: AnyObject {
    func walletConnectBridge(
        _ walletConnectBridge: WalletConnectBridge,
        shouldStart session: WalletConnectSession,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    )
    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didFailToConnect url: WalletConnectURL)
    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didConnectTo session: WalletConnectSession)
    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didDisconnectFrom session: WalletConnectSession)
    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didUpdate session: WalletConnectSession)
    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didFailWith error: Error?, for url: WalletConnectURL)
}

typealias WalletConnectSession = WalletConnectSwift.Session
typealias WalletConnectURL = WCURL
typealias WalletConnectServer = WalletConnectSwift.Server
typealias WalletConnectRequest = WalletConnectSwift.Request
typealias WalletConnectResponse = WalletConnectSwift.Response
typealias WalletConnectSessionWalletInfo = WalletConnectSwift.Session.WalletInfo
typealias WalletConnectSessionConnectionCompletionHandler = (WalletConnectSessionWalletInfo) -> Void
typealias WalletConnectTopic = String
