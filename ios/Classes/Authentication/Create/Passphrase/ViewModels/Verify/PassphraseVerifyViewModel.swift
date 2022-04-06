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
//  PassphraseVerifyViewModel.swift

import UIKit
import MacaroonUIKit

final class PassphraseVerifyViewModel: ViewModel {
    private(set) var firstCardViewModel: PassphraseVerifyCardViewModel?
    private(set) var secondCardViewModel: PassphraseVerifyCardViewModel?
    private(set) var thirdCardViewModel: PassphraseVerifyCardViewModel?
    private(set) var fourthCardViewModel: PassphraseVerifyCardViewModel?

    init(
        shownMnemonics: [Int: [String]],
        correctIndexes: [Int]
    ) {
        setCards(
            from: shownMnemonics,
            indexes: correctIndexes
        )
    }

    private func setCards(
        from shownMnemonics: [Int: [String]],
        indexes: [Int]
    ) {
        shownMnemonics.forEach {index, mnemonics in
            switch index {
            case 0:
                firstCardViewModel = PassphraseVerifyCardViewModel(
                    index: indexes[index],
                    mnemonics: mnemonics
                )
            case 1:
                secondCardViewModel = PassphraseVerifyCardViewModel(
                    index: indexes[index],
                    mnemonics: mnemonics
                )
            case 2:
                thirdCardViewModel = PassphraseVerifyCardViewModel(
                    index: indexes[index],
                    mnemonics: mnemonics
                )
            case 3:
                fourthCardViewModel = PassphraseVerifyCardViewModel(
                    index: indexes[index],
                    mnemonics: mnemonics
                )
            default:
                break
            }
        }
    }
}
