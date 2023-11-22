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

//   WalletConnectUpdateSessionConnectionParams.swift

import Foundation

protocol WalletConnectParams {
    var currentProtocolID: WalletConnectProtocolID { get }
}

protocol WalletConnectUpdateSessionConnectionParams: WalletConnectParams {
    var v1Session: WalletConnectSession? { get }
    var newWalletInfo: WalletConnectSessionWalletInfo? { get }
    var v2Session: WalletConnectV2Session? { get }
    var namespaces: SessionNamespaces? { get }
}

struct WalletConnectV1UpdateSessionConnectionParams: WalletConnectUpdateSessionConnectionParams {
    var v1Session: WalletConnectSession?
    var newWalletInfo: WalletConnectSessionWalletInfo?
    let v2Session: WalletConnectV2Session? = nil
    let namespaces: SessionNamespaces? = nil
    let currentProtocolID: WalletConnectProtocolID = .v1
}

struct WalletConnectV2UpdateSessionConnectionParams: WalletConnectUpdateSessionConnectionParams {
    let v1Session: WalletConnectSession? = nil
    let newWalletInfo: WalletConnectSessionWalletInfo? = nil
    var v2Session: WalletConnectV2Session?
    var namespaces: SessionNamespaces?
    let currentProtocolID: WalletConnectProtocolID = .v1
}
