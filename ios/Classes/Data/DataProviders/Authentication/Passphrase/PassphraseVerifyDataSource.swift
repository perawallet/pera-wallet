// Copyright 2019 Algorand, Inc.

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

class PassphraseVerifyDataSource: NSObject {

    weak var delegate: PassphraseVerifyDataSourceDelegate?

    private let privateKey: Data

    private let numberOfValidations = 4
    private let numberOfWordsInAValidation = 3

    private var mnemonicIndexes: [Int] = []
    private let mnemonics: [String]
    private var shownMnemonics: [Int: [String]] = [:]
    private var correctSelections: [String] = []

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
    private func composeDisplayedData() {
        generateRandomIndexes()
        generateShownMnemonics()
    }

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

extension PassphraseVerifyDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfValidations
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfWordsInAValidation
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let mnemonics = shownMnemonics[indexPath.section],
              let mnemonic = mnemonics[safe: indexPath.item],
              let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PassphraseMnemonicCell.reusableIdentifier,
                for: indexPath
            ) as? PassphraseMnemonicCell else {
            fatalError("Index path is out of bounds")
        }

        cell.bind(PassphraseMnemonicViewModel(mnemonic: mnemonic))
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind != UICollectionView.elementKindSectionHeader {
            fatalError("Unexpected element kind")
        }

        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PasshraseMnemonicNumberHeaderSupplementaryView.reusableIdentifier,
            for: indexPath
        ) as? PasshraseMnemonicNumberHeaderSupplementaryView else {
            fatalError("Unexpected element kind")
        }

        headerView.bind(PasshraseMnemonicNumberHeaderViewModel(order: mnemonicIndexes[indexPath.section]))
        return headerView
    }
}

extension PassphraseVerifyDataSource {
    func validateSelection(in collectionView: UICollectionView) {
        guard let selectedIndexes = collectionView.indexPathsForSelectedItems,
              selectedIndexes.count == numberOfValidations else {
            return
        }

        var isValidated = true
        for indexPath in selectedIndexes {
            isValidated = selectedMnemonic(at: indexPath) == mnemonicValue(at: indexPath)
            if !isValidated {
                delegate?.passphraseVerifyDataSource(self, isValidated: false)
                return
            }
        }

        delegate?.passphraseVerifyDataSource(self, isValidated: isValidated)
    }

    private func selectedMnemonic(at indexPath: IndexPath) -> String? {
        let mnemonics = shownMnemonics[indexPath.section]
        return mnemonics?[safe: indexPath.item]
    }

    private func mnemonicValue(at indexPath: IndexPath) -> String? {
        let mnemonicIndex = mnemonicIndexes[safe: indexPath.section]
        return mnemonics[safe: mnemonicIndex]
    }

    func resetVerificationData() {
        clearDisplayedData()
        composeDisplayedData()
    }

    private func clearDisplayedData() {
        mnemonicIndexes.removeAll()
        shownMnemonics.removeAll()
        correctSelections.removeAll()
    }
}

protocol PassphraseVerifyDataSourceDelegate: AnyObject {
    func passphraseVerifyDataSource(_ passphraseVerifyDataSource: PassphraseVerifyDataSource, isValidated: Bool)
}
