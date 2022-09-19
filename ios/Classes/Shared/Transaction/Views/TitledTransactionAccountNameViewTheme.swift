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
//   TitledTransactionAccountNameViewTheme.swift

import Foundation
import MacaroonUIKit

final class TitledTransactionAccountNameViewTheme: LayoutSheet, StyleSheet {
    var title: TextStyle {
        return [
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(15))
        ]
    }

    var detailLabelLeadingPadding: LayoutMetric {
        return 137
    }

    var nameLeadingInset: LayoutMetric {
        return 8
    }

    var accountTheme: ImageWithTitleViewTheme

    init(_ family: LayoutFamily) {
        self.accountTheme = WCAccountNameViewSmallTheme(family)
    }
}
