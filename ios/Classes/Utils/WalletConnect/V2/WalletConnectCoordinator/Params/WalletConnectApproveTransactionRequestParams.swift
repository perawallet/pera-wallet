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

//   WalletConnectApproveTransactionRequestParams.swift

import Foundation

protocol WalletConnectApproveTransactionRequestParams: WalletConnectParams {
    var v1Request: WalletConnectRequest? { get }
    var signature: [Data?]? { get }
    var v2Request: WalletConnectV2Request? { get }
    var response: WalletConnectV2CodableResult? { get }
}

struct WalletConnectV1ApproveTransactionRequestParams: WalletConnectApproveTransactionRequestParams {
    var v1Request: WalletConnectRequest?
    var signature: [Data?]?
    let v2Request: WalletConnectV2Request? = nil
    let response: WalletConnectV2CodableResult? = nil
    let currentProtocolID: WalletConnectProtocolID = .v1
}

struct WalletConnectV2ApproveTransactionRequestParams: WalletConnectApproveTransactionRequestParams {
    let v1Request: WalletConnectRequest? = nil
    let signature: [Data?]? = nil
    var v2Request: WalletConnectV2Request?
    var response: WalletConnectV2CodableResult?
    let currentProtocolID: WalletConnectProtocolID = .v2
}
