// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WalletConnectProtocolResolver.swift

import Foundation

protocol WalletConnectProtocolResolver {
    var currentWalletConnectProtocol: WalletConnectProtocol? { get }
    var currentWalletConnectProtocolID: WalletConnectProtocolID? { get }
    
    var walletConnectV1Protocol: WalletConnectV1Protocol { get }
    var walletConnectV2Protocol: WalletConnectV2Protocol { get }
    
    func getWalletConnectProtocol(from session: WalletConnectSessionText) -> WalletConnectProtocol?
    func getWalletConnectProtocol(from id: WalletConnectProtocolID) -> WalletConnectProtocol
}

enum WalletConnectProtocolID: String {
    case v1
    case v2
    
    var rawValue: String {
        switch self {
        case .v1: return "1"
        case .v2: return "2"
        }
    }
}
