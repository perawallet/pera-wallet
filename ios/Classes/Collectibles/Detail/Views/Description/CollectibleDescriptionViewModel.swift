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

//   CollectibleDescriptionViewModel.swift

import Foundation
import MacaroonUIKit

struct CollectibleDescriptionViewModel {
    private(set) var description: TextProvider?
    private(set) var isTruncatable: Bool = false

    init(
        asset: Asset,
        isTruncated: Bool,
        characterThreshold: Int = 180
    ) {
        bindDescription(
            asset: asset,
            isTruncated: isTruncated,
            characterThreshold: characterThreshold
        )
    }
}

extension CollectibleDescriptionViewModel {
    private mutating func bindDescription(
        asset: Asset,
        isTruncated: Bool,
        characterThreshold: Int
    ) {
        guard let description = asset.description else {
            self.description = nil
            self.isTruncatable = false
            return
        }

        let (aDescription, isTruncatable) = formDescription(
            from: description,
            isTruncated: isTruncated,
            characterThreshold: characterThreshold
        )

        self.isTruncatable = isTruncatable
        self.description = aDescription.bodyRegular()
    }

    private func formDescription(
        from description: String,
        isTruncated: Bool,
        characterThreshold: Int
    ) -> (String, Bool) {
        let descriptionCharacterCount = description.count
        let isTruncatable = descriptionCharacterCount > characterThreshold

        guard isTruncated && isTruncatable else {
            return (description, isTruncatable)
        }

        let truncatedDescription = description.prefix(characterThreshold)
        let textAfterTruncatedDescription = description.safeSubstring(with: truncatedDescription.endIndex..<description.endIndex)

        let startIndexOfLastTruncatedWord = truncatedDescription.startIndexOfLastWord
        let endIndexOfLastTruncatedWord = textAfterTruncatedDescription.endIndexOfFirstWord
        let lastTruncatedWord = description.safeSubstring(with: startIndexOfLastTruncatedWord..<endIndexOfLastTruncatedWord)

        guard lastTruncatedWord.isValidURL else {
            return ("\(truncatedDescription)...", isTruncatable)
        }

        let isLastWord = endIndexOfLastTruncatedWord == description.endIndex
        if isLastWord {
            return (description, false)
        } else {
            return ("\(description.safeSubstring(with: description.startIndex..<endIndexOfLastTruncatedWord))...", isTruncatable)
        }
    }
}

private extension Substring {
    /// <note>
    /// Valid URL check that matches with `ActiveLabel`'s URL pattern.
    var isValidURL: Bool {
        return Self.predicate.evaluate(with: self)
    }

    static let predicate: NSPredicate = {
        /// <note>
        /// URL pattern used in `ActiveLabel`'s `RegexParser`.
        let pattern =
            "(^|[\\s.:;?\\-\\]<\\(])" +
            "((https?://|www\\.|pic\\.)[-\\w;/?:@&=+$\\|\\_.!~*\\|'()\\[\\]%#,☺]+[\\w/#](\\(\\))?)" +
            "(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])"
        return NSPredicate(format: "SELF MATCHES %@", argumentArray: [pattern])
    }()
}
