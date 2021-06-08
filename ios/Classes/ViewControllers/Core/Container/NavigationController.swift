// Copyright 2019 Algorand, Inc.

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

class NavigationController: UINavigationController {
    
    override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
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
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = Colors.Background.primary
        navigationBar.tintColor = Colors.Background.primary
        navigationBar.shadowImage = UIImage()
        navigationBar.layoutMargins = .zero
        navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    private func configureViewAppearance() {
        view.backgroundColor = Colors.Background.primary
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
