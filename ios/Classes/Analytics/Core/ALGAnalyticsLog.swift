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

//  ALGAnalyticsLog.swift

import Foundation
import MacaroonUtils

protocol ALGAnalyticsLog: ALGAnalyticsParameterRegulator {
    var name: ALGAnalyticsLogName { get }
    var metadata: ALGAnalyticsMetadata { get }
}

/// <note>
/// Naming convention:
/// The log type should be added as suffix, i.e. Error
/// Sort:
/// Alphabetical order by value
enum ALGAnalyticsLogName:
    String,
    CaseIterable,
    Printable {
    case ledgerAccountSelectionScreenFetchingRekeyingAccountsFailed = "ledgerAccountSelectionScreenFetchingRekeyingAccountsFailed"
    case ledgerTransactionError = "LedgerTransactionError"
    case mismatchAccountError = "MismatchAccountFound"
    case recoverAccountWithPassphraseScreenFetchingRekeyingAccountsFailed = "recoverAccountWithPassphraseScreenFetchingRekeyingAccountsFailed"
    case wcSessionSaveError = "WCSessionNotSaved"
    case walletConnectTransactionRequestDidAppear = "WCTransactionRequestDidAppear"
    case walletConnectTransactionRequestDidLoad = "WCTransactionRequestDidLoad"
    case walletConnectTransactionRequestReceived = "WCTransactionRequestReceived"
    case walletConnectTransactionRequestSDKError = "WCTransactionRequestSDKError"
    case walletConnectTransactionRequestValidated = "WCTransactionRequestValidated"
    case walletConnectV2SessionConnectionApprovalFailed = "WCv2SessionConnectionApprovalFailed"
    case walletConnectV2SessionConnectionFailed = "WCv2SessionConnectionFailed"
    case walletConnectV2SessionConnectionRejectionFailed = "WCv2SessionConnectionRejectionFailed"
    case walletConnectV2SessionDisconnectionFailed = "WCv2SessionDisconnectionFailed"
    case walletConnectV2TransactionRequestApprovalFailed = "WCv2TransactionRequestApprovalFailed"
    case walletConnectV2TransactionRequestRejectionFailed = "WCv2TransactionRequestRejectionFailed"
}

extension ALGAnalyticsLogName {
    var code: Int {
        switch self {
        case .ledgerTransactionError: return 0
        case .mismatchAccountError: return 1
        case .wcSessionSaveError: return 2
        case .walletConnectTransactionRequestDidAppear: return 3
        case .walletConnectTransactionRequestDidLoad: return 4
        case .walletConnectTransactionRequestReceived: return 5
        case .walletConnectTransactionRequestValidated: return 6
        case .walletConnectTransactionRequestSDKError: return 7
        case .ledgerAccountSelectionScreenFetchingRekeyingAccountsFailed: return 8
        case .recoverAccountWithPassphraseScreenFetchingRekeyingAccountsFailed: return 9
        case .walletConnectV2SessionConnectionApprovalFailed: return 10
        case .walletConnectV2SessionConnectionFailed: return 11
        case .walletConnectV2SessionConnectionRejectionFailed: return 12
        case .walletConnectV2SessionDisconnectionFailed: return 13
        case .walletConnectV2TransactionRequestApprovalFailed: return 14
        case .walletConnectV2TransactionRequestRejectionFailed: return 15
        }
    }
}
