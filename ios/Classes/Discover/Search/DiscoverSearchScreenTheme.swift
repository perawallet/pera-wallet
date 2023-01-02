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

//   DiscoverSearchScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct DiscoverSearchScreenTheme:
    LayoutSheet,
    StyleSheet {
    var background: ViewStyle
    var contentTopEdgeInset: CGFloat
    var contentHorizontalEdgeInsets: NSDirectionalHorizontalEdgeInsets
    var searchInput: SearchInputViewTheme
    var searchInputBackground: Effect
    var spacingBetweenSearchInputAndSearchInputBackground: CGFloat
    var spacingBetweenSearchInputAndCancelAction: CGFloat
    var cancelAction: ButtonStyle
    var cancelActionContentEdgeInsets: UIEdgeInsets
    var list: ViewStyle

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contentTopEdgeInset = 16
        self.contentHorizontalEdgeInsets = .init(leading: 24, trailing: 24)
        self.searchInput = DiscoverSearchInputViewTheme(family)

        var gradient = Gradient()
        gradient.colors = [
            Colors.Defaults.background.uiColor,
            Colors.Defaults.background.uiColor.withAlphaComponent(0.8),
            Colors.Defaults.background.uiColor.withAlphaComponent(0)
        ]
        gradient.startPoint = .init(x: 0.5, y: 0.82)
        gradient.endPoint = .init(x: 0.5, y: 1.0)
        self.searchInputBackground = LinearGradientEffect(gradient: gradient)

        self.spacingBetweenSearchInputAndSearchInputBackground = 20
        self.spacingBetweenSearchInputAndCancelAction = 12
        self.cancelAction = [
            .font(Fonts.DMSans.medium.make(13)),
            .title("title-cancel".localized),
            .titleColor([ .normal(Colors.Discover.main) ])
        ]
        self.cancelActionContentEdgeInsets = .init(top: 10, left: 12, bottom: 10, right: 12)
        self.list = [
            .backgroundColor(UIColor.clear)
        ]
    }
}

struct DiscoverSearchInputViewTheme: SearchInputViewTheme {
    let textInput: TextInputStyle
    let textInputBackground: ViewStyle
    let textLeftInputAccessory: ImageStyle
    let textRightInputAccessory: ButtonStyle?
    let textClearInputAccessory: ButtonStyle
    let intrinsicHeight: LayoutMetric
    let textInputContentEdgeInsets: LayoutPaddings
    let textInputPaddings: LayoutPaddings
    let textInputAccessorySize: LayoutSize
    let textInputBackgroundRadius: Corner
    let textRightInputAccessoryViewPaddings: LayoutPaddings
    let textRightInputAccessoryViewMode: UITextField.ViewMode
    let placeholder: String

    init(_ family: LayoutFamily) {
        let placeholder = "discover-search-input-placeholder".localized

        self.textInput = [
            .autocapitalizationType(.none),
            .autocorrectionType(.no),
            .font(Fonts.DMSans.regular.make(13)),
            .placeholder(placeholder),
            .placeholderColor(Colors.Discover.textGrayLighter),
            .returnKeyType(.done),
            .textColor(Colors.Discover.textMain),
            .tintColor(Colors.Discover.main)
        ]
        self.textInputBackground = [
            .backgroundColor(Colors.Discover.layer1)
        ]
        self.textLeftInputAccessory = [
            .image("icon-input-search")
        ]
        self.textRightInputAccessory = nil
        self.textClearInputAccessory = [
            .icon([.normal("icon-input-clear")])
        ]
        self.intrinsicHeight = 40
        self.textInputContentEdgeInsets = (0, 16, 0, 16)
        self.textInputPaddings = (0, 0, 0, 0)
        self.textInputAccessorySize = (16, 16)
        self.textInputBackgroundRadius = 16
        self.textRightInputAccessoryViewPaddings = (0, .noMetric, 0, 16)
        self.textRightInputAccessoryViewMode = .whileEditing
        self.placeholder = placeholder
    }
}
