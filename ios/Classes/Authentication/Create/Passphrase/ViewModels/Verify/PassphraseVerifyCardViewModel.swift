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

//   PassphraseVerifyCardViewModel.swift

import Foundation
import MacaroonUIKit

final class PassphraseVerifyCardViewModel: ViewModel {
    private(set) var cardIndex: Int?
    private(set) var headerText: EditText?
    private(set) var firstMnemonic: EditText?
    private(set) var secondMnemonic: EditText?
    private(set) var thirdMnemonic: EditText?
    
    init(
        index: Int?,
        mnemonics: [String]?
    ) {
        bindCardIndex(index)
        bindHeaderText(index)
        bindMnemonics(mnemonics)
    }
}

extension PassphraseVerifyCardViewModel {
    private func bindCardIndex(_ index: Int?) {
        cardIndex = index
    }
    private func bindHeaderText(_ index: Int?) {
        guard let index = index else {
            return
        }
        
        headerText = .attributedString(
            "passphrase-verify-select-word"
                .localized(params: "\(index + 1)")
                .bodyRegular(
                    alignment: .center
                )
        )
    }
    
    private func bindMnemonics(_ mnemonics: [String]?) {
        guard let mnemonics = mnemonics else {
            return
        }

        for (index, word) in mnemonics.enumerated() {
            switch index {
            case 0:
                firstMnemonic = .attributedString(word.bodyMedium(alignment: .center))
            case 1:
                secondMnemonic = .attributedString(word.bodyMedium(alignment: .center))
            case 2:
                thirdMnemonic = .attributedString(word.bodyMedium(alignment: .center))
            default:
                break
            }
        }
    }
}
