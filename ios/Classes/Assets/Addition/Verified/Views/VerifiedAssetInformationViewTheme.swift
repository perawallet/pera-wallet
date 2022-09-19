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
//   VerifiedAssetInformationViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct VerifiedAssetInformationViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let information: TextStyle
    let image: ImageStyle
    
    let imageLeadingOffset: LayoutMetric
    let horizontalInset: LayoutMetric
    let topInset: LayoutMetric
    let verticalSpacing: LayoutMetric
    let bottomInset: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        
        self.title = [
            .textAlignment(.left),
            .text("verified-asset-information-title".localized),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(15))
        ]
        
        let fullText = "verified-asset-information-text".localized(AlgorandWeb.support.presentation)
        let doubleCheckText = "verified-asset-double-check".localized
        let contactText = AlgorandWeb.support.presentation
        
        let fullAttributedText = NSMutableAttributedString(string: fullText)
        
        let fullTextRange = (fullText as NSString).range(of: fullText)
        fullAttributedText.addAttributes(
            [.foregroundColor: Colors.Text.main.uiColor,
             .font: Fonts.DMSans.regular.make(15).uiFont],
            range: fullTextRange)
        
        let doubleCheckTextRange = (fullText as NSString).range(of: doubleCheckText)
        fullAttributedText.addAttributes(
            [.foregroundColor: Colors.Helpers.negative.uiColor,
             .font: Fonts.DMSans.medium.make(15).uiFont],
            range: doubleCheckTextRange)
        
        let contactTextRange = (fullText as NSString).range(of: contactText)
        fullAttributedText.addAttributes(
            [.foregroundColor: Colors.Link.primary.uiColor,
             .font: Fonts.DMSans.medium.make(15).uiFont],
            range: contactTextRange)
        
        self.information = [
            .textAlignment(.left),
            .text(fullAttributedText),
            .textOverflow(FittingText())
        ]
        self.image = [
            .image("icon-verified-shield")
        ]
        
        self.imageLeadingOffset = 12
        self.horizontalInset = 24
        self.topInset = 32
        self.verticalSpacing = 20
        self.bottomInset = 16
    }
}
