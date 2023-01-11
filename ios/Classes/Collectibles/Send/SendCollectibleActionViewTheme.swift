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

//   SendCollectibleActionViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SendCollectibleActionViewTheme:
    StyleSheet,
    LayoutSheet {
    let content: ViewStyle
    let contentCorner: Corner
    let handle: ImageStyle
    let handleTopPadding: LayoutMetric
    let closeActionViewPaddings: LayoutPaddings
    let closeAction: ButtonStyle
    let title: TextStyle
    let titleViewHorizontalPaddings: LayoutHorizontalPaddings
    let contextViewPaddings: LayoutPaddings
    let addressInputTheme: MultilineTextInputFieldViewTheme
    let addressInputViewMinHeight: LayoutMetric
    let selectReceiverAction: ButtonStyle
    let scanQRAction: ButtonStyle
    let spacingBetweenSelectReceiverAndScanQR: LayoutMetric
    let actionButtonIndicator: ImageStyle
    let actionButton: ButtonStyle
    let actionButtonDisabled: ButtonStyle
    let actionButtonContentEdgeInsets: LayoutPaddings
    let actionButtonCorner: Corner
    let actionButtonTopPadding: LayoutMetric
    let actionButtonHeight: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        content = [
            .backgroundColor(Colors.Defaults.background)
        ]

        contentCorner = Corner(
            radius: 16,
            mask: [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
        )

        closeActionViewPaddings = (30, 20, .noMetric, .noMetric)

        closeAction = [
            .icon([ .normal("icon-close") ])
        ]

        handle = [.image("icon-bottom-sheet-handle")]
        handleTopPadding = 8

        title = [
            .text(Self.getTitle("collectible-send-title".localized)),
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineText())
        ]

        titleViewHorizontalPaddings = (8, 24)

        contextViewPaddings = (16, 24, 16, 24)

        let textInputBaseStyle: TextInputStyle = [
            .font(Fonts.DMSans.regular.make(15)),
            .tintColor(Colors.Text.main),
            .textColor(Colors.Text.main),
            .returnKeyType(.done)
        ]

        var addressInputTheme = MultilineTextInputFieldViewCommonTheme(
            textInput: textInputBaseStyle,
            placeholder:"collectible-send-input-placeholder".localized,
            floatingPlaceholder: "collectible-send-input-placeholder".localized
        )

        addressInputTheme.configureForDoubleAccessory()
        self.addressInputTheme = addressInputTheme
        addressInputViewMinHeight = 48

        selectReceiverAction = [
            .icon([ .normal("icon-settings-contacts") ])
        ]

        scanQRAction = [
            .icon([ .normal("icon-qr-scan") ])
        ]

        spacingBetweenSelectReceiverAndScanQR = 16

        actionButtonIndicator = [
            .image("button-loading-indicator"),
            .contentMode(.scaleAspectFit)
        ]

        actionButton = [
            .title(Self.getTitle("collectible-send-action".localized)),
            .titleColor([
                .normal(Colors.Button.Primary.text),
            ]),
            .backgroundColor(Colors.Button.Primary.background)
        ]

        actionButtonDisabled = [
            .title(Self.getTitle("collectible-send-action".localized)),
            .titleColor([
                .normal(Colors.Button.Primary.disabledText),
            ]),
            .backgroundColor(Colors.Button.Primary.disabledBackground)
        ]

        actionButtonContentEdgeInsets = (14, 0, 14, 0)
        actionButtonCorner = Corner(radius: 4)
        actionButtonTopPadding = 32
        actionButtonHeight = 52
    }
}

extension SendCollectibleActionViewTheme {
    private static func getTitle(
        _ title: String
    ) -> EditText {
        return .attributedString(
            title
                .bodyMedium(lineBreakMode: .byTruncatingTail)
        )
    }
}
