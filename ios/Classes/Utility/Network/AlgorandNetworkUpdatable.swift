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
//  AlgorandNetworkUpdatable.swift

import UIKit

protocol AlgorandNetworkUpdatable {
    var appConfiguration: AppConfiguration { get }
    func initializeNetwork()
    func setNetworkFromTarget()
    func setNetwork(to network: AlgorandAPI.BaseNetwork)
}

extension AlgorandNetworkUpdatable where Self: UIViewController {
    func initializeNetwork() {
        if let authenticatedUser = appConfiguration.session.authenticatedUser {
            if let preferredAlgorandNetwork = authenticatedUser.preferredAlgorandNetwork() {
                setNetwork(to: preferredAlgorandNetwork)
            } else {
                setNetworkFromTarget()
            }
        } else {
            setNetworkFromTarget()
        }
    }

    func setNetworkFromTarget() {
        if Environment.current.isTestNet {
            setNetwork(to: .testnet)
        } else {
            setNetwork(to: .mainnet)
        }
    }

    func setNetwork(to network: AlgorandAPI.BaseNetwork) {
        appConfiguration.api.cancelEndpoints()
        appConfiguration.api.setupEnvironment(for: network)
    }
}
