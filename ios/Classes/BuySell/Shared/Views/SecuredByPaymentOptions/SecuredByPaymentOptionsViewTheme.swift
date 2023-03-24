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

//   SecuredByPaymentOptionsViewTheme.swift

import Foundation
import MacaroonUIKit

struct SecuredByPaymentOptionsViewTheme:
    LayoutSheet,
    StyleSheet {
    var spacingBetweenIconAndTitle: LayoutMetric
    var title: TextStyle
    var spacingBetweenIconAndTitleContentAndOptions: LayoutMetric
    var spacingBetweenOptions: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.spacingBetweenIconAndTitle = 8
        self.title = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Helpers.positive)
        ]
        self.spacingBetweenIconAndTitleContentAndOptions = 16
        self.spacingBetweenOptions = 24
    }
}
