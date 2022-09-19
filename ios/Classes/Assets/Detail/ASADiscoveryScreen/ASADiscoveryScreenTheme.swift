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

//   ASADiscoveryScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ASADiscoveryScreenTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var loading: ASADiscoveryLoadingViewTheme
    var error: NoContentWithActionViewCommonTheme
    var errorBackground: ViewStyle
    var profile: ASAProfileViewTheme
    var profileHorizontalEdgeInsets: LayoutHorizontalPaddings
    var normalProfileVerticalEdgeInsets: LayoutVerticalPaddings
    var foldedProfileVerticalEdgeInsets: LayoutVerticalPaddings

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Helpers.heroBackground)
        ]
        self.loading = ASADiscoveryLoadingViewTheme()
        self.error = NoContentWithActionViewCommonTheme()
        self.errorBackground = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.profile = ASAProfileViewTheme(family)
        self.profileHorizontalEdgeInsets = (24, 24)
        self.normalProfileVerticalEdgeInsets = (50, 36)
        self.foldedProfileVerticalEdgeInsets = (12, 20)
    }
}
