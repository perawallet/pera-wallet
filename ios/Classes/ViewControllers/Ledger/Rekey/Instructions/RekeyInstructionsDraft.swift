// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RekeyInstructionsDraft.swift

import Foundation
import MacaroonUIKit

class RekeyInstructionsDraft {
    typealias BodyTextProvider = RekeyInstructionsBodyTextProvider
    typealias HighlightedText = RekeyInstructionsBodyTextProvider.HighlightedText

    let image: Image
    let title: TextProvider
    let body: BodyTextProvider
    let instructions: [InstructionItemViewModel]

    init(
        image: Image,
        title: TextProvider,
        body: BodyTextProvider,
        instructions: [InstructionItemViewModel] = []
    ) {
        self.image = image
        self.title = title
        self.body = body
        self.instructions = instructions
    }
}

extension RekeyInstructionsDraft {
    static func makeBody(
        text: String,
        highlightedText: String
    ) -> RekeyInstructionsBodyTextProvider {
        let attributedText = text.bodyRegular()

        var highlightedTextAttributes = Typography.bodyMediumAttributes()
        highlightedTextAttributes.insert(.textColor(Colors.Helpers.positive.uiColor))

        let highlightedText = HighlightedText(
            text: highlightedText,
            attributes: highlightedTextAttributes
        )

        return RekeyInstructionsBodyTextProvider(
            text: attributedText,
            highlightedText: highlightedText
        )
    }
}

struct RekeyInstructionsBodyTextProvider {
    var text: TextProvider
    var highlightedText: HighlightedText? = nil

    struct HighlightedText {
        let text: String
        let attributes: TextAttributeGroup
    }
}
