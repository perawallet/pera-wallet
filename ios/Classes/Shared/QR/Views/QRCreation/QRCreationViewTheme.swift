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
//   QRCreationViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct QRCreationViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let copyButtonTheme: ButtonPrimaryTheme
    let shareButtonTheme: ButtonSecondaryTheme
    let addressTheme: QRAddressLabelTheme
    
    let topInset: LayoutMetric
    let labelTopInset: LayoutMetric
    let labelHorizontalInset: LayoutMetric
    let copyButtonTopInset: LayoutMetric
    let shareButtonTopInset: LayoutMetric
    let buttonTitleInset: LayoutMetric
    let buttonHorizontalInset: LayoutMetric
    let bottomInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.copyButtonTheme = ButtonPrimaryTheme()
        self.shareButtonTheme = ButtonSecondaryTheme()
        self.addressTheme = QRAddressLabelTheme()
        
        self.topInset = 92 * verticalScale
        self.labelTopInset = 28
        self.labelHorizontalInset = 40
        self.copyButtonTopInset = 16
        self.shareButtonTopInset = 16
        self.buttonTitleInset = 12
        self.buttonHorizontalInset = 24
        self.bottomInset = 16
    }
}
