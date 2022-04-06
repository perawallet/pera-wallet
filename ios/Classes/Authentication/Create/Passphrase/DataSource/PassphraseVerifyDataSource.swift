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
//  PassphraseVerifyDataSource.swift

import UIKit

final class PassphraseVerifyDataSource: NSObject {
    weak var delegate: PassphraseVerifyDataSourceDelegate?

    private let privateKey: Data

    private let numberOfValidations = 4
    private let numberOfWordsInAValidation = 3

    private var mnemonicIndexes: [Int] = []
    private var mnemonics: [String] = []
    private var shownMnemonics: [Int: [String]] = [:]
    private var correctSelections: [String] = []
    private var selectedMnemonics: [Int: Int] = [:]

    init(privateKey: Data) {
        self.privateKey = privateKey
        
        var error: NSError?
        self.mnemonics = AlgorandSDK().mnemonicFrom(privateKey, error: &error).components(separatedBy: " ")
        
        super.init()
        
        if error == nil {
            composeDisplayedData()
        }
    }
}

extension PassphraseVerifyDataSource {
    func loadData() {
        delegate?.passphraseVerifyDataSourceDidLoadData(
            self,
            shownMnemonics: shownMnemonics,
            correctIndexes: mnemonicIndexes
        )
    }
    
    func resetAndReloadData() {
        clearDisplayedData()
        composeDisplayedData()
                
        delegate?.passphraseVerifyDataSourceDidLoadData(
            self,
            shownMnemonics: shownMnemonics,
            correctIndexes: mnemonicIndexes
        )
    }
    
    private func clearDisplayedData() {
        mnemonicIndexes.removeAll()
        shownMnemonics.removeAll()
        correctSelections.removeAll()
        selectedMnemonics.removeAll()
    }
    
    private func composeDisplayedData() {
        generateRandomIndexes()
        generateShownMnemonics()
    }
}

extension PassphraseVerifyDataSource {
    private func generateRandomIndexes() {
        while mnemonicIndexes.count < numberOfValidations {
            let randomIndex = Int.random(in: 0 ..< mnemonics.count)

            if mnemonicIndexes.contains(randomIndex) {
                continue
            }

            mnemonicIndexes.append(randomIndex)
        }
    }

    private func generateShownMnemonics() {
        addValidMnemonicsToShow()
        let randomMnemonics = createRandomMnemonics()
        addRandomMnemonicsToShow(from: randomMnemonics)
        shuffleShownMnemonics()
    }

    private func addValidMnemonicsToShow() {
        for (index, mnemonicIndex) in mnemonicIndexes.enumerated() {
            let mnemonic = mnemonics[mnemonicIndex]
            shownMnemonics[index] = [mnemonic]
            correctSelections.append(mnemonic)
        }
    }

    private func createRandomMnemonics() -> Set<String> {
        var randomMnemonics: Set<String> = []
        let filteredMnemoncics = mnemonics.filter { !correctSelections.contains($0) }
        let shuffledMnemonics = filteredMnemoncics.shuffled()

        for mnemonic in shuffledMnemonics {
            if randomMnemonics.count == numberOfValidations * (numberOfWordsInAValidation - 1) {
                break
            }

            if randomMnemonics.contains(mnemonic) {
                continue
            }

            randomMnemonics.insert(mnemonic)
        }

        return randomMnemonics
    }

    private func addRandomMnemonicsToShow(from randomMnemonics: Set<String>) {
        var index = 0
        for randomMnemonic in randomMnemonics {
            shownMnemonics[index]?.append(randomMnemonic)

            if shownMnemonics[index]?.count == numberOfWordsInAValidation {
                index += 1
            }
        }
    }

    private func shuffleShownMnemonics() {
        shownMnemonics.forEach { index, mnemonics in
            shownMnemonics[index] = mnemonics.shuffled()
        }
    }
}

extension PassphraseVerifyDataSource {
    func selectMnemonic(
        _ section: Int,
        _ item: Int
    ) {
        selectedMnemonics[section] = item
        
        if selectedMnemonics.count == numberOfValidations {
            delegate?.passphraseVerifyDataSourceSelectAllItems()
        }
    }
    
    func verifyPassphrase() -> Bool {
        var isValidate = true
        
        for (section, item) in selectedMnemonics {
            guard let shownSection = shownMnemonics[section] else {
                isValidate = false
                return isValidate
            }
            
            if shownSection[item] != correctSelections[section] {
                isValidate = false
                break
            }
        }
        
        return isValidate
    }
}

protocol PassphraseVerifyDataSourceDelegate: AnyObject {
    func passphraseVerifyDataSourceDidLoadData(
        _ passphraseVerifyDataSource: PassphraseVerifyDataSource,
        shownMnemonics: [Int: [String]],
        correctIndexes: [Int]
    )
    
    func passphraseVerifyDataSourceSelectAllItems()
}
