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

//   TransactionSignatureValidationError.swift

import Foundation

typealias TransactionSignatureValidation = Result<Void, TransactionSignatureValidationError>

enum TransactionSignatureValidationError:
    Error,
    ErrorDisplayable {
    case invalidAccountType
    case missingAuthAccount
    case missingPrivateKey
}

/// <todo>
/// Let's implement a generic apporach for error messages.
extension TransactionSignatureValidationError {
    var title: String {
        return "title-error".localized
    }
    var message: String {
        switch self {
        case .invalidAccountType: return ""
        case .missingAuthAccount: return "ledger-rekey-error-not-found".localized
        case .missingPrivateKey: return "ledger-rekey-error-not-found".localized
        }
    }
}
