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

import UIKit

final class NavigationController: UINavigationController {
    override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return topViewController?.preferredStatusBarUpdateAnimation ?? .none
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        linkInteractors()
    }
}

extension NavigationController {
    private func configureAppearance() {
        configureNavigationBarAppearance()
        configureViewAppearance()
    }
    
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            NSAttributedString.Key.font: Fonts.DMSans.medium.make(15).uiFont,
            NSAttributedString.Key.foregroundColor: AppColors.Components.Text.main.uiColor
        ]
        appearance.largeTitleTextAttributes = [
            NSAttributedString.Key.font: Fonts.DMSans.medium.make(32).uiFont,
            NSAttributedString.Key.foregroundColor: AppColors.Components.Text.main.uiColor
        ]

        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = AppColors.Shared.System.background.uiColor
        appearance.shadowColor = .clear
        navigationBar.isTranslucent = false
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
    }
    
    private func configureViewAppearance() {
        view.backgroundColor = AppColors.Shared.System.background.uiColor
    }
}

extension NavigationController {
    private func linkInteractors() {
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }
}

extension NavigationController: UINavigationControllerDelegate {
}

extension NavigationController: UIGestureRecognizerDelegate {
}
