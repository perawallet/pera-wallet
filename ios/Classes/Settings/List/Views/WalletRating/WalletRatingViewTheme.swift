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
//   WalletRatingViewTheme.swift


import Foundation
import MacaroonUIKit

struct WalletRatingViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let likeButton: ButtonStyle
    let dislikeButton: ButtonStyle
    let title: TextStyle
    let description: TextStyle
    
    let topInset: LayoutMetric
    let horizontalInset: LayoutMetric
    let titleTopInset: LayoutMetric
    let descriptionTopInset: LayoutMetric
    let bottomInset: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.likeButton = [
            .backgroundImage([.normal("icon-settings-like")])
        ]
        self.dislikeButton = [
            .icon([.normal("icon-settings-dislike")])
        ]
        self.title = [
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(19)),
            .textAlignment(.center),
            .text("settings-rate-modal-title".localized)
        ]
        self.description = [
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.center),
            .text("settings-rate-modal-description".localized)
        ]
        
        self.topInset = 60
        self.horizontalInset = 24
        self.titleTopInset = 36
        self.descriptionTopInset = 12
        self.bottomInset = 56
    }
}
