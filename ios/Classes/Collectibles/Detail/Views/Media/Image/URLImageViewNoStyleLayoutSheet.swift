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

//   URLImageViewNoStyleLayoutSheet.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage

typealias URLImageViewStyleLayoutSheet =  URLImageViewStyleSheet & URLImageViewLayoutSheet

struct URLImageViewNoStyleLayoutSheet: URLImageViewStyleLayoutSheet {
    let background: ViewStyle
    let content: ImageStyle
    let placeholderStyleSheet: URLImagePlaceholderViewStyleSheet?
    let placeholderLayoutSheet: URLImagePlaceholderViewLayoutSheet?

    init(
        _ family: LayoutFamily
    ) {
        background = []
        content = []
        placeholderStyleSheet = URLImagePlaceholderDefaultStyleSheet()
        placeholderLayoutSheet = URLImagePlaceholderDefaultLayoutSheet(family)
    }
}

struct URLImagePlaceholderDefaultStyleSheet: URLImagePlaceholderViewStyleSheet {
    var background: ViewStyle
    var image: ImageStyle
    var text: TextStyle

    init() {
        self.background = []
        self.image = [
            .contentMode(.scaleAspectFit)
        ]
        self.text = []
    }
}

struct URLImagePlaceholderDefaultLayoutSheet: URLImagePlaceholderViewLayoutSheet {
    var textPaddings: LayoutPaddings

    init(_ family: LayoutFamily) {
        self.textPaddings = (0, 0, 0, 0)
    }
}
