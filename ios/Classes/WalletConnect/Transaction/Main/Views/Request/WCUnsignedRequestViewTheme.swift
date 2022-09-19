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
//   WCUnsignedRequestViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct WCUnsignedRequestViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let confirmButton: ButtonPrimaryTheme
    let cancelButton: ButtonSecondaryTheme
    let buttonPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let confirmButtonWidthMultiplier: LayoutMetric
    let buttonHeight: LayoutMetric
    let collectionViewBottomOffset: LayoutMetric
    let buttonContainerHeight: LayoutMetric
    let buttonBottomInset: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.confirmButton = ButtonPrimaryTheme(family)
        self.cancelButton = ButtonSecondaryTheme(family)
        self.buttonPadding = 20
        self.horizontalPadding = 24
        self.confirmButtonWidthMultiplier = 2
        self.buttonHeight = 52
        self.buttonContainerHeight = 150
        self.buttonBottomInset = UIApplication.shared.safeAreaBottom + 16
        self.collectionViewBottomOffset = buttonBottomInset + buttonHeight + 12
    }
}
