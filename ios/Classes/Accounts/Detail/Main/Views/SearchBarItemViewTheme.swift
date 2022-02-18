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
//   SearchBarItemViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SearchBarItemViewTheme: StyleSheet, LayoutSheet {
    let searchInput: SearchInputViewTheme

    let horizontalInset: LayoutMetric
    let verticalInset: LayoutMetric

    init(placeholder: String, family: LayoutFamily = .current) {
        self.searchInput = SearchInputViewCommonTheme(placeholder: placeholder, family: family)

        self.horizontalInset = 24
        self.verticalInset = 16
    }

    init(_ family: LayoutFamily) {
        self.init(placeholder: .empty, family: family)
    }
}
