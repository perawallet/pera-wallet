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
//   WCTransactionErrorResponse.swift

import Foundation

enum WCTransactionErrorResponse: Error {
    case rejected(Rejection)
    case unauthorized(Authorization)
    case unsupported(Support)
    case invalidInput(Invalid)

    var message: String {
        switch self {
        case let .rejected(type):
            switch type {
            case .user:
                return "wallet-connect-transaction-error-rejected-user".localized
            case .failedValidation:
                return "wallet-connect-transaction-error-group-validation".localized
            case .unsignable:
                return "wallet-connect-transaction-error-group-unauthorized-user".localized
            case .alreadyDisplayed:
                return "wallet-connect-transaction-error-already-displayed".localized
            case .none:
                return "wallet-connect-transaction-error-rejected".localized
            }
        case let .unauthorized(type):
            switch type {
            case .nodeMismatch:
                return "wallet-connect-transaction-error-node".localized
            case .signerNotFound:
                return "wallet-connect-transaction-error-invalid-signer".localized
            case .none:
                return "wallet-connect-transaction-error-unauthorized".localized
            }
        case let .unsupported(type):
            switch type {
            case .unknownTransaction:
                return "wallet-connect-transaction-error-unsupported-type".localized
            case .multisig:
                return "wallet-connect-transaction-error-multisig".localized
            case .none:
                return "wallet-connect-transaction-error-unsupported".localized
            }
        case let .invalidInput(type):
            switch type {
            case .transactionCount:
                return "wallet-connect-transaction-error-transaction-size".localized
            case .parse:
                return "wallet-connect-transaction-error-parse".localized
            case .publicKey:
                return "wallet-connect-transaction-error-invalid-key".localized
            case .asset:
                return "wallet-connect-transaction-error-invalid-asset".localized
            case .unableToFetchAsset:
                return "wallet-connect-transaction-error-unable-fetch-asset".localized
            case .unsignable:
                return "wallet-connect-transaction-error-unable-sign".localized
            case .group:
                return "wallet-connect-transaction-error-group".localized
            case .signer:
                return "wallet-connect-transaction-error-account-not-exist".localized
            case .none:
                return "wallet-connect-transaction-error-invalid".localized
            }
        }
    }
}

extension WCTransactionErrorResponse: RawRepresentable {
    typealias RawValue = Int

    init?(rawValue: RawValue) {
        switch rawValue {
        case 4001:
            self = .rejected(.none)
        case 4100:
            self = .unauthorized(.none)
        case 4200:
            self = .unsupported(.none)
        case 4300:
            self = .invalidInput(.none)
        default:
            return nil
        }
    }

    var rawValue: RawValue {
        switch self {
        case .rejected:
            return 4001
        case .unauthorized:
            return 4100
        case .unsupported:
            return 4200
        case .invalidInput:
            return 4300
        }
    }
}

extension WCTransactionErrorResponse {
    enum Rejection {
        case user
        case failedValidation
        case unsignable
        case alreadyDisplayed
        case none
    }

    enum Authorization {
        case nodeMismatch
        case signerNotFound
        case none
    }

    enum Support {
        case unknownTransaction
        case multisig
        case none
    }

    enum Invalid {
        case transactionCount
        case parse
        case publicKey
        case asset
        case unableToFetchAsset
        case unsignable
        case group
        case signer
        case none
    }
}
