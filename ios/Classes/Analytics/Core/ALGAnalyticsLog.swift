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

protocol ALGAnalyticsLog {
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
    case ledgerTransactionError = "LedgerTransactionError"
    case mismatchAccountError = "MismatchAccountFound"
    case wcSessionSaveError = "WCSessionNotSaved"
}

extension ALGAnalyticsLogName {
    var code: Int {
        switch self {
        case .ledgerTransactionError: return 0
        case .mismatchAccountError: return 1
        case .wcSessionSaveError: return 2
        }
    }
}
