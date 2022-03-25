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

//   BuyAlgoHomeViewModel.swift

import Foundation
import MacaroonUIKit

struct BuyAlgoHomeViewModel: ViewModel {
    private(set) var logoImage: Image?
    private(set) var headerBackgroundImage: Image?
    private(set) var title: EditText?
    private(set) var subtitle: EditText?
    private(set) var description: EditText?
    private(set) var securityImage: Image?
    private(set) var security: EditText?
    private(set) var paymentMethodImages: [Image] = []
    
    init() {
        bind()
    }
}

extension BuyAlgoHomeViewModel {
    private mutating func bind() {
        bindLogoImage()
        bindHeaderBackground()
        bindTitle()
        bindSubtitle()
        bindDescription()
        bindSecurity()
        bindPaymentMethods()
    }
    
    private mutating func bindLogoImage() {
        logoImage = "icon-moonpay-logo"
    }
    
    private mutating func bindHeaderBackground() {
        headerBackgroundImage = "img-moonpay-background"
    }
    
    private mutating func bindTitle() {
        let font = Fonts.DMSans.regular.make(15).uiFont
        let lineHeightMultiplier = 1.23
        
        title = .attributedString(
            "moonpay-introduction-title"
                .localized
                .attributed(
                    [
                        .font(font),
                        .lineHeightMultiplier(lineHeightMultiplier, font),
                        .paragraph([
                            .textAlignment(.center),
                            .lineHeightMultiple(lineHeightMultiplier)
                        ]),
                    ]
                )
        )
    }
    
    private mutating func bindSubtitle() {
        let font = Fonts.DMSans.medium.make(32).uiFont
        let lineHeightMultiplier = 0.96

        subtitle = .attributedString(
            "moonpay-buy-button-title"
                .localized
                .attributed(
                    [
                        .font(font),
                        .lineHeightMultiplier(lineHeightMultiplier, font),
                        .paragraph([
                            .textAlignment(.left),
                            .lineBreakMode(.byWordWrapping),
                            .lineHeightMultiple(lineHeightMultiplier)
                        ]),
                    ]
                )
        )
    }
    
    private mutating func bindDescription() {
        let font = Fonts.DMSans.regular.make(15).uiFont
        let lineHeightMultiplier = 1.23

        description = .attributedString(
            "moonpay-introduction-description"
                .localized
                .attributed(
                    [
                        .font(font),
                        .lineHeightMultiplier(lineHeightMultiplier, font),
                        .paragraph([
                            .textAlignment(.left),
                            .lineBreakMode(.byWordWrapping),
                            .lineHeightMultiple(lineHeightMultiplier)
                        ]),
                    ]
                )
        )
    }
    
    private mutating func bindSecurity() {
        securityImage = "icon-payment-security"
        
        let font = Fonts.DMSans.medium.make(15).uiFont
        let lineHeightMultiplier = 1.23

        security = .attributedString(
            "moonpay-introduction-security"
                .localized
                .attributed(
                    [
                        .font(font),
                        .lineHeightMultiplier(lineHeightMultiplier, font),
                        .paragraph([
                            .textAlignment(.left),
                            .lineBreakMode(.byWordWrapping),
                            .lineHeightMultiple(lineHeightMultiplier)
                        ]),
                    ]
                )
        )
    }
    
    private mutating func bindPaymentMethods() {
        paymentMethodImages = [
            "icon-payment-mastercard",
            "icon-payment-visa",
            "icon-payment-apple"
        ]
    }
}
