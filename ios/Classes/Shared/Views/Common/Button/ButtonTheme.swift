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
//   ButtonTheme.swift

import MacaroonUIKit

protocol ButtonTheme: LayoutSheet, StyleSheet {
    var label: TextStyle { get }
    var icon: ImageStyle { get }
    var titleColorSet: StateColorGroup { get }
    var backgroundColorSet: StateColorGroup { get }
    var corner: Corner { get }
    var indicator: ImageStyle { get }

    var contentEdgeInsets: LayoutPaddings { get }

    var firstShadow: MacaroonUIKit.Shadow? { get }
    var secondShadow: MacaroonUIKit.Shadow? { get }
    var thirdShadow: MacaroonUIKit.Shadow? { get }
}

extension ButtonTheme {
    var firstShadow: MacaroonUIKit.Shadow? {
        return nil
    }
    var secondShadow: MacaroonUIKit.Shadow? {
        return nil
    }
    var thirdShadow: MacaroonUIKit.Shadow? {
        return nil
    }
}
