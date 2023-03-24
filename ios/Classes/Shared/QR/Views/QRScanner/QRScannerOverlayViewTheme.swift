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
//   QRScannerOverlayViewTheme.swift

import UIKit
import MacaroonUIKit

struct QRScannerOverlayViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let backButton: ButtonStyle
    let dismissButton: ButtonStyle
    let overlayImage: ImageStyle
    let connectedAppsButton: ButtonStyle
    let connectedAppsButtonCorner: Corner

    let horizontalInset: LayoutMetric
    let titleLabelTopInset: LayoutMetric
    let overlayViewSize: LayoutMetric
    let overlayCornerRadius: LayoutMetric
    let overlayImageViewSize: LayoutMetric
    let connectedAppsButtonContentEdgeInsets: LayoutPaddings
    let connectedAppsButtonBottomInset: LayoutMetric
    let cancelButtonSize: LayoutSize
    let connectedAppsButtonTitleImageSpacing: LayoutMetric

    init(_ family: LayoutFamily) {
        self.init(family, title: "qr-scan-overlay-title".localized)
    }

    init(_ family: LayoutFamily, title: String) {
        self.backgroundColor = Colors.QRScanner.background
        let backButtonIcon = "icon-back".uiImage.withRenderingMode(.alwaysTemplate)
        self.backButton = [
            .icon([.normal(backButtonIcon)]),
            .tintColor(Colors.Text.white)
        ]
        let dismissButtonIcon = "icon-close".uiImage.withRenderingMode(.alwaysTemplate)
        self.dismissButton = [
            .icon([.normal(dismissButtonIcon)]),
            .tintColor(Colors.Text.white)
        ]
        self.title = [
            .text(title),
            .textAlignment(.center),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.white),
            .font(Fonts.DMSans.regular.make(24))
        ]
        self.overlayImage = [
            .image("img-qr-overlay-center")
        ]
        self.connectedAppsButton = [
            .icon([.normal("icon-white-disclosure")]),
            .titleColor([.normal(Colors.Text.white)]),
            .font(Fonts.DMSans.medium.make(16))
        ]
        self.horizontalInset = 24
        self.overlayViewSize = 260
        self.overlayCornerRadius = 12
        self.overlayImageViewSize = 266
        self.connectedAppsButtonContentEdgeInsets = (12, 20, 12, 16)
        self.connectedAppsButtonTitleImageSpacing = 8
        self.connectedAppsButtonCorner = Corner(radius: 4)
        self.connectedAppsButtonBottomInset = 34
        self.cancelButtonSize = (44, 44)
        self.titleLabelTopInset = 30 + cancelButtonSize.h
    }
}
