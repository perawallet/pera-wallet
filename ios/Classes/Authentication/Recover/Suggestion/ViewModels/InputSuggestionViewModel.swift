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
//   InputSuggestionViewModel.swift

import Foundation
import MacaroonUIKit

final class InputSuggestionViewModel: ViewModel {
    private let lastSuggestionIndex = 2

    private(set) var suggestion: String?
    private(set) var isSeparatorHidden = false

    init(suggestion: String?, index: Int) {
        bindSuggestion(from: suggestion)
        bindIsSeparatorHidden(from: index)
    }
}

extension InputSuggestionViewModel {
    private func bindSuggestion(from suggestion: String?) {
        guard let suggestion = suggestion else {
            self.suggestion = .empty
            return
        }

        self.suggestion = suggestion.isEmpty ? .empty : "\"\(suggestion)\""
    }

    private func bindIsSeparatorHidden(from index: Int) {
        isSeparatorHidden = index == lastSuggestionIndex
    }
}
