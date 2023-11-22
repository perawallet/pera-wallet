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

    /// <mark>: WC v2
    case unauthorizedChain(String)
    case unauthorizedMethod(String)
    case unsupportedNamespace
    case unsupportedChains
    case unsupportedMethods
    case noSessionForTopic
    case userRejectedChains(
        requestedNetwork: String,
        expectedNetwork: String
    )
    case generic(Error)

    var message: String {
        switch self {
        case let .rejected(type):
            switch type {
            case .user:
                return "wallet-connect-request-error-rejected-user".localized
            case .failedValidation:
                return "wallet-connect-transaction-error-group-validation".localized
            case .unsignable:
                return "wallet-connect-transaction-error-group-unauthorized-user".localized
            case .alreadyDisplayed:
                return "wallet-connect-request-error-already-displayed".localized
            case .none:
                return "wallet-connect-transaction-error-rejected".localized
            }
        case let .unauthorized(type):
            switch type {
            case .nodeMismatch:
                return "wallet-connect-transaction-error-node".localized
            case .dataSignerNotFound:
                return "wallet-connect-data-error-invalid-signer".localized
            case .transactionSignerNotFound:
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
            case .dataCount:
                return "wallet-connect-data-error-data-size".localized
            case .transactionCount:
                return "wallet-connect-transaction-error-transaction-size".localized
            case .dataParse:
                return "wallet-connect-data-error-parse".localized
            case .transactionParse:
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
            case .session:
                return "wallet-connect-transaction-error-session-not-found".localized
            case .none:
                return "wallet-connect-transaction-error-invalid".localized
            }
        case .unauthorizedChain(let chain):
            return "wallet-connect-v2-unauthorized-chain-error-message".localized(params: chain)
        case .unauthorizedMethod(let method):
            return "wallet-connect-v2-unauthorized-method-error-message".localized(params: method)
        case .unsupportedNamespace:
            return "wallet-connect-unsupported-namespace-error-message".localized
        case .unsupportedChains:
            return "wallet-connect-unsupported-chains-error-message".localized
        case .unsupportedMethods:
            return "wallet-connect-unsupported-methods-error-message".localized
        case .noSessionForTopic:
            return "wallet-connect-no-session-for-topic-error-message".localized
        case .userRejectedChains(let requestedNetwork, let expectedNetwork):
            return "wallet-connect-v2-user-rejected-chains-error-message".localized(
                params: requestedNetwork, expectedNetwork
            )
        case .generic(let error):
            return error.localizedDescription
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
        case .noSessionForTopic:
            return 7001
        case .unauthorizedChain:
            return 3005
        case .unauthorizedMethod:
            return 3001
        case .unsupportedNamespace:
            return 5104
        case .unsupportedChains:
            return 5100
        case .unsupportedMethods:
            return 5101
        case .userRejectedChains:
            return 5001
        case .generic:
            return 9999
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
        case dataSignerNotFound
        case transactionSignerNotFound
        case none
    }

    enum Support {
        case unknownTransaction
        case multisig
        case none
    }

    enum Invalid {
        case dataCount
        case transactionCount
        case dataParse
        case transactionParse
        case publicKey
        case asset
        case unableToFetchAsset
        case unsignable
        case group
        case signer
        case session
        case none
    }
}
