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
//   ALGAPIBase.swift

import Foundation
import MacaroonApplication
import MacaroonUtils
import MagpieAlamofire
import MagpieCore
import KeychainAccess

final class ALGAPIBase {
    private(set) var algodToken: String?
    private(set) var indexerToken: String?
    private(set) var network: ALGAPI.Network = .mainnet

    func setupNetworkBase(_ network: ALGAPI.Network) -> String {
        self.network = network
       
        var node: AlgorandNode!
        if network == .testnet {
            node = testNetNode
        } else if network == .localnet {
            node = localNetNode
            
            let url = UserDefaults.standard.string(forKey: "urlString") ?? ""
            var port = UserDefaults.standard.string(forKey: "portString") ?? ""
            port = port.isEmpty ? "" : ":\(port)"
            node.algodAddress = url + port + "/v2"
            
            let keychain = KeychainAccess.Keychain(service: "com.algorand.algorand.token.private").accessibility(.whenUnlocked)
            let algodLocalToken = keychain.string(for: "algodLocalToken") ?? ""
            node.algodToken = algodLocalToken
        } else {
            node = mainNetNode
        }
        
        algodToken = node.algodToken
        indexerToken = node.indexerToken
        return node.algodAddress
    }
}

extension ALGAPIBase {
    enum Base {
        case algod(ALGAPI.Network)
        case indexer(ALGAPI.Network)
        case mobileV1(ALGAPI.Network)
        case mobileV2(ALGAPI.Network)
        case algoExplorer

        init?(_ base: String, network: ALGAPI.Network) {
            if base.isAlgodApiBase {
                self = .algod(network)
            } else if base.isIndexerApiBase {
                self = .indexer(network)
            } else if base.isMobileApiV1Base {
                self = .mobileV1(network)
            } else if base.isAlgoExplorerApiBase {
                self = .algoExplorer
            } else if base.isMobileApiV2Base {
                self = .mobileV2(network)
            } else {
                return nil
            }
        }

        var value: String {
            switch self {
            case let .algod(network):
                if network == .testnet {
                    return Environment.current.testNetAlgodApi
                } else if network == .localnet {
                    let url = UserDefaults.standard.string(forKey: "urlString") ?? ""
                    var port = UserDefaults.standard.string(forKey: "portString") ?? ""
                    port = port.isEmpty ? "" : ":\(port)"
                    let localMainNetAlgodApi = url + port + "/v2"
                    
                    return localMainNetAlgodApi
                } else {
                    return Environment.current.mainNetAlgodApi
                }
            case let .indexer(network):
                if network == .testnet {
                    return Environment.current.testNetIndexerApi
                } else {
                    return Environment.current.mainNetIndexerApi
                }
            case let .mobileV1(network):
                if network == .testnet {
                    return Environment.current.testNetMobileAPIV1
                } else {
                    return Environment.current.mainNetMobileAPIV1
                }
            case let .mobileV2(network):
                if network == .testnet {
                    return Environment.current.testNetMobileAPIV2
                } else {
                    return Environment.current.mainNetMobileAPIV2
                }
            case .algoExplorer:
                return Environment.current.algoExplorerApi
            }
        }
    }
}

fileprivate extension String {
    var isAlgodApiBase: Bool {
        let url = UserDefaults.standard.string(forKey: "urlString") ?? ""
        var port = UserDefaults.standard.string(forKey: "portString") ?? ""
        port = port.isEmpty ? "" : ":\(port)"
        let localMainNetAlgodApi = url + port + "/v2"
        
        return self == Environment.current.testNetAlgodApi ||
                self == Environment.current.mainNetAlgodApi ||
                self == localMainNetAlgodApi
    }

    var isIndexerApiBase: Bool {
        return self == Environment.current.testNetIndexerApi || self == Environment.current.mainNetIndexerApi
    }

    var isMobileApiV1Base: Bool {
        return self == Environment.current.testNetMobileAPIV1 || self == Environment.current.mainNetMobileAPIV1
    }

    var isMobileApiV2Base: Bool {
        return self == Environment.current.testNetMobileAPIV2 || self == Environment.current.mainNetMobileAPIV2
    }

    var isAlgoExplorerApiBase: Bool {
        return self == Environment.current.algoExplorerApi
    }
}

extension EndpointBuilder {
    @discardableResult
    func base(_ someBase: ALGAPIBase.Base) -> Self {
        return base(someBase.value)
    }
}
