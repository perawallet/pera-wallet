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
//  UIViewController+Flow.swift

import Foundation
import UIKit

extension UIViewController {
    func launchOnboarding() {
        AppDelegate.shared?.launchOnboarding()
    }
    
    func launchMain(
        completion: (() -> Void)? = nil
    ) {
        AppDelegate.shared?.launchMain(completion: completion)
    }
    
    func launchMainAfterAuthorization(
        presented viewController: UIViewController
    ) {
        AppDelegate.shared?.launchMainAfterAuthorization(presented: viewController)
    }

    func launchBuyAlgoWithMeld(draft: MeldDraft) {
        AppDelegate.shared?.receive(deeplinkWithSource: .buyAlgoWithMeld(draft))
    }
}

extension UIViewController {
    @discardableResult
    func open<T: UIViewController>(
        _ screen: Screen,
        by style: Screen.Transition.Open,
        animated: Bool = true,
        then completion: EmptyHandler? = nil
    ) -> T? {
        return AppDelegate.shared?.route(
            to: screen,
            from: self,
            by: style,
            animated: animated,
            then: completion
        ) as? T
    }

    func closeScreen(
        by style: Screen.Transition.Close,
        animated: Bool = true,
        onCompletion completion: EmptyHandler? = nil
    ) {
        switch style {
        case .pop:
            navigationController?.popViewController(animated: animated)
        case .dismiss:
            presentingViewController?.dismiss(
                animated: animated,
                completion: completion
            )
        }
    }
    
    func dismissScreen(
        animated: Bool = true,
        completion: EmptyHandler? = nil
    ) {
        closeScreen(
            by: .dismiss,
            animated: animated,
            onCompletion: completion
        )
    }
    
    func popScreen(
        animated: Bool = true
    ) {
        closeScreen(
            by: .pop,
            animated: animated
        )
    }
}

extension UIViewController {
    func dismissIfNeeded(
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        if presentedViewController == nil {
            completion?()
            return
        }
        
        dismiss(
            animated: animated,
            completion: completion
        )
    }
}

extension UIViewController {
    func findVisibleScreen() -> UIViewController {
        return AppDelegate.shared!.findVisibleScreen()
    }
}
