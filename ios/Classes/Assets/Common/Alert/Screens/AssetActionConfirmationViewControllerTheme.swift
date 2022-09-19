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
//   AssetActionConfirmationViewControllerTheme.swift

import MacaroonUIKit

struct AssetActionConfirmationViewControllerTheme:
    LayoutSheet,
    StyleSheet {
    var loading: AssetActionConfirmationLoadingViewTheme
    var context: AssetActionConfirmationViewTheme

    let background: ViewStyle

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.loading = AssetActionConfirmationLoadingViewTheme()
        self.context = AssetActionConfirmationViewTheme()
    }

    static let secondaryActionOnly: AssetActionConfirmationViewControllerTheme = {
        var theme = AssetActionConfirmationViewControllerTheme()
        theme.loading.spacingBetweenPrimaryAndSecondaryAction = 0
        theme.context.buttonInset = 0
        return theme
    }()
}
