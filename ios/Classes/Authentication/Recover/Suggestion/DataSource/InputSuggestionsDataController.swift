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
//   InputSuggestionsDataController.swift

import Foundation

final class InputSuggestionsDataController: NSObject {
    weak var delegate: InputSuggestionsDataControllerDelegate?

    private(set) var suggestionCount = 3
    private var allSuggestions: [String] = []
    private var currentSuggestions: [String]
    
    var hasSuggestions: Bool {
        return currentSuggestionCount > 0
    }

    var currentSuggestionCount: Int {
        return currentSuggestions.filter { !$0.isEmpty }.count
    }

    func hasMatchingSuggestion(with text: String) -> Bool {
        return allSuggestions.contains { $0.caseInsensitiveCompare(text) == .orderedSame }
    }

    override init() {
        currentSuggestions = [String](repeating: "", count: suggestionCount)
        super.init()
        readSuggestionsFromFile()
    }

    private func readSuggestionsFromFile() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {
                return
            }

            if let filepath = Bundle.main.path(forResource: "mnemonics", ofType: "txt") {
                do {
                    let contents = try String(contentsOfFile: filepath)
                    self.allSuggestions = contents.components(separatedBy: "\n")
                } catch {
                    DispatchQueue.main.async {
                        self.delegate?.inputSuggestionsDataController(self, didFailedWith: .mnemonicReadingFailed)
                    }
                }
            }
        }
    }
}

extension InputSuggestionsDataController {
    func suggestion(at index: Int) -> String? {
        return currentSuggestions[safe: index]
    }

    func findTopSuggestions(for text: String) {
        let filteredSuggestions = allSuggestions.filter { $0.lowercased().hasPrefix(text.lowercased()) }
        for i in 0...suggestionCount - 1 {
            currentSuggestions[i] = filteredSuggestions[safe: i] ?? ""
        }
    }
}

extension InputSuggestionsDataController {
    enum SuggestionError: Error {
        case mnemonicReadingFailed
    }
}

protocol InputSuggestionsDataControllerDelegate: AnyObject {
    func inputSuggestionsDataController(
        _ inputSuggestionsDataController: InputSuggestionsDataController,
        didFailedWith error: InputSuggestionsDataController.SuggestionError
    )
}
