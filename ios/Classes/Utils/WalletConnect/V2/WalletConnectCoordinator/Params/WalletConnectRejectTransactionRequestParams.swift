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

//   WalletConnectRejectTransactionRequestParams.swift

import Foundation

protocol WalletConnectRejectTransactionRequestParams: WalletConnectParams {
    var v1Request: WalletConnectRequest? { get }
    var error: WCTransactionErrorResponse? { get }
    var v2Request: WalletConnectV2Request? { get }
}

struct WalletConnectV1RejectTransactionRequestParams: WalletConnectRejectTransactionRequestParams {
    var v1Request: WalletConnectRequest?
    var error: WCTransactionErrorResponse?
    let v2Request: WalletConnectV2Request? = nil
    let currentProtocolID: WalletConnectProtocolID = .v1
}

struct WalletConnectV2RejectTransactionRequestParams: WalletConnectRejectTransactionRequestParams {
    let v1Request: WalletConnectRequest? = nil
    var error: WCTransactionErrorResponse?
    var v2Request: WalletConnectV2Request?
    let currentProtocolID: WalletConnectProtocolID = .v2
}
