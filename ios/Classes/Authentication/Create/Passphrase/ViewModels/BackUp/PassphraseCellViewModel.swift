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
//  PassphraseCellViewModel.swift

import MacaroonUIKit
import Foundation

struct Passphrase {
    let index: Int
    let mnemonics: [String]?
}

final class PassphraseCellViewModel: PairedViewModel {
    private(set) var number: String?
    private(set) var phrase: String?

    init(_ model: Passphrase) {
        bindNumber(model.index)
        bindPhrase(model.mnemonics, at: model.index)
    }
}

extension PassphraseCellViewModel {
    private func bindNumber(_ index: Int) {
        number = "\(index + 1)"
    }

    private func bindPhrase(_ mnemonics: [String]?, at index: Int) {
        phrase = mnemonics?[index]
    }
}
