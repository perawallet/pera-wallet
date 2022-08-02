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

//   AlertUITransition.swift

import Foundation
import MacaroonUIKit
import MacaroonStorySheet
import UIKit

final class AlertUITransition {
    private(set) var transitionController: AlertUITransitionController?

    unowned let presentingViewController: UIViewController

    init(
        presentingViewController: UIViewController
    ) {
        self.presentingViewController = presentingViewController
    }
}

extension AlertUITransition {
    @discardableResult
    func perform<T: UIViewController>(
        _ screen: Screen,
        by style: Transition
    ) -> T? {
        let transitionController = AlertUITransitionController()

        let transition: Screen.Transition.Open
        switch style {
        case .present:
            transition = .customPresent(
                presentationStyle: .custom,
                transitionStyle: .coverVertical,
                transitioningDelegate: transitionController
            )
        case .presentWithoutNavigationController:
            transition = .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: .coverVertical,
                transitioningDelegate: transitionController
            )
        }

        self.transitionController = transitionController
        return presentingViewController.open(
            screen,
            by: transition,
            animated: true
        ) as? T
    }
}

extension AlertUITransition {
    enum Transition {
        case present
        case presentWithoutNavigationController
    }
}
