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
//  API.swift

import Foundation
import MacaroonApplication
import MacaroonUtils
import MagpieAlamofire
import MagpieCore

final class ALGAPI: API {
    let session: Session

    /// <todo>
    /// NOP!
    var _interceptor: ALGAPIInterceptor {
        return interceptor as! ALGAPIInterceptor
    }

    var network: Network {
        return _interceptor.network
    }
    var isTestNet: Bool {
        return _interceptor.isTestNet
    }

    init(session: Session, networkMonitor: NetworkMonitor? = nil) {
        self.session = session

        super.init(
            base: Environment.current.serverApi,
            networking: AlamofireNetworking(),
            interceptor: ALGAPIInterceptor(),
            networkMonitor: networkMonitor
        )

        self.ignoresResponseWhenEndpointsFailedFromUnauthorizedRequest = false

        debug {
            enableLogsInConsole()
        }
    }
}

extension ALGAPI {
    func setupNetworkBase(_ network: ALGAPI.Network) {
        base = _interceptor.setupNetworkBase(network)
    }
}

extension ALGAPI {
    enum Network: String {
        case testnet = "testnet"
        case mainnet = "mainnet"

        /// WC v1
        var allowedChainIDs: [Int] {
            switch self {
            case .testnet:
                return [
                    algorandWalletConnectV1ChainID,
                    algorandWalletConnectV1TestNetChainID
                ]
            case .mainnet:
                return [
                    algorandWalletConnectV1ChainID,
                    algorandWalletConnectV1MainNetChainID
                ]
            }
        }

        /// WC v2
        var allowedChainReference: String {
            switch self {
            case .testnet:
                return algorandWalletConnectV2TestNetChainReference
            case .mainnet:
                return algorandWalletConnectV2MainNetChainReference
            }
        }

        var isMainnet: Bool {
            return self == .mainnet
        }
        
        var isTestnet: Bool {
            return self == .testnet
        }
    }
}
