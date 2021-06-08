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
//   InputSuggestionViewModel.swift

import Foundation

class InputSuggestionViewModel {
    private let lastSuggestionIndex = 2

    private(set) var suggestion: String?
    private(set) var isSeparatorHidden = false

    init(suggestion: String, index: Int) {
        setSuggestion(from: suggestion)
        setIsSeparatorHidden(from: index)
    }

    private func setSuggestion(from suggestion: String) {
        self.suggestion = suggestion.isEmpty ? "" : "\"\(suggestion)\""
    }

    private func setIsSeparatorHidden(from index: Int) {
        isSeparatorHidden = index == lastSuggestionIndex
    }
}
