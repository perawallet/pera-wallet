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
//  NavigationController.swift

import Foundation
import MacaroonUIKit
import UIKit

final class NavigationContainer: MacaroonUIKit.NavigationContainer {
    override func customizeNavigationBarAppearance() {
        customizeNavigationBarDefaultAppearance()
    }

    override func customizeViewAppearance() {
        view.customizeAppearance(
            [
                .backgroundColor(Colors.Defaults.background)
            ]
        )
    }
}

extension NavigationContainer {
    func customizeNavigationBarDefaultAppearance() {
        let titleAttributeGroup: TextAttributeGroup = [
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(Colors.Text.main)
        ]
        let largeTitleAttributeGroup: TextAttributeGroup = [
            .font(Fonts.DMSans.medium.make(32)),
            .textColor(Colors.Text.main)
        ]

        navigationBar.customizeAppearance(
            [
                .backgroundColor(Colors.Defaults.background),
                .backImage("icon-back"),
                .isOpaque(true),
                .largeTitleAttributes(largeTitleAttributeGroup.asSystemAttributes()),
                .shadowImage(UIImage()),
                .shadowColor(nil),
                .tintColor(Colors.Text.main),
                .titleAttributes(titleAttributeGroup.asSystemAttributes())
            ]
        )
    }

    func customizeNavigationBarHighlightedAppearance() {
        let titleAttributeGroup: TextAttributeGroup = [
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(Colors.Text.main)
        ]
        let largeTitleAttributeGroup: TextAttributeGroup = [
            .font(Fonts.DMSans.medium.make(32)),
            .textColor(Colors.Text.main)
        ]

        navigationBar.customizeAppearance(
            [
                .backgroundColor(Colors.Helpers.heroBackground),
                .backImage("icon-back"),
                .isOpaque(true),
                .largeTitleAttributes(largeTitleAttributeGroup.asSystemAttributes()),
                .shadowImage(UIImage()),
                .shadowColor(nil),
                .tintColor(Colors.Text.main),
                .titleAttributes(titleAttributeGroup.asSystemAttributes())
            ]
        )
    }

    func customizeNavigationBarTransparentAppearance(_ textColor: UIColor) {
        let titleAttributeGroup: TextAttributeGroup = [
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(textColor)
        ]
        let largeTitleAttributeGroup: TextAttributeGroup = [
            .font(Fonts.DMSans.medium.make(32)),
            .textColor(textColor)
        ]

        navigationBar.customizeAppearance(
            [
                .backImage("icon-back"),
                .isOpaque(false),
                .largeTitleAttributes(largeTitleAttributeGroup.asSystemAttributes()),
                .shadowImage(UIImage()),
                .shadowColor(nil),
                .tintColor(Colors.Text.main),
                .titleAttributes(titleAttributeGroup.asSystemAttributes())
            ]
        )
    }
}

extension UIViewController {
    private var navigationContainer: NavigationContainer? {
        return navigationController as? NavigationContainer
    }

    func switchToDefaultNavigationBarAppearance() {
        navigationContainer?.customizeNavigationBarDefaultAppearance()
    }

    func switchToHighlightedNavigationBarAppearance() {
        navigationContainer?.customizeNavigationBarHighlightedAppearance()
    }

    func switchToTransparentNavigationBarAppearance(_ textColor: UIColor = .white) {
        navigationContainer?.customizeNavigationBarTransparentAppearance(textColor)
    }
}
