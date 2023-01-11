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
//   WatchAccountAdditionViewControllerTheme.swift

import MacaroonUIKit

struct WatchAccountAdditionViewControllerTheme:
    LayoutSheet,
    StyleSheet {
    let background: ViewStyle
    let contentEdgeInsets: LayoutPaddings
    let title: TextStyle
    let spacingBetweenTitleAndDescription: LayoutMetric
    let description: TextStyle
    let spacingBetweenDescriptionAndAddressInput: LayoutMetric
    let addressInput: MultilineTextInputFieldViewTheme
    let addressInputMinHeight: LayoutMetric
    let pasteFromClipboardAction: ButtonStyle
    let pasteFromClipboardActionContentEdgeInsets: LayoutPaddings
    let scanQRAction: ButtonStyle
    let spacingBetweenAddressInputAndPasteFromClipboardAction: LayoutMetric
    let spacingBetweenAddressInputAndNameServiceContent: LayoutMetric
    let nameServiceLoadingTheme: PreviewLoadingViewTheme
    let nameServiceLoadingHeight: LayoutMetric
    let nameServiceTheme: AccountListItemViewTheme
    let nameServiceEdgeInsets: LayoutPaddings
    let nameServiceItemSeparator: Separator
    let addAccountAction: ButtonStyle
    let addAccountActionEdgeInsets: LayoutPaddings
    let addAccountActionContentEdgeInsets: LayoutPaddings

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contentEdgeInsets = (2, 24, 0, 24)
        self.title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .text("watch-account-create".localized.titleMedium(lineBreakMode: .byTruncatingTail))
        ]
        self.spacingBetweenTitleAndDescription = 16
        self.description = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText()),
            .text("watch-account-explanation-title".localized.bodyRegular(lineBreakMode: .byTruncatingTail))
        ]
        self.spacingBetweenDescriptionAndAddressInput = 40
        let textInputBaseStyle: TextInputStyle = [
            .font(Typography.bodyRegular()),
            .tintColor(Colors.Text.main),
            .textColor(Colors.Text.main),
            .autocorrectionType(.no),
            .autocapitalizationType(.none),
            .returnKeyType(.done)
        ]
        self.addressInput = MultilineTextInputFieldViewCommonTheme(
            textInput: textInputBaseStyle,
            placeholder: "watch-account-input-placeholder".localized,
            floatingPlaceholder:"watch-account-input-placeholder".localized
        )
        self.addressInputMinHeight = 48
        self.pasteFromClipboardAction = [
            .backgroundColor(Colors.Other.Global.gray800),
            .font(Fonts.DMMono.regular.make(15))
        ]
        self.pasteFromClipboardActionContentEdgeInsets = (10, 16, 10, 16)
        self.scanQRAction = [
            .icon([ .normal("icon-qr-scan") ])
        ]
        self.spacingBetweenAddressInputAndPasteFromClipboardAction = 16
        self.spacingBetweenAddressInputAndNameServiceContent = 16
        self.nameServiceLoadingTheme = PreviewLoadingViewCommonTheme()
        self.nameServiceLoadingHeight = 75
        self.nameServiceTheme = AccountListItemViewTheme(family)
        self.nameServiceEdgeInsets = (14, 0, 14, 0)
        self.nameServiceItemSeparator = Separator(
            color: Colors.Layer.grayLighter,
            size: 1,
            position: .top((56, 0))
        )
        self.addAccountAction = [
            .title("watch-account-button".localized),
            .font(Typography.bodyMedium()),
            .titleColor([
                .normal(Colors.Button.Primary.text),
                .disabled(Colors.Button.Primary.disabledText)
            ]),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ])
        ]
        self.addAccountActionEdgeInsets = (16, 8, 16, 8)
        self.addAccountActionContentEdgeInsets = (8, 24, 12, 24)
    }
}
