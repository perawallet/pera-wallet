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
//   OptionsViewController+Theme.swift

import MacaroonUIKit
import UIKit

extension OptionsViewController {
    struct Theme: LayoutSheet, StyleSheet {
        let backgroundColor: Color
        let copyAddressCellSize: LayoutSize
        let defaultCellSize: LayoutSize
        let modalHeight: LayoutMetric

        init(_ family: LayoutFamily) {
            backgroundColor = AppColors.Shared.System.background
            defaultCellSize = (UIScreen.main.bounds.width, 60)
            copyAddressCellSize = (UIScreen.main.bounds.width, 68)
            modalHeight = 462
        }
    }
}
