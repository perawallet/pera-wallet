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
//   BottomSheetTransition.swift

import Foundation
import MacaroonUIKit
import MacaroonBottomSheet
import UIKit

final class BottomSheetTransition {
    private(set) var transitionController: BottomSheetTransitionController?

    unowned let presentingViewController: UIViewController
    let isInteractable: Bool

    init(
        presentingViewController: UIViewController,
        interactable: Bool = true
    ) {
        self.presentingViewController = presentingViewController
        self.isInteractable = interactable
    }
}

extension BottomSheetTransition {
    @discardableResult
    func perform<T: UIViewController>(
        _ screen: Screen,
        by style: Transition,
        completion: (() -> Void)? = nil
    ) -> T? {
        let transitionController =
            BottomSheetTransitionController(
                interactable: isInteractable,
                presentingViewController: presentingViewController
            ) { [weak self] in

                guard let self = self else {
                    return
                }

                completion?()

                self.transitionController = nil
            }

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
        
        let presentedViewController = presentingViewController.open(
            screen,
            by: transition,
            animated: true
        ) as? T

        self.transitionController = transitionController

        return presentedViewController
    }

    enum Transition {
        case present
        case presentWithoutNavigationController
    }
}
