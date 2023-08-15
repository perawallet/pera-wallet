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

//   AccountInformationOptionsViewTheme.swift

import Foundation
import MacaroonUIKit

struct AccountInformationOptionsViewTheme:
    LayoutSheet,
    StyleSheet {
    var option: ListItemButtonTheme
    var spacingBetweenOptions: LayoutMetric

    init(_ family: LayoutFamily) {
        var option = ListItemButtonTheme(family)
        option.contentVerticalPaddings = (0, 0)
        option.contentMinHeight = 40
        option.accessory = [ .tintColor(Colors.Text.grayLighter) ]
        self.option = option
        self.spacingBetweenOptions = 8
    }
}
