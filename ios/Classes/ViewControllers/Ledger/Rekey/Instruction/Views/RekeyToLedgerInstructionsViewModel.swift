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
//   LedgerRekeyInstructionsViewModel.swift

import MacaroonUIKit

final class RekeyToLedgerInstructionsViewModel: RekeyToAnyAccountInstructionsViewModel {
    private(set) var subtitle: String?
    private(set) var firstInstructionViewTitle: EditText?
    private(set) var secondInstructionViewTitle: EditText?
    private(set) var thirdInstructionViewTitle: EditText?
    private(set) var fourthInstructionViewTitle: EditText?

    init(_ requiresLedgerConnection: Bool) {
        bindSubtitle(requiresLedgerConnection)
        bindFirstInstructionViewTitle()
        bindSecondInstructionViewTitle(requiresLedgerConnection)
        bindThirdInstructionViewTitle()
        bindFourthInstructionViewTitle()
    }
}

extension RekeyToLedgerInstructionsViewModel {
    private func bindSubtitle(_ requiresLedgerConnection: Bool) {
        if requiresLedgerConnection {
            subtitle = "rekey-instruction-subtitle-ledger".localized
        } else {
            subtitle = "rekey-instruction-second-ledger".localized
        }
    }
    
    private func bindFirstInstructionViewTitle() {
        firstInstructionViewTitle = .string("rekey-instruction-first".localized)
    }

    private func bindSecondInstructionViewTitle(_ requiresLedgerConnection: Bool) {
        if requiresLedgerConnection {
            secondInstructionViewTitle = .string("rekey-instruction-second-ledger".localized)
        } else {
            secondInstructionViewTitle = .string("rekey-instruction-second-standard".localized)
        }
    }

    private func bindThirdInstructionViewTitle() {
        thirdInstructionViewTitle = .string("rekey-instruction-third".localized)
    }

    private func bindFourthInstructionViewTitle() {
        fourthInstructionViewTitle = .string("ledger-tutorial-bluetooth".localized)
    }
}
