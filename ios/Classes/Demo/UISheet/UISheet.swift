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

//   UISheet.swift

import Foundation
import MacaroonUIKit

class UISheet {
    typealias SubtitleTextProvider = UISheetBodyTextProvider
    typealias HighlightedText = UISheetBodyTextProvider.HighlightedText

    let image: Image?
    let title: TextProvider?
    let body: SubtitleTextProvider?
    let info: TextProvider?

    var bodyHyperlinkHandler: (() -> Void)?

    private(set) var actions: [UISheetAction] = []

    init(
        image: Image? = nil,
        title: TextProvider? = nil,
        body: UISheetBodyTextProvider? = nil,
        info: TextProvider? = nil
    ) {
        self.image = image
        self.title = title
        self.body = body
        self.info = info
    }

    func addAction(
        _ action: UISheetAction
    ) {
        actions.append(action)
    }
}

struct UISheetBodyTextProvider {
    var text: TextProvider
    var highlightedText: HighlightedText? = nil

    struct HighlightedText {
        let text: String
        let attributes: TextAttributeGroup
    }
}
