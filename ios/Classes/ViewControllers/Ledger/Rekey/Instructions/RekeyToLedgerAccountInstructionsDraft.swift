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

//   RekeyToLedgerAccountInstructionsDraft.swift

import Foundation
import MacaroonUIKit

final class RekeyToLedgerAccountInstructionsDraft: RekeyInstructionsDraft {
    init(sourceAccount: Account) {
        let image = Self.makeImage(
            sourceAccount: sourceAccount
        )
        let title = Self.makeTitle(
            sourceAccount: sourceAccount
        )
        let body = Self.makeBody(
            sourceAccount: sourceAccount
        )
        let instructions = Self.makeInstructions(
            sourceAccount: sourceAccount
        )

        super.init(
            image: image,
            title: title,
            body: body,
            instructions: instructions
        )
    }
}

extension RekeyToLedgerAccountInstructionsDraft {
    private static func makeImage(
        sourceAccount: Account
    ) -> Image {
        let authorization = sourceAccount.authorization

        if authorization.isStandard {
            return "rekey-from-standard-account-illustration"
        }

        if authorization.isLedger {
            return "rekey-from-ledger-account-illustration"
        }

        if authorization.isRekeyed {
            return "rekey-from-rekeyed-account-illustration"
        }

        preconditionFailure("Unexpected account type in the flow")
    }
}

extension RekeyToLedgerAccountInstructionsDraft {
    private static func makeTitle(
        sourceAccount: Account
    ) -> TextProvider {
        return "title-rekey-to-ledger-account-capitalized-sentence"
            .localized
            .titleMedium()
    }
}

extension RekeyToLedgerAccountInstructionsDraft {
    private static func makeBody(
        sourceAccount: Account
    ) -> RekeyInstructionsBodyTextProvider {
        let authorization = sourceAccount.authorization

        if authorization.isStandard {
            return Self.makeRekeyStandardAccountToLedgerAccountBody()
        }

        if authorization.isLedger {
            return Self.makeRekeyLedgerAccountToLedgerAccountInstructions()
        }

        if authorization.isRekeyed {
            return Self.makeRekeyRekeyedAccountToLedgerAccountInstructions()
        }

        preconditionFailure("Unexpected account type in the flow")
    }

    private static func makeRekeyStandardAccountToLedgerAccountBody() -> RekeyInstructionsBodyTextProvider {
        let text = "rekey-standard-to-ledger-account-instructions-body".localized
        let highlightedText = "rekey-standard-to-ledger-account-instructions-body-highlighted-text".localized
        return Self.makeBody(text: text, highlightedText: highlightedText)
    }

    private static func makeRekeyLedgerAccountToLedgerAccountInstructions() -> RekeyInstructionsBodyTextProvider {
        let text = "rekey-ledger-to-ledger-account-instructions-body".localized
        let highlightedText = "rekey-ledger-to-ledger-account-instructions-body-highlighted-text".localized
        return Self.makeBody(text: text, highlightedText: highlightedText)
    }

    private static func makeRekeyRekeyedAccountToLedgerAccountInstructions() -> RekeyInstructionsBodyTextProvider {
        let text = "rekey-rekeyed-to-ledger-account-instructions-body".localized
        let highlightedText = "rekey-rekeyed-to-ledger-account-instructions-body-highlighted-text".localized
        return Self.makeBody(text: text, highlightedText: highlightedText)
    }
}

extension RekeyToLedgerAccountInstructionsDraft {
    private static func makeInstructions(
        sourceAccount: Account
    ) -> [InstructionItemViewModel] {
        let authorization = sourceAccount.authorization

        if authorization.isStandard {
            return Self.makeRekeyStandardAccountToLedgerAccountInstructions()
        }

        if authorization.isLedger {
            return Self.makeRekeyLedgerAccountToLedgerAccountInstructions()
        }

        if authorization.isRekeyed {
            return Self.makeRekeyRekeyedAccountToLedgerAccountInstructions()
        }

        preconditionFailure("Unexpected account type in the flow")
    }

    private static func makeRekeyStandardAccountToLedgerAccountInstructions() -> [InstructionItemViewModel] {
        return [
            RekeyAnyAccountToLedgerAccountFutureTransactionsSignInstructionViewModel(order: 1),
            RekeyAnyAccountToAnyAccountNoLongerAbleToSignInstructionViewModel(order: 2),
            RekeyAnyAccountToAnyAccountNoConfigurationChangeInstructionViewModel(order: 3),
            RekeyAnyAccountToAnyAccountOpenBluetoothInstructionViewModel(order: 4)
        ]
    }

    private static func makeRekeyLedgerAccountToLedgerAccountInstructions() -> [InstructionItemViewModel] {
        return [
            RekeyAnyAccountToLedgerAccountFutureTransactionsSignInstructionViewModel(order: 1),
            RekeyLedgerToLedgerAccountNoLongerConnectedInstructionViewModel(order: 2),
            RekeyAnyAccountToAnyAccountNoConfigurationChangeInstructionViewModel(order: 3),
            RekeyAnyAccountToAnyAccountOpenBluetoothInstructionViewModel(order: 4)
        ]
    }

    private static func makeRekeyRekeyedAccountToLedgerAccountInstructions() -> [InstructionItemViewModel] {
        return [
            RekeyRekeyedToLedgerAccountFutureTransactionsSignInstructionViewModel(order: 1),
            RekeyRekeyedToAnyAccountContinueUnableToSignInstructionViewModel(order: 2),
            RekeyAnyAccountToAnyAccountNoConfigurationChangeInstructionViewModel(order: 3),
            RekeyAnyAccountToAnyAccountOpenBluetoothInstructionViewModel(order: 4)
        ]
    }
}
