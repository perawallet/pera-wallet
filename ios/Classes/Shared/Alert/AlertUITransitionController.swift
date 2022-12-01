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

//   AlertUITransitionController.swift

import Foundation
import MacaroonUIKit
import MacaroonStorySheet
import UIKit

final class AlertUITransitionController: MacaroonStorySheet.AlertUITransitionController {
    init() {
        var configuration = AlertUIConfiguration()
        configuration.chromeStyle = [
            .backgroundColor(Colors.Backdrop.modalBackground.uiColor)
        ]
        configuration.contentAreaCorner = 16
        configuration.contentAreaPrimaryShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.largeShadow1.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 16),
            radius: 68,
            cornerRadii: (16, 16),
            corners: .allCorners
        )
        configuration.contentAreaSecondaryShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.largeShadow2.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 1,
            cornerRadii: (16, 16),
            corners: .allCorners
        )
        configuration.contentAreaInsets = UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24)

        super.init(configuration: configuration)
    }
}
