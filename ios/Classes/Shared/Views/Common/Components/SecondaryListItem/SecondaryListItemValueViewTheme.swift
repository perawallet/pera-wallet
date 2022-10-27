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

//   SecondaryListItemValueViewTheme.swift

import MacaroonUIKit

protocol SecondaryListItemValueViewTheme:
    LayoutSheet,
    StyleSheet {
    /// <note> If view has action, pass `true` to `isInteractable(Bool)` attribute.
    var view: ViewStyle { get }
    var backgroundImage: ImageStyle { get }
    var contentEdgeInsets: LayoutPaddings { get }
    var iconLayoutOffset: LayoutOffset { get }
    var title: TextStyle { get }
}

struct SecondaryListItemValueCommonViewTheme: SecondaryListItemValueViewTheme {
    var view: ViewStyle
    var backgroundImage: ImageStyle
    var contentEdgeInsets: LayoutPaddings
    var iconLayoutOffset: LayoutOffset
    var title: TextStyle

    init(
        _ family: LayoutFamily = .current,
        isMultiline: Bool,
        isInteractable: Bool
    ) {
        self.view = [ .isInteractable(isInteractable) ]
        self.backgroundImage = [ .isInteractable(false) ]
        self.contentEdgeInsets = (0, 0, 0, 0)
        self.iconLayoutOffset = (10, 0)

        if isMultiline {
            self.title = [ .textOverflow(MultilineText(numberOfLines: 2)) ]
        } else {
            self.title = []
        }
    }

    init(
        _ family: LayoutFamily
    ) {
        self.init(
            family,
            isMultiline: false,
            isInteractable: false
        )
    }
}
