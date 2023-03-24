// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WebImportErrorScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct WebImportErrorScreenTheme: LayoutSheet, StyleSheet {
    let background: ViewStyle
    let resultViewTheme: WebImportErrorResultViewTheme
    let resultViewTopInset: LayoutMetric
    let resultViewHorizontalInset: LayoutMetric

    let goToHomeAction: ButtonStyle
    let goToHomeActionContentEdgeInsets: UIEdgeInsets
    let goToHomeActionEdgeInsets: NSDirectionalEdgeInsets

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.resultViewTheme = WebImportErrorResultViewTheme(family)
        self.resultViewTopInset = 72
        self.resultViewHorizontalInset = 24

        self.goToHomeAction = [
            .title("web-import-error-action".localized),
            .titleColor([
                .normal(Colors.Button.Primary.text)
            ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .selected("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ])
        ]
        self.goToHomeActionContentEdgeInsets = .init(top: 14, left: 0, bottom: 14, right: 0)
        self.goToHomeActionEdgeInsets = .init(top: 36, leading: 24, bottom: 16, trailing: 24)
    }
}
