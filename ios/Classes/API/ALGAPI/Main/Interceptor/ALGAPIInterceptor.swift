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
//   ALGAPIInterceptor.swift

import Foundation
import MagpieCore
import MacaroonUtils
import MagpieHipo

final class ALGAPIInterceptor: APIInterceptor {

    private let sharedHeaders: Headers = [AcceptJSONHeader(), AcceptGZIPEncodingHeader(), ContentTypeJSONHeader()]

    private lazy var apiBase = ALGAPIBase()

    private lazy var application = HIPApplication()
    private lazy var device = HIPDevice()

    func intercept(_ endpoint: EndpointOperatable) {
        setCommonHeaders(endpoint)
        setAdditionalHeaders(endpoint)
    }

    func intercept(_ response: Response, for endpoint: EndpointOperatable) -> Bool {
        return false
    }
}

extension ALGAPIInterceptor {
    private func setCommonHeaders(_ endpoint: EndpointOperatable) {
        for header in sharedHeaders {
            endpoint.setAdditionalHeader(header, policy: .alwaysOverride)
        }
    }

    private func setAdditionalHeaders(_ endpoint: EndpointOperatable) {
        guard let base = ALGAPIBase.Base(endpoint.request.base, network: apiBase.network) else {
            return
        }

        switch base {
        case .algod:
            setAlgodHeaders(endpoint)
        case .indexer:
            setIndexerHeaders(endpoint)
        case .mobile:
            setMobileHeaders(endpoint)
        case .algoExplorer:
            break
        }
    }

    private func setAlgodHeaders(_ endpoint: EndpointOperatable) {
        if let token = apiBase.algodToken {
            endpoint.setAdditionalHeader(CustomHeader(key: "X-Algo-API-Token", value: token), policy: .alwaysOverride)
        }
    }

    private func setIndexerHeaders(_ endpoint: EndpointOperatable) {
        if let token = apiBase.indexerToken {
            endpoint.setAdditionalHeader(CustomHeader(key: "X-Indexer-API-Token", value: token), policy: .alwaysOverride)
        }
    }

    private func setMobileHeaders(_ endpoint: EndpointOperatable) {
        endpoint.setAdditionalHeader(APIKeyHeader())
        endpoint.setAdditionalHeader(NetworkHeader(apiBase.network), policy: .setIfNotExists)
        endpoint.setAdditionalHeader(AppNameHeader(application), policy: .alwaysOverride)
        endpoint.setAdditionalHeader(AppPackageNameHeader(application), policy: .alwaysOverride)
        endpoint.setAdditionalHeader(AppVersionHeader(application), policy: .alwaysOverride)
        endpoint.setAdditionalHeader(ClientTypeHeader(device), policy: .alwaysOverride)
        endpoint.setAdditionalHeader(DeviceOSVersionHeader(device), policy: .alwaysOverride)
        endpoint.setAdditionalHeader(DeviceModelHeader(device), policy: .alwaysOverride)
    }
}

extension ALGAPIInterceptor {
    /// <todo>
    /// NOP!
    var network: ALGAPI.Network {
        return apiBase.network
    }
    var isTestNet: Bool {
        return network == .testnet
    }

    func setupNetworkBase(_ network: ALGAPI.Network) -> String {
        return apiBase.setupNetworkBase(network)
    }
}

struct APIKeyHeader: Header {
    let key: String
    let value: String?

    init() {
        self.key = "X-API-Key"
        self.value = Environment.current.apiKey
    }
}

struct NetworkHeader: Header {
    let key: String
    let value: String?

    init(
        _ network: ALGAPI.Network?
    ) {
        self.key = "algorand-network"
        self.value = network?.rawValue
    }
}

struct ModificationHeader: Header {
    let key: String
    let value: String?

    init(
        _ modificationKey: String
    ) {
        self.key = "X-Modification-Key"
        self.value = modificationKey
    }
}
