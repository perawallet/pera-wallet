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

//   RekeyingValidator.swift

import Foundation
import MacaroonUtils

struct RekeyingValidator {
    private let transactionSignatureValidator: TransactionSignatureValidator
    
    init(
        session: Session,
        sharedDataController: SharedDataController
    ) {
        self.transactionSignatureValidator = TransactionSignatureValidator(
            session: session,
            sharedDataController: sharedDataController
        )
    }
}

extension RekeyingValidator {
    func validateRekeying(
        from srcAcc: Account,
        to authAcc: Account
    ) -> RekeyingValidation {
        let isSelfRekeying = self.isSelfRekeying(
            from: srcAcc,
            to: authAcc
        )
        if isSelfRekeying {
            return validateRekeyingForUndo(srcAcc)
        }

        let isChainRekeying = self.isChainRekeying(
            from: srcAcc,
            to: authAcc
        )
        if isChainRekeying {
            return .failure(.invalid)
        }

        return validateRekeyingForTxnSignature(srcAcc)
    }

    private func validateRekeyingForUndo(_ acc: Account) -> RekeyingValidation {
        return acc.isRekeyed() ? .success : .failure(.invalid)
    }

    private func validateRekeyingForTxnSignature(_ acc: Account) -> RekeyingValidation {
        let result = transactionSignatureValidator.validateTxnSignature(acc)
        return result.isSuccess ? .success : .failure(.invalid)
    }
}

extension RekeyingValidator {
    private func isSelfRekeying(
        from srcAcc: Account,
        to authAcc: Account
    ) -> Bool {
        return srcAcc.isSameAccount(with: authAcc)
    }

    private func isChainRekeying(
        from srcAcc: Account,
        to authAcc: Account
    ) -> Bool {
        return authAcc.isRekeyed()
    }
}

typealias RekeyingValidation = Result<Void, RekeyingValidationError>

enum RekeyingValidationError: Error {
    case invalid
}
