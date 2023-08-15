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

//   RekeyToStandardAccountInstructionsDraft.swift

import Foundation
import MacaroonUIKit

final class RekeyToStandardAccountInstructionsDraft: RekeyInstructionsDraft {
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

extension RekeyToStandardAccountInstructionsDraft {
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

extension RekeyToStandardAccountInstructionsDraft {
    private static func makeTitle(
        sourceAccount: Account
    ) -> TextProvider {
        return "title-rekey-to-standard-account-capitalized-sentence"
            .localized
            .titleMedium()
    }
}

extension RekeyToStandardAccountInstructionsDraft {
    private static func makeBody(
        sourceAccount: Account
    ) -> RekeyInstructionsBodyTextProvider {
        let authorization = sourceAccount.authorization

        if authorization.isStandard {
            return Self.makeRekeyStandardAccountToStandardAccountBody()
        }

        if authorization.isLedger {
            return Self.makeRekeyLedgerAccountToStandardAccountBody()
        }

        if authorization.isRekeyed {
            return Self.makeRekeyRekeyedAccountToStandardAccountBody()
        }

        preconditionFailure("Unexpected account type in the flow")
    }

    private static func makeRekeyStandardAccountToStandardAccountBody() -> RekeyInstructionsBodyTextProvider {
        let text = "rekey-standard-to-standard-account-instructions-body".localized
        let highlightedText = "rekey-standard-to-standard-account-instructions-body-highlighted-text".localized
        return Self.makeBody(text: text, highlightedText: highlightedText)
    }

    private static func makeRekeyLedgerAccountToStandardAccountBody() -> RekeyInstructionsBodyTextProvider {
        let text = "rekey-ledger-to-standard-account-instructions-body".localized
        let highlightedText = "rekey-ledger-to-standard-account-instructions-body-highlighted-text".localized
        return Self.makeBody(text: text, highlightedText: highlightedText)
    }

    private static func makeRekeyRekeyedAccountToStandardAccountBody() -> RekeyInstructionsBodyTextProvider {
        let text = "rekey-rekeyed-to-standard-account-instructions-body".localized
        let highlightedText = "rekey-rekeyed-to-standard-account-instructions-body-highlighted-text".localized
        return Self.makeBody(text: text, highlightedText: highlightedText)
    }
}

extension RekeyToStandardAccountInstructionsDraft {
    private static func makeInstructions(
        sourceAccount: Account
    ) -> [InstructionItemViewModel] {
        let authorization = sourceAccount.authorization

        if authorization.isStandard {
            return Self.makeRekeyStandardAccountToStandardAccountInstructions()
        }

        if authorization.isLedger {
            return Self.makeRekeyLedgerAccountToStandardAccountInstructions()
        }

        if authorization.isRekeyed {
            return Self.makeRekeyRekeyedAccountToStandardAccountInstructions(sourceAccount)
        }

        preconditionFailure("Unexpected account type in the flow")
    }

    private static func makeRekeyStandardAccountToStandardAccountInstructions() -> [InstructionItemViewModel] {
        return [
            RekeyStandardToStandardAccountFutureTransactionsSignInstructionViewModel(order: 1),
            RekeyAnyAccountToAnyAccountNoLongerAbleToSignInstructionViewModel(order: 2),
            RekeyAnyAccountToAnyAccountNoConfigurationChangeInstructionViewModel(order: 3)
        ]
    }

    private static func makeRekeyLedgerAccountToStandardAccountInstructions() -> [InstructionItemViewModel] {
        return [
            RekeyLedgerToStandardAccountFutureTransactionsSignInstructionViewModel(order: 1),
            RekeyLedgerToStandardAccountNoLongerRequiredToSignInstructionViewModel(order: 2),
            RekeyAnyAccountToAnyAccountNoConfigurationChangeInstructionViewModel(order: 3),
            RekeyAnyAccountToAnyAccountOpenBluetoothInstructionViewModel(order: 4)
        ]
    }

    private static func makeRekeyRekeyedAccountToStandardAccountInstructions(_ sourceAccount: Account) -> [InstructionItemViewModel] {
        var instructions: [InstructionItemViewModel] = [
            RekeyRekeyedToStandardAccountFutureTransactionsSignInstructionViewModel(order: 1),
            RekeyRekeyedToAnyAccountContinueUnableToSignInstructionViewModel(order: 2),
            RekeyAnyAccountToAnyAccountNoConfigurationChangeInstructionViewModel(order: 3),
        ]

        if sourceAccount.authorization.isRekeyedToLedger {
            let bluetoothInstruction = RekeyAnyAccountToAnyAccountOpenBluetoothInstructionViewModel(order: 4)
            instructions.append(bluetoothInstruction)
        }

        return instructions
    }
}
