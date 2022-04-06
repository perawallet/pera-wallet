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

        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23
        
        headerText = .attributedString(
            "passphrase-verify-select-word"
                .localized(params: "\(index + 1)")
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .textAlignment(.center),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }
    
    private func bindMnemonics(_ mnemonics: [String]?) {
        guard let mnemonics = mnemonics else {
            return
        }

        let font = Fonts.DMSans.medium.make(15)
        let lineHeightMultiplier = 1.23
        let attributeGroup: TextAttributeGroup = [
            .font(font),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(.center),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
        
        for (index, word) in mnemonics.enumerated() {
            switch index {
            case 0:
                firstMnemonic = .attributedString(word.attributed(attributeGroup))
            case 1:
                secondMnemonic = .attributedString(word.attributed(attributeGroup))
            case 2:
                thirdMnemonic = .attributedString(word.attributed(attributeGroup))
            default:
                break
            }
        }
    }
}
