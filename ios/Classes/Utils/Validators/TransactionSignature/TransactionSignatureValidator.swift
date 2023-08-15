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

//   TransactionSignatureValidator.swift

import Foundation

struct TransactionSignatureValidator {
    private let session: Session
    private let sharedDataController: SharedDataController
    
    init(
        session: Session,
        sharedDataController: SharedDataController
    ) {
        self.session = session
        self.sharedDataController = sharedDataController
    }
}

extension TransactionSignatureValidator {
    func validateTxnSignature(_ acc: Account) -> TransactionSignatureValidation {
        if !acc.authorization.isAuthorized {
            return .failure(.invalidAccountType)
        }

        if acc.hasAuthAccount() {
            return validateTxnSignatureForRekeyedAccount(acc)
        }

        if acc.authorization.isLedger {
            return .success
        }

        return validateTxnSignatureForStandardAccount(acc)
    }
}

extension TransactionSignatureValidator {
    private func validateTxnSignatureForRekeyedAccount(_ acc: Account) -> TransactionSignatureValidation {
        if isRekeyedToLedgerAccountInLocal(acc) {
            return .success
        }

        if isRekeyedToStandardAccountInLocal(acc) {
            return .success
        }

        return .failure(.missingAuthAccount)
    }

    private func isRekeyedToLedgerAccountInLocal(_ acc: Account) -> Bool {
        return acc.authorization.isRekeyedToLedger
    }

    private func isRekeyedToStandardAccountInLocal(_ acc: Account) -> Bool {
        return acc.authorization.isRekeyedToStandard
    }
}

extension TransactionSignatureValidator {
    private func validateTxnSignatureForStandardAccount(_ acc: Account) -> TransactionSignatureValidation {
        return acc.authorization.isStandard ? .success : .failure(.missingPrivateKey)
    }
}
